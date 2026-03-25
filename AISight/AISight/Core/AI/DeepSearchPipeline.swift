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
        let searchQueries = await reformulator.reformulate(query, language: language)
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
            self.error = .generationFailed(String(localized: "Deep search analysis failed. Try again or disable Deep Search."))
            return searchOutput
        }

        // Step 4: Synthesize final answer (streamed)
        currentStep = .synthesizing
        await runSynthesizer(
            query: query,
            summaries: researcherSummaries,
            sources: searchOutput.results,
            language: language
        )

        return searchOutput
    }

    // MARK: - Researcher

    private func runResearcher(query: String, searchGroup: SearchQueryGroup) async -> String? {
        let dateString = QueryReformulator.currentDateString()

        // Build source text for this group
        var sourcesText = ""
        for result in searchGroup.results.prefix(AppConfig.maxResults) {
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
                .replacing("www.", with: "") ?? result.url
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

    private func runSynthesizer(query: String, summaries: [String], sources: [SearXNGResult], language: String) async {
        let dateString = QueryReformulator.currentDateString()

        // Build source list
        var sourceList = ""
        for source in sources.prefix(AppConfig.maxResults) {
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
        \(Self.languageInstruction(for: language))
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
            self.error = generationErrorToAnswerError(genError)
        } catch {
            self.error = .generationFailed(error.localizedDescription)
        }
    }

    private static let languageNames: [String: String] = [
        "en": "English", "de": "German", "fr": "French", "es": "Spanish",
        "it": "Italian", "ja": "Japanese", "ko": "Korean", "zh": "Chinese",
        "pt": "Portuguese"
    ]

    private static func languageInstruction(for code: String) -> String {
        guard code != "en", let name = languageNames[code] else { return "" }
        return "- IMPORTANT: Respond entirely in \(name). The user's language is \(name)."
    }
}
