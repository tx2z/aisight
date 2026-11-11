import Foundation

/// Settings for an OpenAI-compatible Chat Completions provider.
nonisolated struct CustomModelConfig: Sendable, Hashable {
    let baseURL: URL
    let model: String
    let apiKey: String?
    let contextSize: Int
    /// True once the provider rejected `max_tokens`; requests then send `max_completion_tokens`.
    var usesMaxCompletionTokens = false

    /// Tokens reserved for the answer, derived from the context size.
    var maxTokens: Int { AppConfig.answerTokenBudget(forContextSize: contextSize) }
}

/// Stored user configuration for the custom provider. The API key lives in the Keychain only and
/// is bound to the host it was saved for.
nonisolated enum CustomModelSettings {
    static let baseURLKey = "custom_model_base_url"
    static let modelKey = "custom_model_name"
    static let contextSizeKey = "custom_model_context_size"
    private static let keyHostKey = "custom_model_key_host"
    private static let consentedHostsKey = "custom_model_consented_hosts"
    private static let apiKeyAccount = "custom_model_api_key"
    private static let usesMaxCompletionTokensKey = "custom_model_uses_max_completion_tokens"

    static let contextSizeOptions = [4096, 8192, 32768, 131_072]

    /// https, or http for loopback hosts only.
    static func validatedBaseURL(_ string: String) -> URL? {
        guard var url = HTTPURL.parse(string), let host = url.host() else { return nil }
        if url.scheme?.lowercased() == "http" && !HTTPURL.isLoopback(host: host) { return nil }
        let suffix = "/chat/completions"
        var path = url.path
        while path.hasSuffix("/") { path.removeLast() }
        if path.lowercased().hasSuffix(suffix), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.path = String(path.dropLast(suffix.count))
            url = components.url ?? url
        }
        return url
    }

    static func host(of baseURL: String) -> String? {
        validatedBaseURL(baseURL)?.host()?.lowercased()
    }

    static func storedContextSize(defaults: UserDefaults = .standard) -> Int {
        let stored = defaults.integer(forKey: contextSizeKey)
        return contextSizeOptions.contains(stored) ? stored : AppConfig.baselineContextSize
    }

    /// The API key saved for `host`, or nil when none exists or it was saved for another host.
    static func apiKey(forHost host: String?, defaults: UserDefaults = .standard) -> String? {
        guard let host, defaults.string(forKey: keyHostKey) == host else { return nil }
        return KeychainStore.read(account: apiKeyAccount)
    }

    /// The host the saved API key is bound to.
    static func keyHost(defaults: UserDefaults = .standard) -> String? {
        defaults.string(forKey: keyHostKey)
    }

    static func hasConsent(forHost host: String, defaults: UserDefaults = .standard) -> Bool {
        (defaults.stringArray(forKey: consentedHostsKey) ?? []).contains(host)
    }

    static func recordConsent(forHost host: String, defaults: UserDefaults = .standard) {
        var hosts = defaults.stringArray(forKey: consentedHostsKey) ?? []
        if !hosts.contains(host) { hosts.append(host) }
        defaults.set(hosts, forKey: consentedHostsKey)
    }

    static func recordUsesMaxCompletionTokens(defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: usesMaxCompletionTokensKey)
    }

    /// Persists trimmed values. The learned `max_completion_tokens` flag is reset when the host or model changes. Returns false when the Keychain could not be updated.
    @discardableResult
    static func save(baseURL: String, model: String, apiKey: String, contextSize: Int, defaults: UserDefaults = .standard) -> Bool {
        let previousHost = host(of: defaults.string(forKey: baseURLKey) ?? "")
        let previousModel = defaults.string(forKey: modelKey)
        let trimmedModel = model.trimmingCharacters(in: .whitespacesAndNewlines)
        if previousHost != host(of: baseURL) || previousModel != trimmedModel {
            defaults.removeObject(forKey: usesMaxCompletionTokensKey)
        }
        defaults.set(baseURL.trimmingCharacters(in: .whitespacesAndNewlines), forKey: baseURLKey)
        defaults.set(trimmedModel, forKey: modelKey)
        defaults.set(contextSize, forKey: contextSizeKey)
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let host = host(of: baseURL) else {
            return KeychainStore.write(nil, account: apiKeyAccount)
        }
        defaults.set(host, forKey: keyHostKey)
        return KeychainStore.write(key, account: apiKeyAccount)
    }

    /// Removes the saved URL, model, context size, API key and consent.
    static func clear(defaults: UserDefaults = .standard) {
        for key in [baseURLKey, modelKey, contextSizeKey, keyHostKey, consentedHostsKey, usesMaxCompletionTokensKey] {
            defaults.removeObject(forKey: key)
        }
        KeychainStore.write(nil, account: apiKeyAccount)
    }

    /// The saved configuration, or nil when the URL or model name is missing or the host was not confirmed.
    static func load(defaults: UserDefaults = .standard) -> CustomModelConfig? {
        guard let url = validatedBaseURL(defaults.string(forKey: baseURLKey) ?? ""),
              let host = url.host()?.lowercased(), hasConsent(forHost: host, defaults: defaults),
              let model = defaults.string(forKey: modelKey)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !model.isEmpty else { return nil }
        let key = apiKey(forHost: host, defaults: defaults)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return CustomModelConfig(
            baseURL: url, model: model, apiKey: (key?.isEmpty ?? true) ? nil : key,
            contextSize: storedContextSize(defaults: defaults),
            usesMaxCompletionTokens: defaults.bool(forKey: usesMaxCompletionTokensKey)
        )
    }
}
