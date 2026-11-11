import Foundation
import Observation

/// State and logic behind the "AI Model" settings section: the model preference, the custom provider
/// fields, the one-time host confirmation and the Pro-gated Apple Private Cloud Compute choice.
@MainActor
@Observable
final class AIModelSettings {
    var preference: LanguageModelKind
    var baseURL = ""
    var modelName = ""
    var apiKey = ""
    var contextSize = AppConfig.baselineContextSize
    var showPaywall = false
    var showConsentAlert = false
    private(set) var consentHost = ""
    private(set) var cloudStatus: CloudModelStatus = .notOffered
    private(set) var keychainFailed = false

    private var storedAPIKey = ""
    private var pendingCloudSelection = false
    private var pendingCustomSelection = false
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        preference = defaults.string(forKey: LanguageModelProvider.preferenceKey)
            .flatMap(LanguageModelKind.init(rawValue:)) ?? .onDevice
        reloadFields()
    }

    var showsCloud: Bool { cloudStatus != .notOffered }
    var showsCustom: Bool { LanguageModelProvider.supportsCustomModels }
    var isVisible: Bool { showsCloud || showsCustom }

    var isBaseURLInvalid: Bool { !baseURL.isEmpty && CustomModelSettings.validatedBaseURL(baseURL) == nil }
    var isModelNameMissing: Bool { trimmedModelName.isEmpty }

    private var trimmedModelName: String { modelName.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var customConfigured: Bool {
        guard let host = CustomModelSettings.host(of: baseURL) else { return false }
        return !trimmedModelName.isEmpty && CustomModelSettings.hasConsent(forHost: host, defaults: defaults)
    }

    /// Why the stored preference cannot be honored, if it cannot.
    func statusMessage(canUseCloudModel: Bool) -> String? {
        LanguageModelProvider.select(
            preference: preference, cloudStatus: cloudStatus,
            canUseCloudModel: canUseCloudModel, customConfigured: customConfigured
        ).fallbackReason?.statusMessage
    }

    /// Call when the section appears. A cloud preference that cannot be shown falls back to on-device.
    func refreshCloudStatus() {
        cloudStatus = LanguageModelProvider.cloudStatus()
        if preference == .appleCloud && !showsCloud { preference = .onDevice }
    }

    // MARK: - User changes

    func preferenceChanged(from old: LanguageModelKind, to new: LanguageModelKind, canUseCloudModel: Bool) {
        guard old != new else { return }
        switch new {
        case .appleCloud where !canUseCloudModel:
            pendingCloudSelection = true
            preference = old
            showPaywall = true
        case .custom:
            save()
            if let host = CustomModelSettings.host(of: baseURL), !CustomModelSettings.hasConsent(forHost: host, defaults: defaults) {
                pendingCustomSelection = true
                preference = old
                askConsent(forHost: host)
            } else {
                persistPreference()
            }
        default:
            persistPreference()
        }
    }

    /// Saves changed custom provider fields; asks for host confirmation when a custom provider is selected.
    func commit() {
        save()
        if preference == .custom, let host = CustomModelSettings.host(of: baseURL),
           !CustomModelSettings.hasConsent(forHost: host, defaults: defaults) {
            askConsent(forHost: host)
        }
    }

    func allowConsent() {
        CustomModelSettings.recordConsent(forHost: consentHost, defaults: defaults)
        if pendingCustomSelection { preference = .custom }
        pendingCustomSelection = false
    }

    func declineConsent() {
        if preference == .custom { preference = .onDevice }
        pendingCustomSelection = false
    }

    func paywallDismissed(canUseCloudModel: Bool) {
        if pendingCloudSelection && canUseCloudModel { preference = .appleCloud }
        pendingCloudSelection = false
    }

    /// Removes all saved custom provider data and resets the preference.
    func clear() {
        CustomModelSettings.clear(defaults: defaults)
        defaults.removeObject(forKey: LanguageModelProvider.preferenceKey)
        preference = .onDevice
        pendingCloudSelection = false
        pendingCustomSelection = false
        reloadFields()
    }

    // MARK: - Private

    private func askConsent(forHost host: String) {
        consentHost = host
        showConsentAlert = true
    }

    private func persistPreference() {
        let stored = defaults.string(forKey: LanguageModelProvider.preferenceKey) ?? LanguageModelKind.onDevice.rawValue
        if stored != preference.rawValue { defaults.set(preference.rawValue, forKey: LanguageModelProvider.preferenceKey) }
    }

    private func reloadFields() {
        baseURL = defaults.string(forKey: CustomModelSettings.baseURLKey) ?? ""
        modelName = defaults.string(forKey: CustomModelSettings.modelKey) ?? ""
        contextSize = CustomModelSettings.storedContextSize(defaults: defaults)
        apiKey = CustomModelSettings.apiKey(forHost: CustomModelSettings.host(of: baseURL), defaults: defaults) ?? ""
        storedAPIKey = apiKey
        keychainFailed = false
    }

    /// Persists the fields when they differ from what is saved. A key saved for another host is dropped
    /// unless the user typed a new one.
    private func save() {
        let host = CustomModelSettings.host(of: baseURL)
        if host != CustomModelSettings.keyHost(defaults: defaults) && apiKey == storedAPIKey { apiKey = "" }
        let trimmedURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let unchanged = trimmedURL == (defaults.string(forKey: CustomModelSettings.baseURLKey) ?? "")
            && trimmedModelName == (defaults.string(forKey: CustomModelSettings.modelKey) ?? "")
            && contextSize == CustomModelSettings.storedContextSize(defaults: defaults)
            && apiKey == storedAPIKey
        guard !unchanged else { return }
        keychainFailed = !CustomModelSettings.save(
            baseURL: baseURL, model: modelName, apiKey: apiKey, contextSize: contextSize, defaults: defaults
        )
        storedAPIKey = apiKey
    }
}
