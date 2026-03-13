import Foundation

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
