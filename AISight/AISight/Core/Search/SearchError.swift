import Foundation

enum SearchError: LocalizedError {
    case serverUnavailable
    case timeout
    case invalidResponse
    case noResults

    var errorDescription: String? {
        switch self {
        case .serverUnavailable:
            return "The search server is currently unavailable. Please check your SearXNG instance URL in Settings."
        case .timeout:
            return "The search request timed out. Please try again."
        case .invalidResponse:
            return "Received an invalid response from the search server."
        case .noResults:
            return "No results were found for your query. Try rephrasing your search."
        }
    }
}
