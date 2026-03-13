import Foundation

enum SearchError: LocalizedError {
    case serverUnavailable
    case timeout
    case invalidResponse
    case noResults

    var errorDescription: String? {
        switch self {
        case .serverUnavailable:
            return String(localized: "The search server is currently unavailable. Please check your SearXNG instance URL in Settings.")
        case .timeout:
            return String(localized: "The search request timed out. Please try again.")
        case .invalidResponse:
            return String(localized: "Received an invalid response from the search server.")
        case .noResults:
            return String(localized: "No results were found for your query. Try rephrasing your search.")
        }
    }
}
