import Foundation
import FoundationModels

/// The three model sources. Also the persisted user preference (`language_model`).
nonisolated enum LanguageModelKind: String, Sendable, CaseIterable, Codable {
    case onDevice
    case appleCloud
    case custom
}

nonisolated enum CloudModelStatus: Sendable, Equatable {
    case notOffered
    case usable
    case quotaReached
    case unavailable
}

/// Why the model in use differs from the user's preference.
nonisolated enum FallbackReason: Sendable, Equatable, Codable {
    case requiresPro
    case cloudUnavailable
    case quotaReached
    case notOfferedOnDevice
    case customNotConfigured
    case cloudFailed

    /// Settings status line shown when the preference cannot be honored.
    var statusMessage: String {
        switch self {
        case .requiresPro: String(localized: "Requires Pro \u{2014} using on-device")
        case .cloudUnavailable, .cloudFailed: String(localized: "Unavailable \u{2014} using on-device")
        case .quotaReached: String(localized: "Daily limit reached \u{2014} using on-device")
        case .notOfferedOnDevice: String(localized: "Not available on this device \u{2014} using on-device")
        case .customNotConfigured: String(localized: "Not configured \u{2014} using on-device")
        }
    }

    /// Short wording for the answer badge.
    var shortDescription: String {
        switch self {
        case .requiresPro: String(localized: "Pro required")
        case .cloudUnavailable: String(localized: "cloud unavailable")
        case .quotaReached: String(localized: "daily limit reached")
        case .notOfferedOnDevice: String(localized: "not available on this device")
        case .customNotConfigured: String(localized: "custom provider not configured")
        case .cloudFailed: String(localized: "cloud unreachable")
        }
    }
}

nonisolated struct ModelSelection: Sendable, Equatable {
    let kind: LanguageModelKind
    let fallbackReason: FallbackReason?
}

/// A model chosen once for a whole request; every session it creates uses that same model.
@available(iOS 26.0, macOS 26.0, *)
nonisolated struct ResolvedLanguageModel: Sendable {
    enum Source: Sendable {
        case onDevice
        case appleCloud
        case custom(CustomModelConfig)
    }

    let source: Source
    let contextSize: Int
    var fallbackReason: FallbackReason?

    static let placeholder = ResolvedLanguageModel(source: .onDevice, contextSize: AppConfig.baselineContextSize)

    var kind: LanguageModelKind {
        switch source {
        case .onDevice: .onDevice
        case .appleCloud: .appleCloud
        case .custom: .custom
        }
    }

    /// Model name shown in the answer badge for custom providers.
    var customModelName: String? {
        if case .custom(let config) = source { config.model } else { nil }
    }

    func makeSession(instructions: String) -> LanguageModelSession {
        if #available(iOS 27.0, macOS 27.0, *) {
            switch source {
            case .appleCloud:
                return LanguageModelSession(model: PrivateCloudComputeLanguageModel(), instructions: instructions)
            case .custom(let config):
                return LanguageModelSession(model: ChatCompletionsLanguageModel(config: config), instructions: instructions)
            case .onDevice:
                break
            }
        }
        return LanguageModelSession(instructions: instructions)
    }
}

/// Single owner of language model selection across three sources: the on-device model (default),
/// Apple's Private Cloud Compute (Pro, iOS/macOS 27+) and a user-configured OpenAI-compatible
/// provider (iOS/macOS 27+). Whatever cannot be honored falls back to on-device.
@available(iOS 26.0, macOS 26.0, *)
enum LanguageModelProvider {
    static let preferenceKey = "language_model"

    static var preference: LanguageModelKind {
        UserDefaults.standard.string(forKey: preferenceKey).flatMap(LanguageModelKind.init(rawValue:)) ?? .onDevice
    }

    static var supportsCustomModels: Bool {
        if #available(iOS 27.0, macOS 27.0, *) { true } else { false }
    }

