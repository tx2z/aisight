import Foundation

enum AnswerError: Error, LocalizedError {
    case searchFailed(SearchError)
    case generationFailed(String)
    case modelUnavailable
    case contentPolicy

    var errorDescription: String? {
        switch self {
        case .searchFailed(let searchError):
            String(localized: "Search failed: \(searchError.localizedDescription)")
        case .generationFailed(let message):
            String(localized: "Failed to generate answer: \(message)")
        case .modelUnavailable:
            String(localized: "The on-device language model is not available on this device.")
        case .contentPolicy:
            String(localized: "The request was blocked due to content policy restrictions.")
        }
    }
}
