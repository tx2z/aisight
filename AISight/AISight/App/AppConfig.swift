import Foundation

enum AppConfig: Sendable {
    // TODO: Replace with your SearXNG instance URL before shipping
    // For local dev: docker-compose up in /searxng folder → http://localhost:8888
    static let defaultSearXNGBaseURL = "http://localhost:8888"

    static var effectiveSearXNGBaseURL: String {
        UserDefaults.standard.string(forKey: "searxng_base_url") ?? defaultSearXNGBaseURL
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

    // RRF ranking constant (standard value from Cormack, Clarke, Butt paper)
    static let rrfK: Double = 60

    // URL tracking parameters to strip during deduplication
    static let trackingParams: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "ref", "fbclid", "gclid", "msclkid", "mc_cid", "mc_eid",
    ]
}
