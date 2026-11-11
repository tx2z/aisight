import Foundation

nonisolated enum AppConfig: Sendable {
    // Default SearXNG instance — override in Settings or set your own
    // For local dev: docker-compose up in /searxng folder → http://localhost:8888
    static let defaultSearXNGBaseURL = "https://search.private-search-intelligence.app"

    static var effectiveSearXNGBaseURL: String {
        guard let stored = UserDefaults.standard.string(forKey: "searxng_base_url"),
              HTTPURL.parse(stored) != nil else {
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
    static let baselineContextSize = 4096 // tokens; context size the base snippet length is tuned for
    static let baseSnippetLength = 1200 // chars per source at the baseline context size
    static let maxScaledSnippetLength = 8000 // upper cap for large context models
    static let snippetThreshold = 150 // chars; skip full fetch if snippet > this
    static let minSnippetLength = 30 // discard results with shorter snippets

    /// Per-source snippet length in characters, scaled linearly from `baseSnippetLength`
    /// at `baselineContextSize` and clamped to `baseSnippetLength...maxScaledSnippetLength`.
    static func snippetLength(forContextSize contextSize: Int) -> Int {
        let scaled = baseSnippetLength * contextSize / baselineContextSize
        return min(max(scaled, baseSnippetLength), maxScaledSnippetLength)
    }

    /// Upper bound for a generated answer, within every provider's output limit.
    static let maxAnswerTokens = 4096

    /// Tokens reserved for a generated answer when a provider needs an explicit output limit:
    /// a third of the context, capped at `maxAnswerTokens`.
    static func answerTokenBudget(forContextSize contextSize: Int) -> Int {
        min(contextSize / 3, maxAnswerTokens)
    }

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
