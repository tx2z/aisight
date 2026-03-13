import Foundation

struct SourceInfo: Codable, Hashable, Sendable {
    let url: String
    let title: String
    let engine: String?
}
