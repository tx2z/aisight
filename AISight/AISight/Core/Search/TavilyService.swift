import Foundation

/// Tavily search API client conforming to SearchService.
/// Calls POST https://api.tavily.com/search via URLSession and maps
/// Tavily response fields to SearXNGResult for full pipeline compatibility.
final class TavilyService: SearchService, Sendable {

    private static let apiURL = "https://api.tavily.com/search"

    // Tavily does not support a language filter in the basic search API,
    // so the language parameter is accepted for protocol conformance but not forwarded.
    func search(query: String, language: String) async throws -> SearchOutput {
        let apiKey = AppConfig.tavilyAPIKey
        guard !apiKey.isEmpty else {
            throw SearchError.serverUnavailable
        }

        guard let url = URL(string: Self.apiURL) else {
            throw SearchError.invalidResponse
        }

        let requestBody = TavilySearchRequest(
            apiKey: apiKey,
            query: query,
            searchDepth: AppConfig.tavilySearchDepth,
            maxResults: AppConfig.tavilyMaxResults,
            includeAnswer: false
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = AppConfig.searchTimeoutSeconds

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw SearchError.invalidResponse
        }

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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SearchError.serverUnavailable
        }

        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            throw SearchError.authenticationFailed
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw SearchError.serverUnavailable
        }

        let tavilyResponse: TavilySearchResponse
        do {
            tavilyResponse = try JSONDecoder().decode(TavilySearchResponse.self, from: data)
        } catch {
            throw SearchError.invalidResponse
        }

        let results = tavilyResponse.results.map { item in
            SearXNGResult(
                url: item.url,
                title: item.title,
                content: item.content,
                engine: "tavily",
                score: item.score,
                engines: ["tavily"],
                positions: nil,
                category: nil,
                publishedDate: nil
            )
        }

        guard !results.isEmpty else {
            throw SearchError.noResults
        }

        return SearchOutput(
            results: results,
            queryGroups: [SearchQueryGroup(query: query, results: results)],
            directAnswers: [],
            suggestions: [],
            infoboxes: []
        )
    }

    func multiSearch(queries: [String], language: String) async throws -> SearchOutput {
        guard !queries.isEmpty else { throw SearchError.noResults }

        if queries.count == 1 {
            return try await search(query: queries[0], language: language)
        }

        var allResults: [SearXNGResult] = []
        var queryGroups: [SearchQueryGroup] = []

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
                }
            }
        }

        // Deduplicate by URL, keeping best score
        var bestByURL: [String: SearXNGResult] = [:]
        for result in allResults {
            let key = result.url.lowercased()
            if let existing = bestByURL[key] {
                if (result.score ?? 0) > (existing.score ?? 0) {
                    bestByURL[key] = result
                }
            } else {
                bestByURL[key] = result
            }
        }

        let merged = Array(bestByURL.values)
            .sorted { ($0.score ?? 0) > ($1.score ?? 0) }
            .prefix(AppConfig.maxResults)

        guard !merged.isEmpty else {
            throw SearchError.noResults
        }

        return SearchOutput(
            results: Array(merged),
            queryGroups: queryGroups,
            directAnswers: [],
            suggestions: [],
            infoboxes: []
        )
    }

    func checkAvailability() async -> Bool {
        let apiKey = AppConfig.tavilyAPIKey
        guard !apiKey.isEmpty, apiKey.hasPrefix("tvly-") else { return false }

        guard let url = URL(string: Self.apiURL) else { return false }

        // Intentionally uses "basic" depth and 1 result to minimize credit cost,
        // regardless of the user's configured tavilySearchDepth.
        // Note: this performs a live search and consumes 1 Tavily credit.
        let requestBody = TavilySearchRequest(
            apiKey: apiKey,
            query: "test",
            searchDepth: "basic",
            maxResults: 1,
            includeAnswer: false
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = AppConfig.searchTimeoutSeconds

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return (200...299).contains(httpResponse.statusCode)
        } catch {
            return false
        }
    }
}

// MARK: - Tavily API Models

private struct TavilySearchRequest: Encodable {
    let apiKey: String
    let query: String
    let searchDepth: String
    let maxResults: Int
    let includeAnswer: Bool

    enum CodingKeys: String, CodingKey {
        case apiKey = "api_key"
        case query
        case searchDepth = "search_depth"
        case maxResults = "max_results"
        case includeAnswer = "include_answer"
    }
}

private struct TavilySearchResponse: Decodable {
    let results: [TavilyResult]
}

private struct TavilyResult: Decodable {
    let url: String
    let title: String
    let content: String
    let score: Double?
}
