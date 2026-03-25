import Foundation

struct SourceInfo: Codable, Hashable, Sendable {
    let url: String
    let title: String
    let engine: String?
    let wasUsed: Bool

    init(url: String, title: String, engine: String?, wasUsed: Bool = true) {
        self.url = url
        self.title = title
        self.engine = engine
        self.wasUsed = wasUsed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        title = try container.decode(String.self, forKey: .title)
        engine = try container.decodeIfPresent(String.self, forKey: .engine)
        wasUsed = try container.decodeIfPresent(Bool.self, forKey: .wasUsed) ?? true
    }
}
