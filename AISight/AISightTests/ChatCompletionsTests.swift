import Testing
import Foundation
import FoundationModels
@testable import AISight

struct ChatCompletionsTests {

    private func config(apiKey: String? = "sk-test", base: String = "https://api.example.com/v1", contextSize: Int = 4096) throws -> CustomModelConfig {
        CustomModelConfig(baseURL: try #require(URL(string: base)), model: "test-model", apiKey: apiKey, contextSize: contextSize)
    }

    // MARK: - Request building

    @Test func makeRequest_urlMethodHeadersAndTimeout() throws {
        let request = try ChatCompletionsAPI.makeRequest(config: config(), messages: [])
        #expect(request.url?.absoluteString == "https://api.example.com/v1/chat/completions")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer sk-test")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.timeoutInterval == 180)
    }

    @Test func makeRequest_noAPIKey_omitsAuthorization() throws {
        let request = try ChatCompletionsAPI.makeRequest(config: config(apiKey: nil), messages: [])
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func makeRequest_bodyHasModelStreamMessagesAndMaxTokens() throws {
        let messages = [ChatMessage(role: "system", content: "Be brief"), ChatMessage(role: "user", content: "Hi")]
        let request = try ChatCompletionsAPI.makeRequest(config: config(contextSize: 8192), messages: messages)
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["model"] as? String == "test-model")
        #expect(json["stream"] as? Bool == true)
        #expect(json["max_tokens"] as? Int == AppConfig.answerTokenBudget(forContextSize: 8192))
        let sent = try #require(json["messages"] as? [[String: String]])
        #expect(sent == [["role": "system", "content": "Be brief"], ["role": "user", "content": "Hi"]])
    }

    @Test func makeRequest_defaultSendsMaxTokens() throws {
        let request = try ChatCompletionsAPI.makeRequest(config: config(contextSize: 8192), messages: [])
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["max_tokens"] as? Int == AppConfig.answerTokenBudget(forContextSize: 8192))
        #expect(json["max_completion_tokens"] == nil)
    }

