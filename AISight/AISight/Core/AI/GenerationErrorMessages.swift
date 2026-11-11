import Foundation
import FoundationModels

@available(iOS 26.0, macOS 26.0, *)
func generationErrorToAnswerError(_ error: LanguageModelSession.GenerationError) -> AnswerError {
    switch error {
    case .guardrailViolation, .refusal:
        return .contentPolicy
    case .exceededContextWindowSize:
        return .generationFailed(ErrorCopy.tooLong)
    case .unsupportedLanguageOrLocale:
        return .generationFailed(ErrorCopy.unsupportedLanguage)
    case .rateLimited:
        return .generationFailed(ErrorCopy.rateLimited)
    case .assetsUnavailable:
        return .modelUnavailable
    case .concurrentRequests:
        return .generationFailed(ErrorCopy.busy)
    case .unsupportedGuide:
        return .generationFailed(ErrorCopy.unsupportedRequest)
    case .decodingFailure:
        return .generationFailed(ErrorCopy.decoding)
    @unknown default:
        return .generationFailed(error.localizedDescription)
    }
}

/// Maps any error thrown while generating an answer, from any language model, to an `AnswerError`.
@available(iOS 26.0, macOS 26.0, *)
func answerError(from error: Error) -> AnswerError {
    if let chatError = error as? ChatCompletionsError {
        return chatError == .contentFilter ? .contentPolicy : .generationFailed(chatError.localizedDescription)
    }
    if let genError = error as? LanguageModelSession.GenerationError {
        return generationErrorToAnswerError(genError)
    }
    if #available(iOS 27.0, macOS 27.0, *) {
        if let modelError = error as? LanguageModelError {
            return languageModelErrorToAnswerError(modelError)
        }
        if let cloudError = error as? PrivateCloudComputeLanguageModel.Error {
            return cloudErrorToAnswerError(cloudError)
        }
        if error is SystemLanguageModel.Error {
            return .modelUnavailable
        }
        if error is LanguageModelSession.Error {
            return .generationFailed(ErrorCopy.busy)
        }
    }
    return .generationFailed(error.localizedDescription)
}

@available(iOS 27.0, macOS 27.0, *)
private func languageModelErrorToAnswerError(_ error: LanguageModelError) -> AnswerError {
    switch error {
    case .guardrailViolation, .refusal:
        return .contentPolicy
    case .contextSizeExceeded:
        return .generationFailed(ErrorCopy.tooLong)
    case .unsupportedLanguageOrLocale:
        return .generationFailed(ErrorCopy.unsupportedLanguage)
    case .rateLimited:
        return .generationFailed(ErrorCopy.rateLimited)
    case .timeout:
        return .generationFailed(ErrorCopy.timeout)
    case .unsupportedCapability, .unsupportedTranscriptContent, .unsupportedGenerationGuide:
        return .generationFailed(ErrorCopy.unsupportedRequest)
    @unknown default:
        return .generationFailed(error.localizedDescription)
    }
}

@available(iOS 27.0, macOS 27.0, *)
private func cloudErrorToAnswerError(_ error: PrivateCloudComputeLanguageModel.Error) -> AnswerError {
    switch error {
    case .quotaLimitReached:
        return .generationFailed(String(localized: "The daily limit for Apple Private Cloud Compute has been reached. Please try again later."))
    case .networkFailure:
        return .generationFailed(String(localized: "Could not reach Apple Private Cloud Compute. Check your connection and try again."))
    case .serviceUnavailable:
        return .generationFailed(String(localized: "Apple Private Cloud Compute is temporarily unavailable. Please try again later."))
    @unknown default:
        return .generationFailed(error.localizedDescription)
    }
}
