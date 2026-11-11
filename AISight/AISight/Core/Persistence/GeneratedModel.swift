import Foundation

/// The model that generated a saved answer, in the plain form the answer badge needs.
nonisolated struct GeneratedModel: Codable, Equatable, Sendable {
    let kind: LanguageModelKind
    let customModelName: String?
    let fallbackReason: FallbackReason?

    @available(iOS 26.0, macOS 26.0, *)
    init(_ model: ResolvedLanguageModel) {
        kind = model.kind
        customModelName = model.customModelName
        fallbackReason = model.fallbackReason
    }

    init(kind: LanguageModelKind, customModelName: String? = nil, fallbackReason: FallbackReason? = nil) {
        self.kind = kind
        self.customModelName = customModelName
        self.fallbackReason = fallbackReason
    }
}
