import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
func generationErrorToAnswerError(_ error: LanguageModelSession.GenerationError) -> AnswerError {
    switch error {
    case .guardrailViolation, .refusal:
        return .contentPolicy
    case .exceededContextWindowSize:
        return .generationFailed(String(localized: "The query is too long for the on-device model."))
    case .unsupportedLanguageOrLocale:
        return .generationFailed(String(localized: "This language is not supported by the on-device model."))
    case .rateLimited:
        return .generationFailed(String(localized: "The on-device model is rate limited. Please try again shortly."))
    case .assetsUnavailable:
        return .modelUnavailable
    case .concurrentRequests:
        return .generationFailed(String(localized: "Another request is in progress. Please wait."))
    case .unsupportedGuide:
        return .generationFailed(String(localized: "Unsupported generation configuration."))
    case .decodingFailure:
        return .generationFailed(String(localized: "Failed to decode the model response."))
    @unknown default:
        return .generationFailed(error.localizedDescription)
    }
}
