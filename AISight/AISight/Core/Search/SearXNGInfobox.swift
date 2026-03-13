import Foundation

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
