import Testing
@testable import AISight

struct WhatsNewTests {

    private let current = AppState.currentWhatsNewVersion

    @Test func shows_returningUserNotYetSeen_onSupportedOS() {
        #expect(AppState.shouldShowWhatsNew(hasSeenOnboarding: true, lastSeenVersion: 0, supportsNewFeatures: true))
    }

    @Test func hidden_beforeOnboarding() {
        #expect(!AppState.shouldShowWhatsNew(hasSeenOnboarding: false, lastSeenVersion: 0, supportsNewFeatures: true))
    }

    @Test func hidden_whenAlreadySeen() {
        #expect(!AppState.shouldShowWhatsNew(hasSeenOnboarding: true, lastSeenVersion: current, supportsNewFeatures: true))
    }

    @Test func hidden_onUnsupportedOS() {
        #expect(!AppState.shouldShowWhatsNew(hasSeenOnboarding: true, lastSeenVersion: 0, supportsNewFeatures: false))
    }
}
