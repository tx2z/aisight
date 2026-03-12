import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Observable
class AnswerSession {
    var streamingText: String = ""
    var isGenerating: Bool = false
    private(set) var error: AnswerError? = nil

    private let contentFetcher: ContentFetcher

    init(contentFetcher: ContentFetcher = ContentFetcher()) {
        self.contentFetcher = contentFetcher
    }

    static func checkAvailability() -> Bool {
        return SystemLanguageModel.default.availability == .available
    }

    func reset() {
        streamingText = ""
        isGenerating = false
        error = nil
    }

    static var availabilityStatus: SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    func generateAnswer(for query: String, with searchOutput: SearchOutput) async {
        streamingText = ""
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            // 1. Optionally fetch full content for short snippets
            var sources: [(index: Int, title: String, snippet: String, url: String)] = []
            for (i, result) in searchOutput.results.prefix(AppConfig.maxResults).enumerated() {
                var snippet = result.content ?? ""
                if await contentFetcher.shouldFetchFullContent(snippet: snippet) {
                    if let fullContent = try? await contentFetcher.fetchContent(from: result.url) {
                        snippet = fullContent
                    }
                }
                if snippet.count > AppConfig.maxSnippetLength {
                    snippet = String(snippet.prefix(AppConfig.maxSnippetLength))
                }
                sources.append((
                    index: i + 1,
                    title: result.title,
                    snippet: snippet,
                    url: result.url
                ))
            }

            guard !Task.isCancelled else { return }

            // 2. Build prompt and create session
            let systemPromptText = SystemPrompt.build(
                query: query,
                sources: sources,
                directAnswers: searchOutput.directAnswers,
                infoboxes: searchOutput.infoboxes
            )
            let session = LanguageModelSession(
                instructions: systemPromptText
            )

            // 3. Stream response
            let stream = session.streamResponse(to: query)
            for try await partial in stream {
                guard !Task.isCancelled else { break }
                streamingText = partial.content
            }

            guard !Task.isCancelled else { return }

        } catch let genError as LanguageModelSession.GenerationError {
            switch genError {
            case .guardrailViolation:
                self.error = .contentPolicy
            case .exceededContextWindowSize:
                self.error = .generationFailed("The query is too long for the on-device model.")
            case .unsupportedLanguageOrLocale:
                self.error = .generationFailed("This language is not supported by the on-device model.")
            case .rateLimited:
                self.error = .generationFailed("The on-device model is rate limited. Please try again shortly.")
            case .assetsUnavailable:
                self.error = .modelUnavailable
            case .concurrentRequests:
                self.error = .generationFailed("Another request is in progress. Please wait.")
            case .refusal:
                self.error = .contentPolicy
            case .unsupportedGuide:
                self.error = .generationFailed("Unsupported generation configuration.")
            case .decodingFailure:
                self.error = .generationFailed("Failed to decode the model response.")
            @unknown default:
                self.error = .generationFailed(genError.localizedDescription)
            }
        } catch {
            self.error = .generationFailed(error.localizedDescription)
        }
    }
}

enum AnswerError: Error, LocalizedError {
    case searchFailed(SearchError)
    case generationFailed(String)
    case modelUnavailable
    case contentPolicy

    var errorDescription: String? {
        switch self {
        case .searchFailed(let searchError):
            return "Search failed: \(searchError.localizedDescription)"
        case .generationFailed(let message):
            return "Failed to generate answer: \(message)"
        case .modelUnavailable:
            return "The on-device language model is not available on this device."
        case .contentPolicy:
            return "The request was blocked due to content policy restrictions."
        }
    }
}
