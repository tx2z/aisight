# AISight — Research Findings

> Last updated: 2026-03-11

---

## 1. Apple FoundationModels Framework (iOS 26 / macOS 26)

### 1.1 Overview

Apple introduced the **FoundationModels** framework at WWDC 2025 (iOS 26, macOS 26). It exposes the on-device large language model (a ~3 billion parameter model) that powers Apple Intelligence features directly to third-party developers. The framework lives under `import FoundationModels` and requires no network connectivity for inference — all processing is on-device and private.

### 1.2 Core APIs

#### LanguageModelSession

`LanguageModelSession` is the primary interface for interacting with the on-device model.

- **Initialization**: `LanguageModelSession()` or with explicit instructions via `LanguageModelSession(instructions: "You are a helpful assistant...")`.
- **Single response**: `session.respond(to: "prompt")` returns a `LanguageModelSession.Response` containing the generated text.
- **Streaming**: `session.streamResponse(to: "prompt")` returns an `AsyncSequence` of partial response chunks, enabling real-time UI updates as the model generates tokens.
- **Conversation continuity**: A session maintains conversation history. Subsequent calls to `respond(to:)` or `streamResponse(to:)` on the same session instance carry forward prior context.
- **Reset**: `session.reset()` clears the conversation history within that session.

#### SystemLanguageModel

`SystemLanguageModel` provides metadata about the on-device model:

- `SystemLanguageModel.default` — the system's primary language model.
- `.isAvailable` — checks whether the model is downloaded and ready.
- `.contextWindowSize` — reports the model's context window (see below).

#### @Generable Macro

The `@Generable` macro enables structured (typed) output generation:

- Annotate a Swift struct with `@Generable` to have the model return structured data conforming to that type.
- The struct's properties must be basic types (`String`, `Int`, `Bool`, `Double`, arrays thereof, or nested `@Generable` types).
- Usage: `let result: MyStruct = try await session.respond(to: "prompt", generating: MyStruct.self)`.
- This is invaluable for extracting structured citations, ratings, or categorized answers from the model.

#### Tool Calling

FoundationModels supports a tool-calling pattern:

- Define a tool by conforming to the `Tool` protocol (providing a `name`, `description`, and `call(arguments:)` method).
- Register tools when creating a session or when calling `respond`/`streamResponse`.
- The model can decide to invoke a tool during generation; the framework calls the tool's `call` method, feeds the result back to the model, and the model incorporates it into the response.
- Tools enable the model to access live data (e.g., search results) that it does not have in its weights.

### 1.3 Context Window

- The on-device 3B model has a context window of approximately **4,096 tokens**.
- This is small compared to cloud models. It means the combined size of the system prompt, user query, retrieved source content, and generated answer must fit within ~4K tokens.
- Practical implication: aggressive summarization and truncation of search-result content is mandatory. AISight budgets roughly 400 tokens per source and limits to 5 sources maximum (~2,000 tokens for sources + ~500 for system prompt + ~500 for query + ~1,000 for answer).

### 1.4 Known Limitations

| Limitation | Impact on AISight |
|---|---|
| ~4K token context window | Must truncate/summarize source content aggressively |
| No image understanding | Cannot process screenshots, charts, or photos |
| English-primary (some multilingual support) | Non-English queries may produce lower-quality answers |
| No code execution | Cannot run or verify code snippets |
| No mathematical reasoning engine | Math-heavy questions may yield incorrect answers |
| Model not fine-tunable | Cannot customize the model for specific domains |
| Requires Apple Silicon (A17 Pro+, M1+) | Limits to iPhone 15 Pro, iPhone 16 series, recent iPads/Macs |
| iOS 26+ / macOS 26+ required | Users must be on the latest OS |
| No internet for inference, but model must be downloaded | First-time setup requires the model to be present on device |
| Hallucination risk | The 3B model is more prone to confabulation than larger models; grounding with search results mitigates this |

### 1.5 Availability Check

Before using the model, apps should check:

```
if SystemLanguageModel.default.isAvailable {
    // proceed
} else {
    // show message that Apple Intelligence is not available
}
```

The model may be unavailable if: the device lacks Apple Silicon with sufficient capability, Apple Intelligence is disabled in Settings, or the model has not finished downloading.

---

## 2. SearXNG JSON API

### 2.1 Overview

SearXNG is a free, open-source metasearch engine that aggregates results from multiple search engines (Google, Bing, DuckDuckGo, Wikipedia, etc.) without tracking users. It is self-hostable and exposes a JSON API.

