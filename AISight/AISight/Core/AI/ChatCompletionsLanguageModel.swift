import Foundation
import FoundationModels

/// A FoundationModels language model backed by an OpenAI-compatible Chat Completions endpoint.
@available(iOS 27.0, macOS 27.0, *)
nonisolated struct ChatCompletionsLanguageModel: LanguageModel {
    typealias Executor = ChatCompletionsExecutor

    let executorConfiguration: CustomModelConfig

    init(config: CustomModelConfig) {
        executorConfiguration = config
    }

    var capabilities: LanguageModelCapabilities { LanguageModelCapabilities([]) }
}

/// Refuses redirects that leave the original scheme and host, so the API key is never sent elsewhere.
private nonisolated final class SameOriginRedirectGuard: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(
        _ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void
    ) {
        let original = task.originalRequest?.url
        let target = request.url
        let sameOrigin = original?.scheme == target?.scheme && original?.host() == target?.host()
        completionHandler(sameOrigin ? request : nil)
    }
}

@available(iOS 27.0, macOS 27.0, *)
nonisolated struct ChatCompletionsExecutor: LanguageModelExecutor {
    typealias Model = ChatCompletionsLanguageModel
    typealias Configuration = CustomModelConfig

    private let config: CustomModelConfig

    init(configuration: CustomModelConfig) throws {
        config = configuration
    }

    func respond(
        to request: LanguageModelExecutorGenerationRequest,
        model: ChatCompletionsLanguageModel,
        streamingInto channel: LanguageModelExecutorGenerationChannel
    ) async throws {
        let messages = Self.messages(from: request.transcript)
        let session = URLSession(configuration: .ephemeral, delegate: SameOriginRedirectGuard(), delegateQueue: nil)
        defer { session.finishTasksAndInvalidate() }
        do {
            do {
                try await stream(ChatCompletionsAPI.makeRequest(config: config, messages: messages), allowRetry: !config.usesMaxCompletionTokens, using: session, into: channel)
            } catch RetryWithMaxCompletionTokens.signal {
                var retryConfig = config
                retryConfig.usesMaxCompletionTokens = true
                try await stream(ChatCompletionsAPI.makeRequest(config: retryConfig, messages: messages), allowRetry: false, using: session, into: channel)
                CustomModelSettings.recordUsesMaxCompletionTokens()
            }
        } catch let error as URLError {
            switch error.code {
            case .cancelled: throw CancellationError()
            case .timedOut: throw ChatCompletionsError.timeout
            default: throw ChatCompletionsError.network
            }
        }
    }

    /// Thrown before any content was streamed when the provider rejected `max_tokens`.
    private enum RetryWithMaxCompletionTokens: Error { case signal }

    private func stream(
        _ urlRequest: URLRequest, allowRetry: Bool, using session: URLSession, into channel: LanguageModelExecutorGenerationChannel
    ) async throws {
        let (bytes, response) = try await session.bytes(for: urlRequest)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            var body = Data()
            for try await byte in bytes {
                body.append(byte)
                if body.count >= ChatCompletionsAPI.maxErrorBodyBytes { break }
            }
            let bodyText = String(decoding: body, as: UTF8.self)
            if http.statusCode == 400 && allowRetry
                && ChatCompletionsAPI.requiresMaxCompletionTokens(errorBody: bodyText) {
                throw RetryWithMaxCompletionTokens.signal
            }
            throw ChatCompletionsAPI.error(forStatus: http.statusCode, body: bodyText)
        }

        let entryID = UUID().uuidString
        let segmentID = UUID().uuidString
        var filter = ThinkTagFilter()
        var sawSSE = false
        var finished = false
        var rawLines: [String] = []

        func emit(_ text: String) async {
            guard !text.isEmpty else { return }
            await channel.send(.response(
                entryID: entryID,
                action: .appendText(text, segmentID: segmentID, tokenCount: max(1, text.count / 4))
            ))
        }

        for try await line in bytes.lines {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("data:") { sawSSE = true } else { rawLines.append(line) }
            switch ChatCompletionsAPI.parseSSELine(line) {
            case .delta(let text): await emit(filter.feed(text))
            case .finished: finished = true
            case .failed(let error): throw error
            case .ignored: continue
            }
            if finished { break }
        }

        if sawSSE {
            guard finished else { throw ChatCompletionsError.incompleteStream }
        } else {
            await emit(filter.feed(try ChatCompletionsAPI.parseFullBody(rawLines.joined(separator: "\n"))))
        }
        await emit(filter.finish())
    }

    /// Instructions become the system message; prompts and responses keep their roles. Empty entries are skipped.
    static func messages(from transcript: Transcript) -> [ChatMessage] {
        func text(_ segments: [Transcript.Segment]) -> String {
            segments.compactMap { segment in
                if case .text(let textSegment) = segment { textSegment.content } else { nil }
            }.joined(separator: "\n")
        }
        return transcript.compactMap { entry in
            let message: ChatMessage? = switch entry {
            case .instructions(let instructions): ChatMessage(role: "system", content: text(instructions.segments))
            case .prompt(let prompt): ChatMessage(role: "user", content: text(prompt.segments))
            case .response(let response): ChatMessage(role: "assistant", content: text(response.segments))
            default: nil
            }
            return message.flatMap { $0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : $0 }
        }
    }
}
