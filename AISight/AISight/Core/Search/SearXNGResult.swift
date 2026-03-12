import Foundation

struct SearXNGResult: Codable, Identifiable, Sendable {
    let url: String
    let title: String
    let content: String?
    let engine: String?
    let score: Double?
    let engines: [String]?
    let positions: [Int]?
    let category: String?
    let publishedDate: String?

    var id: String { "\(url)_\(engine ?? "")" }

    /// How many different engines returned this URL
    var engineCount: Int { engines?.count ?? 1 }

    /// Snippet length, 0 if nil/empty
    var snippetLength: Int { (content ?? "").count }

    /// Whether the snippet has enough content to be useful without full page fetch
    var hasUsableSnippet: Bool { snippetLength >= AppConfig.snippetThreshold }

    /// Domain extracted from URL
    var domain: String? {
        URL(string: url).flatMap { $0.host() }?
            .replacingOccurrences(of: "www.", with: "")
    }
}

struct SearXNGResponse: Codable, Sendable {
    let query: String?
    let results: [SearXNGResult]
    let numberOfResults: Int?
    let answers: [String]?
    let suggestions: [String]?
    let infoboxes: [SearXNGInfobox]?
    let unresponsiveEngines: [[String]]?

    enum CodingKeys: String, CodingKey {
        case query, results, answers, suggestions, infoboxes
        case numberOfResults = "number_of_results"
        case unresponsiveEngines = "unresponsive_engines"
    }
}

struct SearXNGInfobox: Codable, Sendable {
    let infobox: String?
    let content: String?
    let urls: [SearXNGInfoboxURL]?

    enum CodingKeys: String, CodingKey {
        case infobox, content, urls
    }
}

struct SearXNGInfoboxURL: Codable, Sendable {
    let title: String?
    let url: String?
}