### 2.2 API Format

**Request:**

```
GET <base_url>/search?q=<query>&format=json&engines=google,bing,duckduckgo&language=en&pageno=1&categories=general
```

| Parameter | Required | Description |
|---|---|---|
| `q` | Yes | The search query string (URL-encoded) |
| `format` | Yes | Must be `json` for JSON responses |
| `engines` | No | Comma-separated list of engines to query (e.g., `google,bing,duckduckgo`) |
| `language` | No | Language code (e.g., `en`, `de`, `fr`). Defaults to instance setting. |
| `pageno` | No | Page number for pagination. Defaults to `1`. |
| `categories` | No | Search category: `general`, `news`, `science`, `files`, `images`, `music`, `videos`, `it`, `social media` |

**Response (JSON):**

```json
{
  "query": "example query",
  "number_of_results": 12345,
  "results": [
    {
      "url": "https://example.com/page",
      "title": "Page Title",
      "content": "A snippet or description of the page content...",
      "engine": "google",
      "score": 5.2,
      "category": "general",
      "parsed_url": ["https", "example.com", "/page", "", "", ""],
      "engines": ["google", "bing"],
      "positions": [1, 3]
    }
  ],
  "answers": [],
  "corrections": [],
  "infoboxes": [],
  "suggestions": ["related query 1", "related query 2"],
  "unresponsive_engines": []
}
```

**Key response fields per result:**

| Field | Type | Description |
|---|---|---|
| `url` | String | The URL of the result page |
| `title` | String | The title of the result |
| `content` | String | A text snippet/description from the page |
| `engine` | String | The primary engine that returned this result |
| `engines` | [String] | All engines that returned this result |
| `score` | Float | Relevance score (higher is better); aggregated across engines |
| `category` | String | The result category |
| `positions` | [Int] | The rank position in each engine's results |

### 2.3 Rate Limiting

- SearXNG instances may impose rate limits (typically via IP-based throttling or bot detection).
- Self-hosted instances can be configured with custom rate limits or none at all.
- Public instances often have stricter limits; using a self-hosted instance is strongly recommended for AISight.
- AISight should implement retry-with-backoff and surface errors gracefully to the user.

### 2.4 Availability Considerations

- SearXNG is a network service; it may be unreachable if the server is down or the device has no internet.
- AISight must handle the case where SearXNG is unavailable: show a banner, allow the user to configure a different URL in settings, and provide a status indicator.

---

## 3. Web Content Fetching from Swift

### 3.1 Approach

AISight needs to fetch the full text of web pages returned by SearXNG so the on-device model can read and summarize them. The approach:

1. **URLSession** (async/await) — Standard Apple networking. `URLSession.shared.data(from: url)` with Swift concurrency.
2. **Basic HTML tag stripping** — A lightweight approach using regex or `NSAttributedString` to remove HTML tags. No heavy dependencies like SwiftSoup are needed for v1.0.
3. **Text truncation** — After stripping HTML, truncate to a token budget (approximately 400 tokens per source, ~1,600 characters as a rough heuristic).

### 3.2 HTML Stripping Strategy

A minimal HTML-to-text approach:

- Remove `<script>` and `<style>` blocks entirely (regex: `<script[^>]*>[\s\S]*?</script>`).
- Remove all remaining HTML tags (regex: `<[^>]+>`).
- Decode common HTML entities (`&amp;`, `&lt;`, `&gt;`, `&quot;`, `&#39;`, `&nbsp;`).
- Collapse multiple whitespace/newlines into single spaces.
- Trim the result.

This is intentionally simple. It will not perfectly parse every web page, but it produces usable text for the model to reason over.

### 3.3 Concurrency

- Fetch multiple pages concurrently using `TaskGroup` or `async let`.
- Set a per-request timeout (e.g., 10 seconds) to avoid blocking on slow servers.
- Limit concurrent fetches (e.g., max 5) to avoid resource exhaustion.

---

## 4. Reference Repositories

### 4.1 Dimillian/FoundationChat

- **URL**: https://github.com/Dimillian/FoundationChat
- **Author**: Thomas Ricouard (creator of IceCubesApp)
- **Relevance**: Demonstrates a chat interface built on top of FoundationModels. Shows session management, streaming responses, and SwiftUI integration patterns.
- **Key takeaways**: Message history management, streaming text display with `AsyncSequence`, error handling patterns.

### 4.2 rudrankriyam/Foundation-Models-Framework-Example

