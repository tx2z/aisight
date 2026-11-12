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
    /// The one list of supported languages: code, English name (for prompts), native name (for pickers).
    static let supportedLanguages: [(code: String, englishName: String, nativeName: String)] = [
        ("en", "English", "English"),
        ("de", "German", "Deutsch"),
        ("fr", "French", "Fran\u{00E7}ais"),
        ("es", "Spanish", "Espa\u{00F1}ol"),
        ("it", "Italian", "Italiano"),
        ("ja", "Japanese", "\u{65E5}\u{672C}\u{8A9E}"),
        ("ko", "Korean", "\u{D55C}\u{AD6D}\u{C5B4}"),
        ("zh", "Chinese", "\u{4E2D}\u{6587}"),
        ("pt", "Portuguese", "Portugu\u{00EA}s")
    ]

    static func englishLanguageName(for code: String) -> String? {
        supportedLanguages.first { $0.code == code }?.englishName
    }

    /// Base language code (`es-ES`, `zh_Hans` -> `es`, `zh`) when it is a supported language; nil otherwise.
    static func supportedLanguageCode(from identifier: String) -> String? {
        guard let base = identifier.split(whereSeparator: { $0 == "-" || $0 == "_" }).first?.lowercased() else { return nil }
        return supportedLanguages.contains { $0.code == base } ? base : nil
    }

    /// The language chosen in Settings, else the device language when supported, else English.
    static var effectiveSearchLanguage: String {
        searchLanguage(
            detected: nil,
            stored: UserDefaults.standard.string(forKey: "search_language"),
            preferredLanguages: Locale.preferredLanguages
        )
    }

    /// The detected question language, else the stored language, else the device language, else English.
    /// Only supported languages are accepted at each step.
    static func searchLanguage(detected: String?, stored: String?, preferredLanguages: [String]) -> String {
        if let code = detected.flatMap(supportedLanguageCode(from:)) { return code }
        if let code = stored.flatMap(supportedLanguageCode(from:)) { return code }
        if let code = preferredLanguages.first.flatMap(supportedLanguageCode(from:)) { return code }
        return "en"
    }

    /// Today's date as `yyyy-MM-dd`.
    static func todayISODate() -> String {
        Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    }

    static func currentYear() -> Int {
        Calendar.current.component(.year, from: .now)
    }

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