    @Test func makeRequest_flagSendsMaxCompletionTokens() throws {
        var flagged = try config(contextSize: 8192)
        flagged.usesMaxCompletionTokens = true
        let request = try ChatCompletionsAPI.makeRequest(config: flagged, messages: [])
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["max_completion_tokens"] as? Int == AppConfig.answerTokenBudget(forContextSize: 8192))
        #expect(json["max_tokens"] == nil)
    }

    @Test func requiresMaxCompletionTokens_detectsOpenAIMessage() {
        let body = #"{"error":{"message":"Unsupported parameter: 'max_tokens' is not supported with this model. Use 'max_completion_tokens' instead.","type":"invalid_request_error","param":"max_tokens","code":"unsupported_parameter"}}"#
        #expect(ChatCompletionsAPI.requiresMaxCompletionTokens(errorBody: body))
        #expect(ChatCompletionsAPI.requiresMaxCompletionTokens(errorBody: "USE MAX_COMPLETION_TOKENS"))
    }

    @Test func requiresMaxCompletionTokens_ignoresUnrelatedErrors() {
        #expect(!ChatCompletionsAPI.requiresMaxCompletionTokens(errorBody: #"{"error":{"message":"Invalid model","code":"model_not_found"}}"#))
        #expect(!ChatCompletionsAPI.requiresMaxCompletionTokens(errorBody: ""))
    }

    // MARK: - Learned flag persistence

    private func makeDefaults() throws -> UserDefaults {
        let name = "ChatCompletionsTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: name))
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func savedFlag_resetWhenHostOrModelChanges() throws {
        let defaults = try makeDefaults()
        CustomModelSettings.save(baseURL: "https://api.example.com/v1", model: "m1", apiKey: "", contextSize: 4096, defaults: defaults)
        CustomModelSettings.recordUsesMaxCompletionTokens(defaults: defaults)
        #expect(defaults.bool(forKey: "custom_model_uses_max_completion_tokens"))

        CustomModelSettings.save(baseURL: "https://api.example.com/v1/", model: "m1", apiKey: "", contextSize: 8192, defaults: defaults)
        #expect(defaults.bool(forKey: "custom_model_uses_max_completion_tokens"))

        CustomModelSettings.save(baseURL: "https://api.example.com/v1", model: "m2", apiKey: "", contextSize: 4096, defaults: defaults)
        #expect(!defaults.bool(forKey: "custom_model_uses_max_completion_tokens"))

        CustomModelSettings.recordUsesMaxCompletionTokens(defaults: defaults)
        CustomModelSettings.save(baseURL: "https://other.example.com/v1", model: "m2", apiKey: "", contextSize: 4096, defaults: defaults)
        #expect(!defaults.bool(forKey: "custom_model_uses_max_completion_tokens"))
    }

    @Test func clear_removesFlag() throws {
        let defaults = try makeDefaults()
        CustomModelSettings.recordUsesMaxCompletionTokens(defaults: defaults)
        CustomModelSettings.clear(defaults: defaults)
        #expect(!defaults.bool(forKey: "custom_model_uses_max_completion_tokens"))
    }

    // MARK: - SSE parsing

    @Test func parseSSELine_deltaWithAndWithoutSpace() {
        #expect(ChatCompletionsAPI.parseSSELine(#"data: {"choices":[{"delta":{"content":"Hi"}}]}"#) == .delta("Hi"))
        #expect(ChatCompletionsAPI.parseSSELine(#"data:{"choices":[{"delta":{"content":"Hi"}}]}"#) == .delta("Hi"))
    }

    @Test func parseSSELine_crlfTolerated() {
        #expect(ChatCompletionsAPI.parseSSELine("data: [DONE]\r") == .finished)
    }

    @Test func parseSSELine_multipleChunksThenDone() {
        let lines = [
            #"data: {"choices":[{"delta":{"content":"Hel"}}]}"#,
            #"data: {"choices":[{"delta":{"content":"lo"}}]}"#,
            "data: [DONE]",
        ]
        #expect(lines.map(ChatCompletionsAPI.parseSSELine) == [.delta("Hel"), .delta("lo"), .finished])
    }

    @Test func parseSSELine_finishReasonFinishes() {
        #expect(ChatCompletionsAPI.parseSSELine(#"data: {"choices":[{"delta":{},"finish_reason":"stop"}]}"#) == .finished)
    }

    @Test func parseSSELine_contentFilterFails() {
        #expect(ChatCompletionsAPI.parseSSELine(#"data: {"choices":[{"delta":{},"finish_reason":"content_filter"}]}"#) == .failed(.contentFilter))
    }

    @Test func parseSSELine_inStreamErrorFails() {
        #expect(ChatCompletionsAPI.parseSSELine(#"data: {"error":{"message":"boom"}}"#) == .failed(.server(message: "boom")))
    }

    @Test func parseSSELine_malformedAndCommentsIgnored() {
        #expect(ChatCompletionsAPI.parseSSELine("data: {not json") == .ignored)
        #expect(ChatCompletionsAPI.parseSSELine(": keep-alive") == .ignored)
        #expect(ChatCompletionsAPI.parseSSELine("") == .ignored)
        #expect(ChatCompletionsAPI.parseSSELine(#"data: {"choices":[{"delta":{"role":"assistant"}}]}"#) == .ignored)
    }

    @Test func parseFullBody_returnsMessageContent() throws {
        #expect(try ChatCompletionsAPI.parseFullBody(#"{"choices":[{"message":{"content":"Answer"}}]}"#) == "Answer")
    }

    @Test func parseFullBody_errorAndGarbageThrow() {
        #expect(throws: ChatCompletionsError.self) { try ChatCompletionsAPI.parseFullBody(#"{"error":{"message":"x"}}"#) }
        #expect(throws: ChatCompletionsError.invalidResponse) { try ChatCompletionsAPI.parseFullBody("<html>") }
    }

    // MARK: - HTTP error bodies

    @Test func errorForStatus_mapsStatusCodes() {
        #expect(ChatCompletionsAPI.error(forStatus: 401, body: "") == .invalidAPIKey)
        #expect(ChatCompletionsAPI.error(forStatus: 403, body: "") == .invalidAPIKey)
        #expect(ChatCompletionsAPI.error(forStatus: 404, body: "") == .notFound)
        #expect(ChatCompletionsAPI.error(forStatus: 429, body: "") == .rateLimited)
        #expect(ChatCompletionsAPI.error(forStatus: 500, body: "") == .http(status: 500, message: nil))
    }

    @Test func errorForStatus_usesBodyCodeAndMessage() {
        #expect(ChatCompletionsAPI.error(forStatus: 400, body: #"{"error":{"code":"context_length_exceeded","message":"x"}}"#) == .contextLengthExceeded)
        #expect(ChatCompletionsAPI.error(forStatus: 400, body: #"{"error":{"code":"content_filter"}}"#) == .contentFilter)
        #expect(ChatCompletionsAPI.error(forStatus: 500, body: #"{"error":{"message":"overloaded"}}"#) == .http(status: 500, message: "overloaded"))
    }

    // MARK: - Think-tag filtering

    @Test func thinkFilter_removesWholeSpan() {
        var filter = ThinkTagFilter()
        #expect(filter.feed("<think>hidden</think>Visible") + filter.finish() == "Visible")
    }

    @Test func thinkFilter_handlesTagsSplitAcrossChunks() {
        var filter = ThinkTagFilter()
        let chunks = ["Hello <thi", "nk>secret</th", "ink> world"]
        let output = chunks.map { filter.feed($0) }.joined() + filter.finish()
        #expect(output == "Hello  world")
    }

    @Test func thinkFilter_keepsLoneAngleBracket() {
        var filter = ThinkTagFilter()
        #expect(filter.feed("a < b") + filter.finish() == "a < b")
    }

    // MARK: - URL validation

    @Test func validatedBaseURL_httpsAccepted_remoteHTTPRejected() {
        #expect(CustomModelSettings.validatedBaseURL("https://api.openai.com/v1") != nil)
        #expect(CustomModelSettings.validatedBaseURL("http://api.example.com/v1") == nil)
    }

    @Test func validatedBaseURL_httpOnlyForLoopback() {
        #expect(CustomModelSettings.validatedBaseURL("http://localhost:11434/v1") != nil)
        #expect(CustomModelSettings.validatedBaseURL("http://127.0.0.1:1234/v1") != nil)
        #expect(CustomModelSettings.validatedBaseURL("http://[::1]:1234/v1") != nil)
        #expect(CustomModelSettings.validatedBaseURL("http://mac.local:1234/v1") == nil)
    }

    @Test func validatedBaseURL_rejectsUserinfoAndGarbage() {
        #expect(CustomModelSettings.validatedBaseURL("https://user:pass@api.example.com/v1") == nil)
        #expect(CustomModelSettings.validatedBaseURL("") == nil)
        #expect(CustomModelSettings.validatedBaseURL("ftp://example.com") == nil)
    }

    @Test func validatedBaseURL_stripsTrailingChatCompletions() {
        #expect(CustomModelSettings.validatedBaseURL("https://api.example.com/v1/chat/completions")?.absoluteString == "https://api.example.com/v1")
        #expect(CustomModelSettings.validatedBaseURL("https://api.example.com/v1/chat/completions/")?.absoluteString == "https://api.example.com/v1")
    }

    @Test func httpURL_rejectsMissingHostAndNonHTTP() {
        #expect(HTTPURL.parse("https://") == nil)
        #expect(HTTPURL.parse("file:///tmp") == nil)
        #expect(HTTPURL.parse(" https://example.com ") != nil)
    }

    // MARK: - Transcript conversion

    @Test func messages_fromTranscript_skipsEmptyEntries() {
        guard #available(iOS 27.0, macOS 27.0, *) else { return }
        func segments(_ text: String) -> [Transcript.Segment] { [.text(Transcript.TextSegment(content: text))] }
        let transcript = Transcript(entries: [
            .instructions(Transcript.Instructions(segments: segments("Be brief"), toolDefinitions: [])),
            .prompt(Transcript.Prompt(segments: segments("Question"))),
            .response(Transcript.Response(assetIDs: [], segments: segments("  "))),
        ])
        #expect(ChatCompletionsExecutor.messages(from: transcript) == [
            ChatMessage(role: "system", content: "Be brief"),
            ChatMessage(role: "user", content: "Question"),
        ])
    }
}
