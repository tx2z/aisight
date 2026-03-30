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
    var queryGroups: [SearchQueryGroup] = []
    var errorMessage: String?

    private(set) var answerSession: AnswerSession
    private(set) var deepSearchPipeline: DeepSearchPipeline

    private let searchService: SearXNGService
    private let reformulator: QueryReformulator
    private var currentTask: Task<Void, Never>?
    private var lastSearchOutput: SearchOutput?

    /// Convenience accessors forwarded from the active pipeline.
    var streamingText: String {
        isDeepSearch ? deepSearchPipeline.streamingText : answerSession.streamingText
    }
    var isGenerating: Bool {
        isDeepSearch ? deepSearchPipeline.isGenerating : answerSession.isGenerating
    }

    var isSearching: Bool = false

    var isDeepSearch: Bool = false
    var usedSourceURLs: Set<String> = []

    /// Whether the last answer was auto-regenerated due to a failed grounding check.
    var wasRegenerated: Bool {
        isDeepSearch ? deepSearchPipeline.wasRegenerated : answerSession.wasRegenerated
    }

    /// Whether a regeneration (same sources, new LLM pass) is possible.
    var canRegenerate: Bool {
        lastSearchOutput != nil && !isGenerating && !isSearching
    }

    /// Current deep search step description, nil when not in deep search or idle.
    var searchStepDescription: String? {
        guard isDeepSearch else { return nil }
        let step = deepSearchPipeline.currentStep
        guard step != .idle else { return nil }
        return step.description
    }

    init(searchService: SearXNGService = SearXNGService()) {
        self.searchService = searchService
        self.answerSession = AnswerSession()
        self.deepSearchPipeline = DeepSearchPipeline()
        self.reformulator = QueryReformulator()
    }

    var language: String {
        UserDefaults.standard.string(forKey: "search_language") ?? AppConfig.defaultSearchLanguage
    }

    // MARK: - Search

    func performSearch(modelContext: ModelContext) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        currentTask?.cancel()

        if isDeepSearch {
            performDeepSearch(trimmedQuery: trimmedQuery, modelContext: modelContext)
        } else {
            performNormalSearch(trimmedQuery: trimmedQuery, modelContext: modelContext)
        }
    }

    private func performDeepSearch(trimmedQuery: String, modelContext: ModelContext) {
        currentTask = Task {
            isSearching = true
            sources = []
            queryGroups = []
            errorMessage = nil
            deepSearchPipeline.reset()

            let searchOutput = await deepSearchPipeline.execute(
                query: trimmedQuery,
                language: language,
                searchService: searchService
            )

            guard !Task.isCancelled else { return }

            isSearching = false

            if let searchOutput {
                self.sources = searchOutput.results
                self.queryGroups = searchOutput.queryGroups
                self.lastSearchOutput = searchOutput
            }

            if let pipelineError = deepSearchPipeline.error {
                errorMessage = userFacingMessage(for: pipelineError)
            }

            if deepSearchPipeline.error == nil && deepSearchPipeline.streamingText.isEmpty {
                errorMessage = String(localized: "The model returned an empty response. Try rephrasing your question.")
            }

            // Track which sources were used by the researchers
            if let searchOutput {
                let groupsResearched = searchOutput.queryGroups.prefix(AppConfig.deepSearchResearcherCount)
                self.usedSourceURLs = Set(groupsResearched.flatMap { $0.results.prefix(AppConfig.maxResults) }.map(\.url))
            }

            // Save to history on success
            if deepSearchPipeline.error == nil && !deepSearchPipeline.streamingText.isEmpty {
                saveToHistory(query: trimmedQuery, answer: deepSearchPipeline.streamingText, modelContext: modelContext, isDeepSearch: true)
            }
        }
    }

    private func performNormalSearch(trimmedQuery: String, modelContext: ModelContext) {
        currentTask = Task {
            isSearching = true
            sources = []
            queryGroups = []
            errorMessage = nil

            // 1. Reformulate query into optimized search keywords (fresh LLM session)
            let searchQueries = await reformulator.reformulate(trimmedQuery, language: language)

            guard !Task.isCancelled else { return }

            // 2. Search with all reformulated queries in parallel, merge results
            var searchOutput: SearchOutput
            do {
                searchOutput = try await searchService.multiSearch(queries: searchQueries, language: language)
                guard !Task.isCancelled else { return }
                self.sources = searchOutput.results
                self.queryGroups = searchOutput.queryGroups
                self.lastSearchOutput = searchOutput
                self.isSearching = false
            } catch let error as SearchError {
                guard !Task.isCancelled else { return }
                isSearching = false
                errorMessage = userFacingMessage(for: error)
                return
            } catch let error as URLError where error.code == .notConnectedToInternet {
                guard !Task.isCancelled else { return }
                isSearching = false
                errorMessage = String(localized: "Connect to the internet to search. Previously answered questions are available in History.")
                return
            } catch {
                guard !Task.isCancelled else { return }
                isSearching = false
                errorMessage = String(localized: "Search server is unavailable. Check your connection or update the server URL in Settings.")
                return
            }

            guard !Task.isCancelled else { return }

            // Track which sources the AI actually uses
            self.usedSourceURLs = Set(searchOutput.results.prefix(AppConfig.maxResults).map(\.url))

            // 3. Generate answer via AnswerSession with pre-fetched results
            await answerSession.generateAnswer(for: trimmedQuery, with: searchOutput, language: language)

            guard !Task.isCancelled else { return }

            // 4. Map AnswerSession errors to user-facing messages
            if let answerError = answerSession.error {
                errorMessage = userFacingMessage(for: answerError)
            }

            if answerSession.error == nil && answerSession.streamingText.isEmpty {
                errorMessage = String(localized: "The model returned an empty response. Try rephrasing your question.")
            }

            // 5. Save to history on success
            if answerSession.error == nil && !answerSession.streamingText.isEmpty {
                saveToHistory(query: trimmedQuery, answer: answerSession.streamingText, modelContext: modelContext)
            }
        }
    }

    // MARK: - History

    private func saveToHistory(query: String, answer: String, modelContext: ModelContext, isDeepSearch: Bool = false) {
        let allSources = queryGroups.flatMap(\.results)
        let sourceInfos = allSources.map {
            SourceInfo(url: $0.url, title: $0.title, engine: $0.engine, wasUsed: self.usedSourceURLs.contains($0.url))
        }
        let store = QueryHistoryStore(modelContext: modelContext)
        store.save(query: query, answer: answer, sources: sourceInfos, isDeepSearch: isDeepSearch)
    }

    // MARK: - Regenerate (same sources, new LLM pass)

    func regenerateAnswer(modelContext: ModelContext) {
        guard let searchOutput = lastSearchOutput else { return }
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        currentTask?.cancel()
        currentTask = Task {
            answerSession.reset()
            errorMessage = nil

            await answerSession.generateAnswer(for: trimmedQuery, with: searchOutput, language: language)

            guard !Task.isCancelled else { return }

            if let answerError = answerSession.error {
                errorMessage = userFacingMessage(for: answerError)
            }

            if answerSession.error == nil && answerSession.streamingText.isEmpty {
                errorMessage = String(localized: "The model returned an empty response. Try rephrasing your question.")
            }

            // Update history with new answer
            if answerSession.error == nil && !answerSession.streamingText.isEmpty {
                saveToHistory(query: trimmedQuery, answer: answerSession.streamingText, modelContext: modelContext)
            }
        }
    }

    // MARK: - Reset

    func resetSearch() {
        currentTask?.cancel()
        currentTask = nil
        query = ""
        sources = []
        queryGroups = []
        errorMessage = nil
        isSearching = false
        usedSourceURLs = []
        lastSearchOutput = nil
        answerSession.reset()
        deepSearchPipeline.reset()
    }

    // MARK: - Error Mapping

    private func userFacingMessage(for error: SearchError) -> String {
        switch error {
        case .serverUnavailable:
            return String(localized: "Search server is unavailable. Check your connection or update the server URL in Settings.")
        case .timeout:
            return String(localized: "Search took too long. The server may be overloaded \u{2014} try again in a moment.")
        case .noResults:
            return String(localized: "No sources found for this query. Try rephrasing.")
        case .invalidResponse:
            return String(localized: "Search server is unavailable. Check your connection or update the server URL in Settings.")
        }
    }

    private func userFacingMessage(for error: AnswerError) -> String {
        switch error {
        case .searchFailed(let searchError):
            return userFacingMessage(for: searchError)
        case .generationFailed(let message):
            return String(localized: "An error occurred while generating the answer: \(message)")
        case .modelUnavailable:
            return String(localized: "AISight requires Apple Intelligence. Enable it in Settings \u{2192} Apple Intelligence & Siri.")
        case .contentPolicy:
            return String(localized: "This query can't be answered on-device. Try a different question.")
        }
    }
}
