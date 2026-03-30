import Foundation

final class SearXNGService: SearchService, Sendable {

    func search(query: String, language: String) async throws -> SearchOutput {
        let baseURL = AppConfig.effectiveSearXNGBaseURL
        guard var components = URLComponents(string: "\(baseURL)/search") else {
            throw SearchError.invalidResponse
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "engines", value: AppConfig.searchEngines),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "categories", value: AppConfig.searchCategories),
        ]
        guard let url = components.url else {
            throw SearchError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = AppConfig.searchTimeoutSeconds

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .timedOut {
            throw SearchError.timeout
        } catch let error as URLError where error.code == .cannotConnectToHost
            || error.code == .notConnectedToInternet
            || error.code == .cannotFindHost {
            throw SearchError.serverUnavailable
        } catch {
            throw SearchError.serverUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SearchError.serverUnavailable
        }

        let searxResponse: SearXNGResponse
        do {
            searxResponse = try JSONDecoder().decode(SearXNGResponse.self, from: data)
        } catch {
            throw SearchError.invalidResponse
        }

        let processed = processResults(searxResponse.results, query: query)

        guard !processed.isEmpty else {
            throw SearchError.noResults
        }

        return SearchOutput(
            results: processed,
            queryGroups: [SearchQueryGroup(query: query, results: processed)],
            directAnswers: searxResponse.answers ?? [],
            suggestions: searxResponse.suggestions ?? [],
            infoboxes: searxResponse.infoboxes ?? []
        )
    }

    /// Search with multiple queries in parallel, merge and deduplicate results.
    func multiSearch(queries: [String], language: String) async throws -> SearchOutput {
        guard !queries.isEmpty else { throw SearchError.noResults }

        // Single query — use standard path
        if queries.count == 1 {
            return try await search(query: queries[0], language: language)
        }

        // Run all queries in parallel, tracking results per query
        var allResults: [SearXNGResult] = []
        var queryGroups: [SearchQueryGroup] = []
        var allAnswers: [String] = []
        var allSuggestions: [String] = []
        var allInfoboxes: [SearXNGInfobox] = []

        // Use a struct to pass back both query and its output
        await withTaskGroup(of: (String, SearchOutput?).self) { group in
            for query in queries {
                group.addTask {
                    let output = try? await self.search(query: query, language: language)
                    return (query, output)
                }
            }

            for await (query, output) in group {
                if let output {
                    queryGroups.append(SearchQueryGroup(query: query, results: output.results))
                    allResults.append(contentsOf: output.results)
                    allAnswers.append(contentsOf: output.directAnswers)
                    allSuggestions.append(contentsOf: output.suggestions)
                    allInfoboxes.append(contentsOf: output.infoboxes)
                }
            }
        }

        // Deduplicate and rank the merged results for the answer session
        // Use first query (original) for relevance boosting
        let merged = processResults(allResults, query: queries.first)

        guard !merged.isEmpty else {
            throw SearchError.noResults
        }

        return SearchOutput(
            results: merged,
            queryGroups: queryGroups,
            directAnswers: Array(Set(allAnswers)),
            suggestions: Array(Set(allSuggestions)),
            infoboxes: allInfoboxes
        )
    }

    func checkAvailability() async -> Bool {
        let baseURL = AppConfig.effectiveSearXNGBaseURL
        guard var components = URLComponents(string: "\(baseURL)/search") else {
            return false
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: "test"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "engines", value: AppConfig.searchEngines),
            URLQueryItem(name: "language", value: "en"),
        ]
        guard let url = components.url else {
            return false
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = AppConfig.searchTimeoutSeconds

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return (200...299).contains(httpResponse.statusCode)
        } catch {
            return false
        }
    }

    // MARK: - Result Processing

    /// Filter, deduplicate, and rank results using Reciprocal Rank Fusion
    /// with title relevance boosting.
    func processResults(_ raw: [SearXNGResult], query: String? = nil) -> [SearXNGResult] {
        // 1. Filter out results with too-short or empty snippets
        let filtered = raw.filter { $0.snippetLength >= AppConfig.minSnippetLength }

        // 2. Build per-engine ranked lists for RRF
        //    SearXNG returns results with an `engines` array and `positions` array.
        //    We group by engine and use their original position for RRF.
        let engineRankings = buildEngineRankings(filtered)

        // 3. Deduplicate by normalized URL, merging engine data
        var bestByURL: [String: SearXNGResult] = [:]
        for result in filtered {
            let key = normalizeURL(result.url)
            if let existing = bestByURL[key] {
                // Keep whichever has the longer snippet (more content for the LLM)
                if result.snippetLength > existing.snippetLength {
                    bestByURL[key] = result
                }
            } else {
                bestByURL[key] = result
            }
        }

        // 4. Compute RRF scores with title relevance boost
        let k = AppConfig.rrfK
        let queryTerms = query.map { tokenize($0) } ?? []
        var scored: [(result: SearXNGResult, rrfScore: Double)] = []
        for (normalizedURL, result) in bestByURL {
            var rrfScore: Double = 0
            for (_, rankedURLs) in engineRankings {
                if let rank = rankedURLs[normalizedURL] {
                    rrfScore += 1.0 / (k + Double(rank))
                }
            }
            // Boost results whose title closely matches query terms
            if !queryTerms.isEmpty {
                let titleTerms = tokenize(result.title)
                let overlap = queryTerms.filter { titleTerms.contains($0) }
                let relevance = Double(overlap.count) / Double(queryTerms.count)
                // Up to 50% boost for perfect title match
                rrfScore *= (1.0 + relevance * 0.5)
            }
            scored.append((result, rrfScore))
        }

        scored.sort { $0.rrfScore > $1.rrfScore }
        return scored.prefix(AppConfig.maxResults).map(\.result)
    }

    /// Build a dictionary of [engine: [normalizedURL: rank]] from the result set.
    /// Each engine's results are sorted by their SearXNG score to determine rank.
    func buildEngineRankings(_ results: [SearXNGResult]) -> [String: [String: Int]] {
        // Group results by engine
        var byEngine: [String: [(url: String, score: Double)]] = [:]
        for result in results {
            let engines = result.engines ?? [result.engine].compactMap { $0 }
            let normalizedURL = normalizeURL(result.url)
            for engine in engines {
                byEngine[engine, default: []].append((normalizedURL, result.score ?? 0))
            }
        }

        // Sort each engine's results by score descending → position = rank
        var rankings: [String: [String: Int]] = [:]
        for (engine, entries) in byEngine {
            // Deduplicate URLs within an engine (keep best score)
            var bestScore: [String: Double] = [:]
            for entry in entries {
                bestScore[entry.url] = max(bestScore[entry.url] ?? 0, entry.score)
            }
            let sorted = bestScore.sorted { $0.value > $1.value }
            var rankMap: [String: Int] = [:]
            for (rank, entry) in sorted.enumerated() {
                rankMap[entry.key] = rank + 1
            }
            rankings[engine] = rankMap
        }

        return rankings
    }

    /// Tokenize text into lowercase words for relevance matching.
    func tokenize(_ text: String) -> Set<String> {
        Set(
            text.lowercased()
                .components(separatedBy: .alphanumerics.inverted)
                .filter { $0.count >= 3 }
        )
    }

    /// Normalize URL for deduplication — strip scheme, www, trailing slash, tracking params.
    func normalizeURL(_ urlString: String) -> String {
        guard var components = URLComponents(string: urlString.lowercased()) else {
            return urlString.lowercased()
        }
        // Strip tracking query params
        if let queryItems = components.queryItems {
            let cleaned = queryItems.filter { !AppConfig.trackingParams.contains($0.name.lowercased()) }
            components.queryItems = cleaned.isEmpty ? nil : cleaned
        }
        // Remove fragment
        components.fragment = nil

        var result = components.host ?? ""
        // Strip www.
        if result.hasPrefix("www.") { result = String(result.dropFirst(4)) }
        // Append path
        let path = components.path
        result += path
        // Strip trailing slash
        if result.hasSuffix("/") { result = String(result.dropLast()) }
        // Append remaining query
        if let query = components.query, !query.isEmpty {
            result += "?\(query)"
        }
        return result
    }
}
