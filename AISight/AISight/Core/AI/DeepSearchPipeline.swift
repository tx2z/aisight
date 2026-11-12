import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Observable
final class DeepSearchPipeline {
    var streamingText: String = ""
    var isGenerating: Bool = false
    var currentStep: DeepSearchStep = .idle
    var error: AnswerError? = nil
    private(set) var wasRegenerated: Bool = false
    private(set) var usedModel = ResolvedLanguageModel.placeholder

    enum DeepSearchStep: Equatable {
        case idle
        case reformulating
        case searching
        case researching(current: Int, total: Int)
        case synthesizing

        var description: String {
            switch self {
            case .idle: return ""
            case .reformulating: return String(localized: "Reformulating query...")
            case .searching: return String(localized: "Searching the web...")
            case .researching(let current, let total): return String(localized: "Analyzing sources (\(current)/\(total))...")
            case .synthesizing: return String(localized: "Writing answer...")
            }
        }
    }

    private let contentFetcher = ContentFetcher()
    private var lastResearcherError: AnswerError?

    func reset() {
        streamingText = ""
        isGenerating = false
        currentStep = .idle
        error = nil
        wasRegenerated = false
        usedModel = .placeholder
    }

    /// Execute the full deep search pipeline: reformulate → search → research → synthesize.
    /// Returns the SearchOutput for source display, or nil on failure.
    func execute(query: String, detectedLanguage: String?, language: String, searchService: SearXNGService, canUseCloudModel: Bool) async -> SearchOutput? {
        streamingText = ""
        isGenerating = true
        error = nil
        currentStep = .reformulating
        defer { isGenerating = false }

        lastResearcherError = nil
        let model = await LanguageModelProvider.resolve(canUseCloudModel: canUseCloudModel)
        usedModel = model

        // Step 1: Reformulate query
        let reformulator = QueryReformulator()
        let searchQueries = await reformulator.reformulate(query, languageCode: detectedLanguage)
        guard !Task.isCancelled else { return nil }

        // Step 2: Parallel search
        currentStep = .searching
        let searchOutput: SearchOutput
        do {
            searchOutput = try await searchService.multiSearch(queries: searchQueries, language: language)
        } catch {
            self.error = .searchFailed(error as? SearchError ?? .serverUnavailable)
            return nil
        }
        guard !Task.isCancelled else { return nil }

        // Steps 3-4 run on one model; a cloud failure re-runs them all on-device.
        do {
            try await LanguageModelProvider.runWithCloudFallback(
                model,
                onFallback: { fallback in
                    usedModel = fallback
                    streamingText = ""
                    error = nil
                    lastResearcherError = nil
                },
                work: { model in
                    try await research(query: query, language: language, searchOutput: searchOutput, model: model)
                }
            )
        } catch {
            guard !Task.isCancelled else { return searchOutput }
            self.error = answerError(from: error)
        }

        return searchOutput
    }

    /// Sequential researchers (one per query group), then the streamed synthesis.
    private func research(
        query: String, language: String, searchOutput: SearchOutput, model: ResolvedLanguageModel
    ) async throws {
        var researcherSummaries: [String] = []
        let groupsToResearch = Array(searchOutput.queryGroups.prefix(AppConfig.deepSearchResearcherCount))
        let researchedSources = DeepSearchSupport.researchedSources(in: groupsToResearch)

        for (index, group) in groupsToResearch.enumerated() {
            guard !Task.isCancelled else { return }
            currentStep = .researching(current: index + 1, total: groupsToResearch.count)

            if let summary = try await runResearcher(query: query, searchGroup: group, language: language, model: model) {
                researcherSummaries.append(summary)
            }
        }

        guard !Task.isCancelled else { return }

        if researcherSummaries.isEmpty {
            self.error = lastResearcherError
                ?? .generationFailed(String(localized: "Deep Search couldn't find relevant information in the sources. Try rephrasing your question."))
            return
        }

        currentStep = .synthesizing
        try await runSynthesizer(
            query: query,
            summaries: researcherSummaries,
            sources: researchedSources,
            language: language,
            model: model
        )
    }

    // MARK: - Researcher

