import Foundation
import Observation

@MainActor
@Observable
final class AppState {

    var hasSeenOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }

    var lastSeenWhatsNewVersion: Int = UserDefaults.standard.integer(forKey: "lastSeenWhatsNewVersion") {
        didSet {
            UserDefaults.standard.set(lastSeenWhatsNewVersion, forKey: "lastSeenWhatsNewVersion")
        }
    }

    static let currentWhatsNewVersion = 1

    /// The What's New sheet is only for returning users on an OS that has the new features.
    static func shouldShowWhatsNew(
        hasSeenOnboarding: Bool,
        lastSeenVersion: Int,
        supportsNewFeatures: Bool
    ) -> Bool {
        hasSeenOnboarding && supportsNewFeatures && lastSeenVersion < currentWhatsNewVersion
    }
}
