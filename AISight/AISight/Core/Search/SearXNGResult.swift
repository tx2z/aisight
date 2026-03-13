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
            .replacing("www.", with: "")
    }
}
