import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Observable
class DeepSearchPipeline {
    var streamingText: String = ""
    var isGenerating: Bool = false
    var currentStep: DeepSearchStep = .idle
    var error: AnswerError? = nil

    enum DeepSearchStep: Equatable {
        case idle
        case reformulating
        case searching
        case researching(current: Int, total: Int)
        case synthesizing

        var description: String {
            switch self {
            case .idle: return ""
            case .reformulating: return "Reformulating query..."
            case .searching: return "Searching the web..."
            case .researching(let current, let total): return "Analyzing sources (\(current)/\(total))..."
            case .synthesizing: return "Writing answer..."
            }
        }
    }

    private let contentFetcher = ContentFetcher()

    func reset() {
        streamingText = ""
        isGenerating = false
        currentStep = .idle
        error = nil
    }

    /// Execute the full deep search pipeline: reformulate → search → research → synthesize.
    /// Returns the SearchOutput for source display, or nil on failure.
    func execute(query: String, language: String, searchService: SearXNGService) async -> SearchOutput? {
        streamingText = ""
        isGenerating = true
        error = nil
        currentStep = .reformulating
        defer { isGenerating = false }

        let researcherCount = AppConfig.deepSearchResearcherCount

        // Step 1: Reformulate query
        let reformulator = QueryReformulator()
        let searchQueries = await reformulator.reformulate(query)
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

        // Step 3: Sequential researchers — one per query group
        var researcherSummaries: [String] = []
        let groupsToResearch = Array(searchOutput.queryGroups.prefix(researcherCount))

        for (index, group) in groupsToResearch.enumerated() {
            guard !Task.isCancelled else { return searchOutput }
            currentStep = .researching(current: index + 1, total: groupsToResearch.count)

            let summary = await runResearcher(
                query: query,
                searchGroup: group
            )
            if let summary {
                researcherSummaries.append(summary)
            }
        }

        guard !Task.isCancelled else { return searchOutput }

        // If all researchers failed, fall back — the caller can use normal mode
        if researcherSummaries.isEmpty {
            self.error = .generationFailed("Deep search analysis failed. Try again or disable Deep Search.")
            return searchOutput
        }

        // Step 4: Synthesize final answer (streamed)
        currentStep = .synthesizing
        await runSynthesizer(
            query: query,
            summaries: researcherSummaries,
            sources: searchOutput.results
        )

        return searchOutput
    }

    // MARK: - Researcher

    private func runResearcher(query: String, searchGroup: SearchQueryGroup) async -> String? {
        let dateString = QueryReformulator.currentDateString()

        // Build source text for this group
        var sourcesText = ""
        for (i, result) in searchGroup.results.prefix(AppConfig.maxResults).enumerated() {
            var snippet = result.content ?? ""
            if await contentFetcher.shouldFetchFullContent(snippet: snippet) {
                if let fullContent = try? await contentFetcher.fetchContent(from: result.url) {
                    snippet = fullContent
                }
            }
            if snippet.count > AppConfig.maxSnippetLength {
                snippet = String(snippet.prefix(AppConfig.maxSnippetLength))
            }
            let domain = URL(string: result.url).flatMap { $0.host() }?
                .replacingOccurrences(of: "www.", with: "") ?? result.url
            sourcesText += """
            \(result.title) (\(domain))
            \(snippet)

            """
        }

        let instructions = """
        You are a research analyst. Read these search results and write a detailed \
        summary of everything relevant to the user's question. Today is \(dateString).

        Rules:
        - Extract ALL relevant information from the sources — be thorough, not minimal
        - Include specific facts, numbers, names, dates, statistics, approval ratings, \
        rankings, quotes, and any other concrete details
        - Connect information across sources to build a complete picture
        - When citing a source, write (via domain.com) using just the domain name
        - Write 2-4 detailed paragraphs
        - Always find something useful in the sources — they were selected for relevance
        """

        let prompt = """
        User's question: \(query)

        Search query used: \(searchGroup.query)

        Sources:
        \(sourcesText)
        """

        do {
            let session = LanguageModelSession(instructions: instructions)
            let response = try await session.respond(to: prompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? nil : text
        } catch {
            return nil
        }
    }

    // MARK: - Synthesizer

    private func runSynthesizer(query: String, summaries: [String], sources: [SearXNGResult]) async {
        let dateString = QueryReformulator.currentDateString()

        // Build source list
        var sourceList = ""
        for source in sources.prefix(AppConfig.maxResults) {
            let domain = URL(string: source.url).flatMap { $0.host() }?
                .replacingOccurrences(of: "www.", with: "") ?? source.url
            sourceList += "- \(source.title) (\(domain))\n"
        }

        // Build research findings
        var findings = ""
        for (i, summary) in summaries.enumerated() {
            findings += "### Researcher \(i + 1)\n\(summary)\n\n"
        }

        let instructions = """
        You are AISight — a private, on-device answer engine. Today is \(dateString).
        Below are research findings from multiple analysts who examined different \
        aspects of the user's question, along with the original sources they referenced.

        Write a comprehensive, detailed answer that covers the question thoroughly.

        ## Rules
        - Be detailed and thorough — the user chose Deep Search because they want depth
        - Use **bold** for key terms and bullet lists when comparing or listing items
        - When using information from a source, attribute it inline like (via nytimes.com) \
        or (via wikipedia.org) using just the domain name
        - Combine and connect findings from all researchers into a coherent narrative
        - Include all specific facts, numbers, statistics, and details from the research
        - If researchers found different or conflicting information, present all viewpoints
        - Write 3-5 paragraphs minimum — this is a deep research answer, not a quick summary
        - Write in clear, accessible language

        ## Research Findings
        \(findings)
        ## Sources
        \(sourceList)
        """

        do {
            let session = LanguageModelSession(instructions: instructions)
            let stream = session.streamResponse(to: query)
            for try await partial in stream {
                guard !Task.isCancelled else { break }
                streamingText = partial.content
            }
        } catch let genError as LanguageModelSession.GenerationError {
            switch genError {
            case .guardrailViolation, .refusal:
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
