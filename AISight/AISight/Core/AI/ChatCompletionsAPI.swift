import Foundation

nonisolated struct ChatMessage: Sendable, Equatable, Encodable {
    let role: String
    let content: String
}

nonisolated enum ChatCompletionsError: Error, Equatable, LocalizedError {
    case invalidAPIKey
    case notFound
    case rateLimited
    case contextLengthExceeded
    case contentFilter
    case timeout
    case network
    case incompleteStream
    case invalidResponse
    case server(message: String)
    case http(status: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: String(localized: "Invalid API key. Check it in Settings \u{2192} AI Model.")
        case .notFound: String(localized: "Model or URL not found. Check the custom provider settings.")
        case .rateLimited: String(localized: "The custom provider has received too many requests. Please try again shortly.")
        case .contextLengthExceeded: ErrorCopy.tooLong
        case .contentFilter: ErrorCopy.contentBlocked
        case .timeout: String(localized: "The custom provider took too long to respond. Please try again.")
        case .network: String(localized: "Could not reach the custom provider. Check your connection and the server URL.")
        case .incompleteStream: String(localized: "The custom provider's response ended unexpectedly. Please try again.")
        case .invalidResponse: String(localized: "The custom provider sent a response AISight can't read. Check that it is OpenAI-compatible.")
        case .server(let message): String(localized: "The custom provider returned an error: \(message)")
        case .http(let status, let message):
            if let message { String(localized: "The custom provider returned an error (HTTP \(status)): \(message)") }
            else { String(localized: "The custom provider returned an error (HTTP \(status)).") }
        }
    }
}

nonisolated enum SSEEvent: Equatable {
    case delta(String)
    case finished
    case failed(ChatCompletionsError)
    case ignored
}

/// Removes `<think>...</think>` spans from streamed text, including tags split across chunks.
nonisolated struct ThinkTagFilter {
    private var pending = ""
    private var inThink = false

    mutating func feed(_ chunk: String) -> String {
        pending += chunk
        var output = ""
        while true {
            let tag = inThink ? "</think>" : "<think>"
            if let range = pending.range(of: tag) {
                if !inThink { output += pending[..<range.lowerBound] }
                pending = String(pending[range.upperBound...])
                inThink.toggle()
            } else {
                var keep = min(tag.count - 1, pending.count)
                while keep > 0 && !tag.hasPrefix(pending.suffix(keep)) { keep -= 1 }
                let emitEnd = pending.index(pending.endIndex, offsetBy: -keep)
                if !inThink { output += pending[..<emitEnd] }
                pending = String(pending[emitEnd...])
                return output
            }
        }
    }

    /// Text still buffered at the end of the stream.
    mutating func finish() -> String {
        defer { pending = "" }
        return inThink ? "" : pending
    }
}

/// Pure request building and response parsing for the OpenAI Chat Completions API.
nonisolated enum ChatCompletionsAPI {
    static let requestTimeout: TimeInterval = 180
    static let maxErrorBodyBytes = 4096

    private struct Body: Encodable {
        let model: String
        let messages: [ChatMessage]
        let maxTokens: Int
        let usesMaxCompletionTokens: Bool

        enum CodingKeys: String, CodingKey {
            case model, messages, stream
            case maxTokens = "max_tokens"
            case maxCompletionTokens = "max_completion_tokens"
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            try container.encode(messages, forKey: .messages)
            try container.encode(true, forKey: .stream)
            try container.encode(maxTokens, forKey: usesMaxCompletionTokens ? .maxCompletionTokens : .maxTokens)
        }
    }

    static func makeRequest(config: CustomModelConfig, messages: [ChatMessage]) throws -> URLRequest {
        var request = URLRequest(url: config.baseURL.appending(path: "chat/completions"))
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        if let apiKey = config.apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONEncoder().encode(
            Body(
                model: config.model,
                messages: messages,
                maxTokens: config.maxTokens,
                usesMaxCompletionTokens: config.usesMaxCompletionTokens
            )
        )
        return request
    }

    /// True when a 400 error body says the model needs `max_completion_tokens` instead of `max_tokens`.
    static func requiresMaxCompletionTokens(errorBody: String) -> Bool {
        errorBody.lowercased().contains("max_completion_tokens")
    }

    /// Parses one line of a server-sent-events stream.
    static func parseSSELine(_ line: String) -> SSEEvent {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("data:") else { return .ignored }
        let payload = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
        if payload == "[DONE]" { return .finished }
        guard let object = jsonObject(payload) else { return .ignored }
        if let error = error(fromObject: object, status: nil) { return .failed(error) }
        guard let choice = (object["choices"] as? [[String: Any]])?.first else { return .ignored }
        if let content = (choice["delta"] as? [String: Any])?["content"] as? String, !content.isEmpty {
            return .delta(content)
        }
        if let reason = choice["finish_reason"] as? String, !reason.isEmpty {
            return reason == "content_filter" ? .failed(.contentFilter) : .finished
        }
        return .ignored
    }

    /// Parses a complete, non-streamed completion body: returns the message content or throws the embedded error.
    static func parseFullBody(_ body: String) throws -> String {
        guard let object = jsonObject(body.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ChatCompletionsError.invalidResponse
        }
        if let error = error(fromObject: object, status: nil) { throw error }
        guard let choice = (object["choices"] as? [[String: Any]])?.first,
              let content = (choice["message"] as? [String: Any])?["content"] as? String else {
            throw ChatCompletionsError.invalidResponse
        }
        return content
    }

    /// Maps a non-2xx response, using the error code and message from the body when present.
    static func error(forStatus status: Int, body: String) -> ChatCompletionsError {
        if let object = jsonObject(body.trimmingCharacters(in: .whitespacesAndNewlines)),
           let error = error(fromObject: object, status: status) { return error }
        return statusError(status, message: nil)
    }

    private static func jsonObject(_ text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    private static func statusError(_ status: Int, message: String?) -> ChatCompletionsError {
        switch status {
        case 401, 403: .invalidAPIKey
        case 404: .notFound
        case 429: .rateLimited
        default: .http(status: status, message: message)
        }
    }

    private static func error(fromObject object: [String: Any], status: Int?) -> ChatCompletionsError? {
        guard let raw = object["error"] else { return nil }
        let detail = raw as? [String: Any]
        let message = (detail?["message"] as? String) ?? (raw as? String)
        let code = (detail?["code"] as? String) ?? (detail?["type"] as? String)
        switch code {
        case "context_length_exceeded": return .contextLengthExceeded
        case "content_filter": return .contentFilter
        default: break
        }
        if let status { return statusError(status, message: message) }
        return .server(message: message ?? "")
    }
}
