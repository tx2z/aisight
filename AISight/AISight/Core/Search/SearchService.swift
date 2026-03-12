import Foundation

/// Aggregated output from a search, including direct answers and metadata.
struct SearchOutput: Sendable {
    let results: [SearXNGResult]
    let directAnswers: [String]
    let suggestions: [String]
    let infoboxes: [SearXNGInfobox]
}

protocol SearchService: Sendable {
    func search(query: String, language: String) async throws -> SearchOutput
    func checkAvailability() async -> Bool
}
