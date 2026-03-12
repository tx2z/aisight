import Foundation
import Observation
import SwiftData

#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Observable
final class SearchViewModel {

    var query: String = ""
    var sources: [SearXNGResult] = []
    var errorMessage: String?

    private(set) var answerSession: AnswerSession

    private let searchService: SearXNGService
    private var currentTask: Task<Void, Never>?

    /// Convenience accessors forwarded from AnswerSession.
    var streamingText: String { answerSession.streamingText }
    var isGenerating: Bool { answerSession.isGenerating }

    var isSearching: Bool = false

    init(searchService: SearXNGService = SearXNGService()) {
        self.searchService = searchService
        self.answerSession = AnswerSession()
    }

    var language: String {
        UserDefaults.standard.string(forKey: "search_language") ?? AppConfig.defaultSearchLanguage
    }

    // MARK: - Search

    func performSearch(modelContext: ModelContext) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        currentTask?.cancel()
        currentTask = Task {
            isSearching = true
            sources = []
            errorMessage = nil

            // 1. Fetch sources for display
            var searchOutput: SearchOutput
            do {
                searchOutput = try await searchService.search(query: trimmedQuery, language: language)
                guard !Task.isCancelled else { return }
                self.sources = searchOutput.results
                self.isSearching = false
            } catch let error as SearchError {
                guard !Task.isCancelled else { return }
                isSearching = false
                errorMessage = userFacingMessage(for: error)
                return
            } catch let error as URLError where error.code == .notConnectedToInternet {
                guard !Task.isCancelled else { return }
                isSearching = false
                errorMessage = "Connect to the internet to search. Previously answered questions are available in History."
                return
            } catch {
                guard !Task.isCancelled else { return }
                isSearching = false
                errorMessage = "Search server is unavailable. Check your connection or update the server URL in Settings."
                return
            }

            guard !Task.isCancelled else { return }

            // 2. Generate answer via AnswerSession with pre-fetched results
            await answerSession.generateAnswer(for: trimmedQuery, with: searchOutput)

            guard !Task.isCancelled else { return }

            // 3. Map AnswerSession errors to user-facing messages
            if let answerError = answerSession.error {
                errorMessage = userFacingMessage(for: answerError)
            }

            if answerSession.error == nil && answerSession.streamingText.isEmpty {
                errorMessage = "The model returned an empty response. Try rephrasing your question."
            }

            // 4. Save to history on success
            if answerSession.error == nil && !answerSession.streamingText.isEmpty {
                let sourceInfos = sources.map { SourceInfo(url: $0.url, title: $0.title, engine: $0.engine) }
                let store = QueryHistoryStore(modelContext: modelContext)
                store.save(query: trimmedQuery, answer: answerSession.streamingText, sources: sourceInfos)
            }
        }
    }

    // MARK: - Error Mapping

    private func userFacingMessage(for error: SearchError) -> String {
        switch error {
        case .serverUnavailable:
            return "Search server is unavailable. Check your connection or update the server URL in Settings."
        case .timeout:
            return "Search took too long. The server may be overloaded \u{2014} try again in a moment."
        case .noResults:
            return "No sources found for this query. Try rephrasing."
        case .invalidResponse:
            return "Search server is unavailable. Check your connection or update the server URL in Settings."
        }
    }

    private func userFacingMessage(for error: AnswerError) -> String {
        switch error {
        case .searchFailed(let searchError):
            return userFacingMessage(for: searchError)
        case .generationFailed(let message):
            return "An error occurred while generating the answer: \(message)"
        case .modelUnavailable:
            return "AISight requires Apple Intelligence. Enable it in Settings \u{2192} Apple Intelligence & Siri."
        case .contentPolicy:
            return "This query can't be answered on-device. Try a different question."
        }
    }
}