    /// The model that will actually be used for `preference`, and why it differs when it does.
    static func select(
        preference: LanguageModelKind,
        cloudStatus: CloudModelStatus,
        canUseCloudModel: Bool,
        customConfigured: Bool
    ) -> ModelSelection {
        switch preference {
        case .onDevice:
            return ModelSelection(kind: .onDevice, fallbackReason: nil)
        case .appleCloud:
            let reason: FallbackReason? = switch cloudStatus {
            case .notOffered: .notOfferedOnDevice
            case _ where !canUseCloudModel: .requiresPro
            case .unavailable: .cloudUnavailable
            case .quotaReached: .quotaReached
            case .usable: nil
            }
            return ModelSelection(kind: reason == nil ? .appleCloud : .onDevice, fallbackReason: reason)
        case .custom:
            return customConfigured
                ? ModelSelection(kind: .custom, fallbackReason: nil)
                : ModelSelection(kind: .onDevice, fallbackReason: .customNotConfigured)
        }
    }

    static func cloudStatus() -> CloudModelStatus {
        guard #available(iOS 27.0, macOS 27.0, *) else { return .notOffered }
        let model = PrivateCloudComputeLanguageModel()
        if model.availability == .unavailable(.deviceNotEligible) { return .notOffered }
        guard model.isAvailable else { return .unavailable }
        if case .limitReached = model.quotaUsage.status { return .quotaReached }
        return .usable
    }

    static func resolve(canUseCloudModel: Bool) async -> ResolvedLanguageModel {
        let customConfig = supportsCustomModels ? CustomModelSettings.load() : nil
        let selection = select(
            preference: preference, cloudStatus: cloudStatus(),
            canUseCloudModel: canUseCloudModel, customConfigured: customConfig != nil
        )
        if #available(iOS 27.0, macOS 27.0, *) {
            switch selection.kind {
            case .custom:
                if let customConfig {
                    return ResolvedLanguageModel(source: .custom(customConfig), contextSize: customConfig.contextSize)
                }
            case .appleCloud:
                if let size = try? await PrivateCloudComputeLanguageModel().contextSize {
                    return ResolvedLanguageModel(source: .appleCloud, contextSize: size)
                }
                return await resolveOnDevice(reason: .cloudUnavailable)
            case .onDevice:
                break
            }
        }
        return await resolveOnDevice(reason: selection.fallbackReason)
    }

    static func resolveOnDevice(reason: FallbackReason?) async -> ResolvedLanguageModel {
        var contextSize = AppConfig.baselineContextSize
        if #available(iOS 27.0, macOS 27.0, *) { contextSize = SystemLanguageModel.default.contextSize }
        return ResolvedLanguageModel(source: .onDevice, contextSize: contextSize, fallbackReason: reason)
    }

    /// Session for short utility prompts; always on-device so no cloud quota is spent.
    static func makeOnDeviceSession(instructions: String) -> LanguageModelSession {
        LanguageModelSession(instructions: instructions)
    }

    /// Runs `work` with `model`. If Apple Private Cloud Compute fails with a quota, network or service
    /// error, switches to the on-device model, reports it through `onFallback`, and runs `work` again.
    static func runWithCloudFallback(
        _ model: ResolvedLanguageModel,
        onFallback: (ResolvedLanguageModel) -> Void,
        work: (ResolvedLanguageModel) async throws -> Void
    ) async throws {
        do {
            try await work(model)
        } catch where model.kind == .appleCloud && isCloudFallbackError(error) && !Task.isCancelled {
            let fallback = await resolveOnDevice(reason: .cloudFailed)
            onFallback(fallback)
            try await work(fallback)
        }
    }

    static func isCloudFallbackError(_ error: Error) -> Bool {
        guard #available(iOS 27.0, macOS 27.0, *),
              let cloudError = error as? PrivateCloudComputeLanguageModel.Error else { return false }
        switch cloudError {
        case .quotaLimitReached, .networkFailure, .serviceUnavailable: return true
        @unknown default: return false
        }
    }
}
