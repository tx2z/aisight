import Foundation

enum AppConfig: Sendable {
    // Default SearXNG instance — override in Settings or set your own
    // For local dev: docker-compose up in /searxng folder → http://localhost:8888
    static let defaultSearXNGBaseURL = "https://search.private-search-intelligence.app"

    static var effectiveSearXNGBaseURL: String {
        guard let stored = UserDefaults.standard.string(forKey: "searxng_base_url"),
              let url = URL(string: stored),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            return defaultSearXNGBaseURL
        }
        return stored
    }

    // SearXNG search parameters
    static let searchEngines = "google,bing,brave"
    static let searchCategories = "general"
    static let maxResults = 5
    static let defaultSearchLanguage = "en"
    static let searchTimeoutSeconds: TimeInterval = 10
    static let maxSnippetLength = 1600 // ~400 tokens
    static let snippetThreshold = 150 // chars; skip full fetch if snippet > this
    static let minSnippetLength = 30 // discard results with shorter snippets

    // Deep Search
    static let deepSearchResearcherCount = 3

    // RRF ranking constant (standard value from Cormack, Clarke, Butt paper)
    static let rrfK: Double = 60

    // URL tracking parameters to strip during deduplication
    static let trackingParams: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "ref", "fbclid", "gclid", "msclkid", "mc_cid", "mc_eid",
    ]
}
