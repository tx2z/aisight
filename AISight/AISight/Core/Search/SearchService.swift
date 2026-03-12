import Foundation

/// A single search query and its results, for display grouping.
struct SearchQueryGroup: Sendable, Identifiable {
    let id = UUID()
    let query: String
    let results: [SearXNGResult]
}

/// Aggregated output from a search, including direct answers and metadata.
struct SearchOutput: Sendable {
    let results: [SearXNGResult]
    let queryGroups: [SearchQueryGroup]
    let directAnswers: [String]
    let suggestions: [String]
    let infoboxes: [SearXNGInfobox]
}

protocol SearchService: Sendable {
    func search(query: String, language: String) async throws -> SearchOutput
    func checkAvailability() async -> Bool
}
