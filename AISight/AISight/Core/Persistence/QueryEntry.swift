import Foundation
import SwiftData

@Model
final class QueryEntry {
    var id: UUID
    var query: String
    var answer: String
    var sources: [SourceInfo]
    var timestamp: Date
    var isDeepSearch: Bool = false

    init(query: String, answer: String, sources: [SourceInfo], isDeepSearch: Bool = false) {
        self.id = UUID()
        self.query = query
        self.answer = answer
        self.sources = sources
        self.timestamp = Date.now
        self.isDeepSearch = isDeepSearch
    }
}
