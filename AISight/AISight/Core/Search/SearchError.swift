import Foundation

enum SearchError: LocalizedError {
    case serverUnavailable
    case authenticationFailed
    case timeout
    case invalidResponse
    case noResults

    var errorDescription: String? {
        switch self {
        case .serverUnavailable:
            return String(localized: "The search service is unavailable. Check your settings.")
        case .authenticationFailed:
            return String(localized: "Invalid API key. Update it in Settings.")
        case .timeout:
            return String(localized: "The search request timed out. Please try again.")
        case .invalidResponse:
            return String(localized: "Received an invalid response from the search server.")
        case .noResults:
            return String(localized: "No results were found for your query. Try rephrasing your search.")
        }
    }
}
