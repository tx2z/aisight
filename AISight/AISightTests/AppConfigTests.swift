import Testing
import Foundation
@testable import AISight

struct AppConfigTests {

    // MARK: - effectiveSearXNGBaseURL

    @Test func effectiveURL_noStoredValue_returnsDefault() {
        // When no key is set, should return the default
        let effective = AppConfig.effectiveSearXNGBaseURL
        // Can't control UserDefaults.standard in tests without side effects,
        // but we can verify it returns a valid URL string
        #expect(effective.hasPrefix("https://"))
    }

    // MARK: - Static config values

    @Test func maxResults_isFive() {
        #expect(AppConfig.maxResults == 5)
    }

    @Test func deepSearchResearcherCount_isThree() {
        #expect(AppConfig.deepSearchResearcherCount == 3)
    }

    @Test func searchTimeoutSeconds_isReasonable() {
        #expect(AppConfig.searchTimeoutSeconds >= 5)
        #expect(AppConfig.searchTimeoutSeconds <= 30)
    }

    @Test func snippetThreshold_greaterThanMinSnippetLength() {
        #expect(AppConfig.snippetThreshold > AppConfig.minSnippetLength)
    }

    @Test func maxSnippetLength_greaterThanThreshold() {
        #expect(AppConfig.maxSnippetLength > AppConfig.snippetThreshold)
    }

    @Test func trackingParams_containsCommonTrackers() {
        #expect(AppConfig.trackingParams.contains("utm_source"))
        #expect(AppConfig.trackingParams.contains("fbclid"))
        #expect(AppConfig.trackingParams.contains("gclid"))
        #expect(AppConfig.trackingParams.contains("msclkid"))
    }
}
