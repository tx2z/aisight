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
            ErrorCopy.modelUnavailable
        case .contentPolicy:
            ErrorCopy.contentBlocked
        }
    }
}

/// User-facing error messages shared by every model's error mapping.
nonisolated enum ErrorCopy {
    static var modelUnavailable: String { String(localized: "The language model is not available on this device.") }
    static var contentBlocked: String { String(localized: "The request was blocked due to content policy restrictions.") }
    static var tooLong: String { String(localized: "The query is too long for the language model.") }
    static var unsupportedLanguage: String { String(localized: "This language is not supported by the language model.") }
    static var rateLimited: String { String(localized: "The language model has received too many requests. Please try again shortly.") }
    static var timeout: String { String(localized: "The language model took too long to respond. Please try again.") }
    static var unsupportedRequest: String { String(localized: "This model can't handle this request. Try another model in Settings \u{2192} AI Model.") }
    static var busy: String { String(localized: "Another request is in progress. Please wait.") }
    static var decoding: String { String(localized: "Failed to decode the model response.") }
}
