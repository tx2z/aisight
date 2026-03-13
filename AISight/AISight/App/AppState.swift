import Foundation
import Observation

#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
@Observable
final class AppState {

    var hasSeenOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }

    var isAppleIntelligenceAvailable: Bool {
        if #available(iOS 26.0, macOS 26.0, *) {
            SystemLanguageModel.default.availability == .available
        } else {
            false
        }
    }

}