    private func runResearcher(query: String, searchGroup: SearchQueryGroup, language: String, model: ResolvedLanguageModel) async throws -> String? {
        let dateString = AppConfig.todayISODate()

        // Build source text for this group
        let maxSnippet = AppConfig.snippetLength(forContextSize: model.contextSize)
        var sourcesText = ""
        for result in searchGroup.results.prefix(AppConfig.maxResults) {
            let snippet = await contentFetcher.snippet(for: result, maxLength: maxSnippet)
            let domain = URL(string: result.url).flatMap { $0.host() }?
                .replacing("www.", with: "") ?? result.url
            sourcesText += """
            \(result.title) (\(domain))
            \(snippet)

            """
        }

        let instructions = """
        You are a research analyst. Read these search results and write a summary \
        of what they say that is relevant to the user's question. Today is \(dateString).

        Rules:
        - Write the summary using only the sources that help answer the user's question. \
        Never mention, describe or cite the other sources.
        - Include specific facts, numbers, names, dates and other concrete details
        - Connect information across sources to build a complete picture
        - When citing a source, always write (via domain.com) using just the domain name, \
        for example (via example.com)
        - Write at most 2 short paragraphs with only what answers the question
        - If no source helps answer the question, your entire reply must be exactly \
        \(DeepSearchSupport.noRelevantInfoMarker). Never write \(DeepSearchSupport.noRelevantInfoMarker) together with a summary.
        \(SystemPrompt.languageInstruction(for: language))
        """

        let prompt = """
        User's question: \(query)

        Search query used: \(searchGroup.query)

        Sources:
        \(sourcesText)
        """

        do {
            let session = model.makeSession(instructions: instructions)
            let response = try await session.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty || DeepSearchSupport.isNoRelevantInfo(text) ? nil : text
        } catch {
            if model.kind == .appleCloud && LanguageModelProvider.isCloudFallbackError(error) { throw error }
            guard !Task.isCancelled else { return nil }
            lastResearcherError = answerError(from: error)
            return nil
        }
    }

    // MARK: - Synthesizer

    private func runSynthesizer(query: String, summaries: [String], sources: [SearXNGResult], language: String, model: ResolvedLanguageModel) async throws {
        let dateString = AppConfig.todayISODate()

        // Build source list
        var sourceList = ""
        for source in sources {
            let domain = URL(string: source.url).flatMap { $0.host() }?
                .replacing("www.", with: "") ?? source.url
            sourceList += "- \(source.title) (\(domain))\n"
        }

        // Build research findings
        var findings = ""
        for (i, summary) in summaries.enumerated() {
            findings += "### Researcher \(i + 1)\n\(summary)\n\n"
        }

        let instructions = """
        You are AISight — a private answer engine. Today is \(dateString).
        Below are research findings from multiple analysts who examined different \
        aspects of the user's question, along with the original sources they referenced.

        Write a comprehensive answer that covers the question.

        ## Rules
        - Be as detailed as the findings support, without filler or repetition
        - Use **bold** for key terms and bullet lists when comparing or listing items
        - When using information from a source, attribute it inline like (via nytimes.com) \
        or (via wikipedia.org) using just the domain name
        - Combine and connect findings from all researchers into a coherent narrative
        - If researchers found different or conflicting information, present all viewpoints
        - Write in clear, accessible language
        \(SystemPrompt.languageInstruction(for: language))
        ## Research Findings
        \(findings)
        ## Sources
        \(sourceList)
        """

        let session = model.makeSession(instructions: instructions)
        let stream = session.streamResponse(to: query)
        for try await partial in stream {
            guard !Task.isCancelled else { break }
            streamingText = partial.content

            // Stop generation if model starts looping
            if let trimmed = AnswerValidator.detectAndTrimRepetition(streamingText) {
                streamingText = trimmed
                break
            }
        }
    }
}

/// Pure helpers for the Deep Search pipeline.
nonisolated enum DeepSearchSupport {
    static let noRelevantInfoMarker = "NO_RELEVANT_INFO"

    /// True when the response is the marker alone, ignoring case, whitespace and surrounding punctuation.
    static func isNoRelevantInfo(_ text: String) -> Bool {
        let ignored = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters).union(.symbols)
        return text.trimmingCharacters(in: ignored).caseInsensitiveCompare(noRelevantInfoMarker) == .orderedSame
    }

    /// Results the researchers read (each group capped at `AppConfig.maxResults`), deduplicated by URL in first-seen order.
    static func researchedSources(in groups: [SearchQueryGroup]) -> [SearXNGResult] {
        var seen = Set<String>()
        return groups
            .flatMap { $0.results.prefix(AppConfig.maxResults) }
            .filter { seen.insert($0.url).inserted }
    }
}