- **URL**: https://github.com/rudrankriyam/Foundation-Models-Framework-Example
- **Author**: Rudrank Riyam
- **Relevance**: Example project showcasing FoundationModels features including `@Generable`, tool calling, and structured output.
- **Key takeaways**: Tool protocol conformance patterns, `@Generable` struct design, session configuration.

### 4.3 Other Resources

- Apple's WWDC 2025 session "Meet the FoundationModels framework" and "Build app features powered by the Foundation Models framework."
- Apple's official FoundationModels documentation at developer.apple.com.
- Apple Intelligence overview and device compatibility pages.

---

## 5. App Store Guidelines for On-Device AI Apps

### 5.1 Relevant Guidelines

| Guideline | Requirement |
|---|---|
| **4.0 Design** | App must function as advertised. AI-generated content must be clearly labeled or its nature understood by the user. |
| **4.2 Minimum Functionality** | The app must provide genuine utility beyond what a simple web wrapper would offer. AISight's combination of search + on-device AI synthesis qualifies. |
| **5.1 Privacy** | Since FoundationModels runs on-device with no cloud AI service, AISight has a strong privacy story. Must still disclose any data collected (search queries go to SearXNG, web content is fetched). |
| **5.1.1 Data Collection and Storage** | Privacy nutrition label must list: search queries sent to SearXNG server, URLs fetched for content. No user data sent to third-party AI services. |
| **5.1.2 Data Use and Sharing** | SearXNG server URL is user-configurable. Default instance should be disclosed. |
| **2.3.1 In-App Purchase** | If the app is free with no IAP, no issues. |
| **1.4.1 Objectionable Content** | AI responses may occasionally produce unexpected content. AISight relies on Apple's built-in model safety guardrails. No additional content moderation layer is required for v1.0, but monitor user feedback. |

### 5.2 Privacy Nutrition Label

AISight's data practices for the App Store privacy label:

- **Data Linked to You**: None (AISight does not create user accounts or track identifiers).
- **Data Not Linked to You**: Search queries (sent to user-configured SearXNG instance). Usage data (if analytics are added later).
- **Data Used to Track You**: None.

### 5.3 Key Considerations

- Apple may scrutinize apps that use FoundationModels to ensure they do not circumvent Apple Intelligence safeguards.
- The app should not attempt to jailbreak or manipulate the system prompt to bypass safety features.
- The app should handle model unavailability gracefully (device not supported, model not downloaded, etc.).

---

## 6. Showstopper Analysis

### 6.1 Potential Showstoppers

| Risk | Severity | Mitigation | Verdict |
|---|---|---|---|
| 4K context window too small for useful answers | High | Aggressive truncation, max 5 sources at 400 tokens each, concise system prompt | **Manageable** — the design accounts for this |
| FoundationModels unavailable on older devices | Medium | Clear device requirements in App Store listing, graceful unavailability handling | **Acceptable** — this is a platform constraint, not a bug |
| SearXNG public instances unreliable | Medium | User-configurable URL, encourage self-hosting, availability ping on launch | **Manageable** — user controls this |
| HTML stripping produces poor text extraction | Medium | Good enough for v1.0; can improve with better parsing later | **Manageable** |
| Apple rejects app for AI-related policy | Low | App uses Apple's own framework as intended; strong privacy story | **Low risk** |
| On-device model hallucinates despite grounding | Medium | Citation requirement in system prompt, disclaimer to user | **Manageable** — inherent to any LLM |
| FoundationModels API changes before iOS 26 GA | Low | Framework was announced at WWDC 2025; API is expected to be stable by GA | **Low risk** |

### 6.2 Verdict

**No showstoppers identified.** All risks are manageable with the architectural decisions documented in ARCHITECTURE.md. The primary engineering challenge is maximizing answer quality within the tight 4K context window, which the design addresses through careful token budgeting and source truncation.

---

## 7. References

1. Apple Developer Documentation — FoundationModels Framework
2. WWDC 2025 — "Meet the FoundationModels framework"
3. WWDC 2025 — "Build app features powered by the Foundation Models framework"
4. SearXNG Documentation — https://docs.searxng.org/
5. SearXNG API Documentation — https://docs.searxng.org/dev/search_api.html
6. Dimillian/FoundationChat — https://github.com/Dimillian/FoundationChat
7. rudrankriyam/Foundation-Models-Framework-Example — https://github.com/rudrankriyam/Foundation-Models-Framework-Example
8. Apple App Store Review Guidelines — https://developer.apple.com/app-store/review/guidelines/
