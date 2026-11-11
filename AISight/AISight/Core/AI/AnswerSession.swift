import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Observable
final class AnswerSession {
    var streamingText: String = ""
    var isGenerating: Bool = false
    private(set) var error: AnswerError? = nil
    private(set) var wasRegenerated: Bool = false
    private(set) var usedModel = ResolvedLanguageModel.placeholder

    private let contentFetcher: ContentFetcher

    init(contentFetcher: ContentFetcher = ContentFetcher()) {
        self.contentFetcher = contentFetcher
    }

    func reset() {
        streamingText = ""
        isGenerating = false
        error = nil
        wasRegenerated = false
        usedModel = .placeholder
    }

    func generateAnswer(
        for query: String, with searchOutput: SearchOutput, language: String = "en", canUseCloudModel: Bool
    ) async {
        streamingText = ""
        isGenerating = true
        error = nil
        wasRegenerated = false
        defer { isGenerating = false }

        let model = await LanguageModelProvider.resolve(canUseCloudModel: canUseCloudModel)
        usedModel = model
        do {
            try await LanguageModelProvider.runWithCloudFallback(
                model,
                onFallback: { fallback in
                    usedModel = fallback
                    streamingText = ""
                    wasRegenerated = false
                },
                work: { model in
                    try await generate(query: query, searchOutput: searchOutput, language: language, model: model)
                }
            )
        } catch {
            guard !Task.isCancelled else { return }
            self.error = answerError(from: error)
        }
    }

    private func generate(
        query: String, searchOutput: SearchOutput, language: String, model: ResolvedLanguageModel
    ) async throws {
        // 1. Fetch full content for short snippets (concurrent)
        let results = Array(searchOutput.results.prefix(AppConfig.maxResults))
        let maxSnippet = AppConfig.snippetLength(forContextSize: model.contextSize)
        let fetcher = contentFetcher
        let sources: [(index: Int, title: String, snippet: String, url: String)]
        sources = await withTaskGroup(of: (Int, String, String, String).self) { group in
            for (i, result) in results.enumerated() {
                group.addTask {
                    let snippet = await fetcher.snippet(for: result, maxLength: maxSnippet)
                    return (i + 1, result.title, snippet, result.url)
                }
            }
            var collected: [(Int, String, String, String)] = []
            for await result in group {
                collected.append(result)
            }
            return collected.sorted { $0.0 < $1.0 }
                .map { (index: $0.0, title: $0.1, snippet: $0.2, url: $0.3) }
        }

        guard !Task.isCancelled else { return }

        // 2. Build prompt and generate answer
        try await streamAnswer(
            query: query, sources: sources, searchOutput: searchOutput,
            language: language, strict: false, model: model
        )

        guard !Task.isCancelled else { return }

        // 3. Source grounding check — regenerate if answer is poorly grounded
        let groundingScore = AnswerValidator.checkSourceGrounding(
            answer: streamingText, sources: sources
        )
        if groundingScore < 0.3 && !streamingText.isEmpty {
            wasRegenerated = true
            streamingText = ""
            try await streamAnswer(
                query: query, sources: sources, searchOutput: searchOutput,
                language: language, strict: true, model: model
            )
        }
    }

    /// Stream a response from a fresh LLM session with repetition detection.
    private func streamAnswer(
        query: String,
        sources: [(index: Int, title: String, snippet: String, url: String)],
        searchOutput: SearchOutput,
        language: String,
        strict: Bool,
        model: ResolvedLanguageModel
    ) async throws {
        let systemPromptText = strict
            ? SystemPrompt.buildStrict(
                query: query, sources: sources,
                directAnswers: searchOutput.directAnswers,
                infoboxes: searchOutput.infoboxes, language: language
            )
            : SystemPrompt.build(
                query: query, sources: sources,
                directAnswers: searchOutput.directAnswers,
                infoboxes: searchOutput.infoboxes, language: language
            )

        let session = model.makeSession(instructions: systemPromptText)
        let stream = session.streamResponse(to: query)
        for try await partial in stream {
            guard !Task.isCancelled else { break }
            streamingText = partial.content

            if let trimmed = AnswerValidator.detectAndTrimRepetition(streamingText) {
                streamingText = trimmed
                break
            }
        }
    }
}
