# AISight — Technical Architecture

> Last updated: 2026-03-11

---

## 1. Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | Swift 6.1+ | Strict concurrency, async/await throughout |
| UI Framework | SwiftUI | iOS 26+ features, native look and feel |
| AI Framework | FoundationModels | Apple's on-device LLM framework (iOS 26+) |
| Search Backend | SearXNG JSON API | Self-hosted or public instance, user-configurable |
| Persistence | SwiftData | Local storage for query history and settings |
| Networking | URLSession (async/await) | Standard Apple networking, no third-party deps |
| Minimum Target | iOS 26.0 | Requires Apple Intelligence capable device |
| Dependencies | None (first-party only) | Zero external package dependencies for v1.0 |

---

## 2. AppConfig Design

`AppConfig.swift` serves as the centralized configuration for the app. It provides sensible defaults while allowing user overrides for key settings.

### Structure

```swift
struct AppConfig {
    // MARK: - SearXNG Configuration
    static let defaultSearXNGBaseURL = "https://searxng.example.com"
    static let searchEngines = "google,bing,duckduckgo"
    static let maxResults = 5
    static let searchTimeout: TimeInterval = 10.0
    static let searchLanguage = "en"
    static let searchCategories = "general"

    // MARK: - Content Fetching
    static let contentFetchTimeout: TimeInterval = 10.0
    static let maxConcurrentFetches = 5
    static let maxTokensPerSource = 400
    static let maxCharactersPerSource = 1600  // ~400 tokens heuristic

    // MARK: - AI Configuration
    static let maxSources = 5
    static let systemPromptTokenBudget = 500
    static let answerTokenBudget = 1000

    // MARK: - Availability
    static let searxngPingTimeout: TimeInterval = 5.0
    static let searxngPingPath = "/healthz"  // or just "/"
}
```

### User-Configurable Settings (via SwiftData)

| Setting | Stored In | Default |
|---|---|---|
| SearXNG Base URL | `UserSettings` model | `AppConfig.defaultSearXNGBaseURL` |
| Search Language | `UserSettings` model | `AppConfig.searchLanguage` |

These are persisted in SwiftData and take precedence over `AppConfig` defaults when set.

---

## 3. Core Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        USER INTERFACE                                │
│  ┌──────────┐   ┌──────────────┐   ┌──────────┐   ┌─────────────┐  │
│  │ QueryView │   │ AnswerView   │   │History  │   │ SettingsView│  │
│  │          │   │ (streaming)  │   │ View     │   │            │  │
│  └────┬─────┘   └──────▲───────┘   └──────────┘   └────────────┘  │
│       │                │                                            │
├───────┼────────────────┼────────────────────────────────────────────┤
│       │    ORCHESTRATION│                                            │
│       ▼                │                                            │
│  ┌─────────────────────┴──────────────────────────────────┐        │
│  │                  QueryProcessor                         │        │
│  │  Coordinates the full pipeline for a single query       │        │
│  └──┬──────────┬───────────────────┬──────────────────────┘        │
│     │          │                   │                                │
├─────┼──────────┼───────────────────┼────────────────────────────────┤
│     │  SERVICE │LAYER              │                                │
│     ▼          ▼                   ▼                                │
│  ┌────────┐ ┌──────────────┐ ┌─────────────────────────────┐      │
│  │SearXNG │ │Content       │ │AnswerSession                │      │
│  │Service │ │Fetcher       │ │(LanguageModelSession + Tools)│      │
│  └───┬────┘ └──────┬───────┘ └──────────┬──────────────────┘      │
│      │             │                     │                          │
│      │             │                     ▼                          │
│      │             │              ┌──────────────┐                  │
│      │             │              │Citation      │                  │
│      │             │              │Extractor     │                  │
│      │             │              └──────┬───────┘                  │
│      │             │                     │                          │
├──────┼─────────────┼─────────────────────┼──────────────────────────┤
│      │  PERSISTENCE│                     │                          │
│      │             │                     ▼                          │
│      │             │              ┌──────────────┐                  │
│      │             │              │SwiftData     │                  │
│      │             │              │(History)     │                  │
│      │             │              └──────────────┘                  │
├──────┼─────────────┼────────────────────────────────────────────────┤
│      │   NETWORK   │                                                │
│      ▼             ▼                                                │
│  ┌──────────────────────┐                                          │
│  │  URLSession           │                                          │
│  │  (SearXNG + Web pages)│                                          │
│  └──────────────────────┘                                          │
└─────────────────────────────────────────────────────────────────────┘
```

### Step-by-Step Flow

1. **User Query** — The user types a question in `QueryView` and taps "Ask."

2. **QueryProcessor** — Receives the raw query string. Orchestrates the full pipeline:
   - Sends query to `SearXNGService`.
   - Passes top results to `ContentFetcher`.
   - Constructs the prompt with fetched content.
   - Creates an `AnswerSession` and streams the response.
   - Passes the response to `CitationExtractor`.
   - Persists the query and answer to SwiftData.

3. **SearXNGService** — Builds and executes the SearXNG API request. Returns an array of `SearchResult` models (url, title, snippet, score, engine). Handles errors, timeouts, and empty results.

4. **ContentFetcher** — Takes the top N search result URLs (max 5). Fetches each page concurrently via `URLSession`. Strips HTML tags. Truncates text to the per-source token budget (~400 tokens / ~1,600 characters). Returns an array of `FetchedSource` models.

5. **AnswerSession** — Creates a `LanguageModelSession` with:
   - A system prompt (see Section 8).
   - The user's query.
   - Source content injected as context.
   - Tool definitions (if using the tool-calling pattern).
   - Calls `streamResponse(to:)` and yields partial tokens to the UI.

6. **StreamingAnswer** — The UI (`AnswerView`) observes the async stream and appends tokens as they arrive, providing real-time feedback.

7. **CitationExtractor** — Parses the completed answer to identify citation markers (e.g., `[1]`, `[2]`) and maps them to the corresponding `SearchResult` URLs and titles.

8. **SwiftData** — The completed `QueryRecord` (query text, answer text, citations, timestamp) is persisted for the history view.

---

## 4. Component List

### 4.1 Models

| Model | Storage | Description |
|---|---|---|
| `QueryRecord` | SwiftData | A persisted query: question text, answer text, citations, timestamp |
| `Citation` | SwiftData (embedded) | A single citation: source number, URL, title, snippet |
| `UserSettings` | SwiftData | User preferences: SearXNG base URL, language |
| `SearchResult` | In-memory | A single SearXNG result: url, title, content, score, engine |
| `FetchedSource` | In-memory | Fetched and processed page: url, title, plainText, truncated flag |

### 4.2 Services

| Service | Description |
|---|---|
| `SearXNGService` | Handles all communication with the SearXNG JSON API. Builds requests, parses responses, handles errors. |
| `ContentFetcher` | Fetches web page content via URLSession. Strips HTML. Truncates to token budget. Handles timeouts and failures per-URL. |
| `AnswerSession` | Wraps `LanguageModelSession`. Configures system prompt, manages context, streams responses. |
| `CitationExtractor` | Parses generated answer text to extract citation markers and map them to sources. |
| `QueryProcessor` | Top-level orchestrator. Coordinates the full query pipeline from input to persisted result. |
| `SearXNGAvailabilityMonitor` | Pings the configured SearXNG instance on launch and periodically. Publishes availability state. |

### 4.3 Views

| View | Description |
|---|---|
| `QueryView` | Main screen. Text input field, "Ask" button, displays streaming answer. |
| `AnswerView` | Displays the streamed answer with formatted citations. Embedded in or presented from QueryView. |
| `HistoryView` | List of past queries with timestamps. Tap to view the full answer. |
| `SettingsView` | Configure SearXNG URL, view connection status, app info. |
| `CitationCardView` | A compact card showing a source's title, URL, and snippet. Tappable to open in Safari. |
| `SearXNGStatusBanner` | A banner displayed when SearXNG is unreachable. Includes a "Configure" button linking to Settings. |

### 4.4 Utilities

| Utility | Description |
|---|---|
| `HTMLStripper` | Static methods to remove HTML tags, scripts, styles, and decode entities from raw HTML. |
| `TokenEstimator` | Rough token count estimation (characters / 4 heuristic) for context window budgeting. |
| `AppConfig` | Centralized compile-time configuration constants. |

---

## 5. SearXNG API Contract

### 5.1 Request

```
GET {userSettings.searxngBaseURL}/search
```

**Query Parameters:**

| Parameter | Value | Source |
|---|---|---|
| `q` | User's query (URL-encoded) | User input |
| `format` | `json` | Hardcoded |
| `engines` | `google,bing,duckduckgo` | `AppConfig.searchEngines` |
| `language` | `en` | `UserSettings.language` or `AppConfig.searchLanguage` |
| `pageno` | `1` | Hardcoded for v1.0 |
| `categories` | `general` | `AppConfig.searchCategories` |

**Headers:**

| Header | Value |
|---|---|
| `Accept` | `application/json` |
| `User-Agent` | `AISight/1.0` |

**Timeout:** `AppConfig.searchTimeout` (10 seconds)

### 5.2 Response

**Success (HTTP 200):**

```json
{
  "query": "what is the capital of france",
  "number_of_results": 54200000,
  "results": [
    {
      "url": "https://en.wikipedia.org/wiki/Paris",
      "title": "Paris - Wikipedia",
      "content": "Paris is the capital and largest city of France...",
      "engine": "google",
      "engines": ["google", "bing", "duckduckgo"],
      "score": 9.0,
      "category": "general",
      "positions": [1, 1, 1]
    }
  ],
  "suggestions": [],
  "unresponsive_engines": []
}
```

**AISight uses these fields from each result:**

| Field | Used For |
|---|---|
| `url` | ContentFetcher target, citation link |
| `title` | Display in CitationCardView, citation label |
| `content` | Fallback snippet if page fetch fails |
| `score` | Ranking/selecting top N results |

**Error handling:**

| HTTP Status | AISight Behavior |
|---|---|
| 200 | Parse results, proceed with pipeline |
| 429 | Rate limited — show "Search temporarily unavailable, try again shortly" |
| 500/502/503 | Server error — show "Search service error" with retry option |
| Timeout | Show "Search timed out" with retry option |
| Network error | Show "No internet connection" or "SearXNG unreachable" |

### 5.3 Response Parsing (Swift)

```swift
struct SearXNGResponse: Codable {
    let query: String
    let numberOfResults: Int?
    let results: [SearXNGResult]
    let suggestions: [String]?
    let unresponsiveEngines: [String]?

    enum CodingKeys: String, CodingKey {
        case query
        case numberOfResults = "number_of_results"
        case results
        case suggestions
        case unresponsiveEngines = "unresponsive_engines"
    }
}

struct SearXNGResult: Codable {
    let url: String
    let title: String
    let content: String?
    let engine: String?
    let engines: [String]?
    let score: Double?
    let category: String?
    let positions: [Int]?
}
```

---

## 6. SearXNG Availability Handling

### 6.1 Ping on Launch

When the app launches, `SearXNGAvailabilityMonitor` sends a lightweight request to the configured SearXNG base URL:

```
GET {baseURL}/
```

- Timeout: `AppConfig.searxngPingTimeout` (5 seconds).
- A successful HTTP response (any 2xx status) means the instance is reachable.
- The result is published via a `@Observable` property for SwiftUI to react to.

### 6.2 Banner When Unreachable

If the ping fails, a `SearXNGStatusBanner` is displayed at the top of `QueryView`:

- Message: "Search service is not reachable. Check your SearXNG URL in Settings."
- A "Settings" button navigates to `SettingsView`.
- The banner is dismissible but reappears on next launch if still unreachable.
- The user can still attempt queries — the error will be handled gracefully at the `SearXNGService` level.

### 6.3 Settings Status Indicator

In `SettingsView`, the SearXNG URL field shows a status indicator:

| State | Indicator |
|---|---|
| Reachable | Green circle with "Connected" label |
| Unreachable | Red circle with "Unreachable" label |
| Checking | Gray spinning indicator with "Checking..." label |
| Not configured | Orange circle with "Not set" label |

A "Test Connection" button triggers an on-demand ping.

### 6.4 Periodic Re-check

The availability monitor re-checks when:
- The app returns to the foreground (via `scenePhase` change).
- The user changes the SearXNG URL in settings.
- The user taps "Test Connection."

There is no background polling timer — checks are event-driven.

---

## 7. Tool-Calling Architecture

### 7.1 Overview

AISight uses the FoundationModels tool-calling API to let the on-device model request web search results during generation. This is an alternative to pre-fetching all content before invoking the model.

### 7.2 Tool Definition

```swift
struct WebSearchTool: Tool {
    let name = "web_search"
    let description = "Search the web for information about a topic. Returns titles, URLs, and content snippets from top results."

    struct Arguments: Codable {
        let query: String
    }

    struct Result: Codable {
        let sources: [SourceSnippet]
    }

    struct SourceSnippet: Codable {
        let title: String
        let url: String
        let content: String
    }

    func call(arguments: Arguments) async throws -> Result {
        let results = try await SearXNGService.shared.search(query: arguments.query)
        let fetched = try await ContentFetcher.shared.fetch(results: results)
        let snippets = fetched.map { SourceSnippet(title: $0.title, url: $0.url, content: $0.plainText) }
        return Result(sources: snippets)
    }
}
```

### 7.3 Hybrid Approach (Recommended for v1.0)

Given the small context window, v1.0 uses a **pre-fetch** approach rather than tool calling:

1. Search and fetch content **before** invoking the model.
2. Inject the fetched content directly into the prompt.
3. The model generates an answer grounded in the provided content.

This is simpler and more predictable than tool calling, which would consume context window tokens for the tool-call round-trip. Tool calling can be explored in a future version if Apple ships models with larger context windows.

---

## 8. System Prompt Design

### 8.1 System Prompt

The system prompt is passed as the `instructions` parameter when creating the `LanguageModelSession`:

```
You are AISight, a helpful assistant that answers questions using web sources.

Rules:
1. Answer the user's question using ONLY the provided sources below.
2. Cite your sources using numbered references like [1], [2], etc.
3. If the sources do not contain enough information to answer, say so honestly.
4. Keep your answer concise — aim for 2-4 sentences unless more detail is clearly needed.
5. Do not make up information that is not in the sources.
6. Do not include URLs in your answer text — use citation numbers only.

Sources will be provided in the following format:
[1] Title: <title>
URL: <url>
Content: <text>
```

### 8.2 Prompt Assembly

The full prompt sent to the model is assembled as follows:

```
[System prompt — via session instructions, ~150 tokens]

[User message — assembled by QueryProcessor:]
Question: <user's query>

Sources:
[1] Title: <title>
URL: <url>
Content: <truncated plain text, ~400 tokens>

[2] Title: <title>
URL: <url>
Content: <truncated plain text, ~400 tokens>

... (up to 5 sources)
```

### 8.3 Token Budget Breakdown

| Component | Budget | Notes |
|---|---|---|
| System prompt (instructions) | ~150 tokens | Kept minimal |
| User query | ~100 tokens | Most questions are short |
| Source content (up to 5 sources) | ~2,000 tokens | 5 x 400 tokens per source |
| Generated answer | ~1,000 tokens | Remaining context window space |
| Overhead (formatting, markers) | ~250 tokens | Source labels, newlines, etc. |
| **Total** | **~3,500 tokens** | Fits within ~4K window |

If the user's query is unusually long, the number of sources or per-source budget is reduced proportionally.

---

## 9. Context Window Management

### 9.1 Strategy

The 4K token context window is the primary architectural constraint. The management strategy:

1. **Fixed budget allocation** — Each component of the prompt has a pre-allocated token budget (see Section 8.3).

2. **Token estimation** — Use a simple heuristic: 1 token ≈ 4 characters. This is a rough approximation but sufficient for budgeting. The `TokenEstimator` utility provides this.

3. **Source truncation** — Each source's plain text is truncated to `AppConfig.maxCharactersPerSource` (1,600 characters ≈ 400 tokens). Truncation happens at a sentence boundary when possible (find the last period before the limit). A `[truncated]` marker is appended.

4. **Source selection** — Only the top `AppConfig.maxSources` (5) results by SearXNG score are used. If fewer results are returned, fewer sources are included.

5. **Adaptive source count** — If the user's query is long (> 100 tokens estimated), reduce the number of sources to 3 to leave room for the answer.

6. **No conversation history** — v1.0 does not carry prior conversation turns into the context. Each query gets a fresh session. This maximizes available space for source content and the answer.

### 9.2 Truncation Algorithm

```
function truncateToTokenBudget(text, maxTokens):
    maxChars = maxTokens * 4
    if length(text) <= maxChars:
        return text

    truncated = text[0..maxChars]
    lastSentenceEnd = lastIndexOf(truncated, ". ")
    if lastSentenceEnd > maxChars * 0.5:
        truncated = truncated[0..lastSentenceEnd + 1]

    return truncated + " [truncated]"
```

### 9.3 Fallback: Snippet-Only Mode

If content fetching fails for all sources (e.g., all URLs time out), the system falls back to using SearXNG's `content` field (the search snippet) as the source text. These snippets are typically 1-2 sentences and consume far fewer tokens, but provide less context for the model to work with.

---

## 10. Error Handling Strategy

| Error Scenario | Handling |
|---|---|
| SearXNG unreachable | Show banner. Allow retry. Suggest checking Settings. |
| SearXNG returns 0 results | Display "No results found. Try rephrasing your question." |
| All content fetches fail | Fall back to snippet-only mode. Answer may be less detailed. |
| Some content fetches fail | Proceed with successfully fetched sources. |
| FoundationModels unavailable | Display "On-device AI is not available. Please ensure Apple Intelligence is enabled in Settings." |
| Model generation fails | Display "Unable to generate an answer. Please try again." |
| Model generation produces empty output | Display "The AI could not produce an answer for this question." |
| SwiftData save fails | Log error. The answer is still displayed but not persisted. Non-blocking. |
| Network lost mid-query | Cancel in-flight requests. Display appropriate error based on which stage failed. |

---

## 11. Project Structure

```
AISight/
├── AISightApp.swift              # App entry point, SwiftData container setup
├── AppConfig.swift               # Centralized configuration constants
│
├── Models/
│   ├── QueryRecord.swift         # SwiftData model for persisted queries
│   ├── Citation.swift            # Citation model (embedded in QueryRecord)
│   ├── UserSettings.swift        # SwiftData model for user preferences
│   ├── SearchResult.swift        # In-memory model for SearXNG results
│   └── FetchedSource.swift       # In-memory model for fetched page content
│
├── Services/
│   ├── QueryProcessor.swift      # Pipeline orchestrator
│   ├── SearXNGService.swift      # SearXNG API client
│   ├── ContentFetcher.swift      # Web page fetcher + HTML stripper
│   ├── AnswerSession.swift       # LanguageModelSession wrapper
│   ├── CitationExtractor.swift   # Citation parsing from model output
│   └── SearXNGAvailabilityMonitor.swift  # Ping and availability state
│
├── Views/
│   ├── QueryView.swift           # Main query input screen
│   ├── AnswerView.swift          # Streaming answer display
│   ├── HistoryView.swift         # Query history list
│   ├── SettingsView.swift        # SearXNG URL config, status
│   ├── CitationCardView.swift    # Individual source card
│   └── SearXNGStatusBanner.swift # Unreachable warning banner
│
├── Utilities/
│   ├── HTMLStripper.swift        # HTML tag removal and entity decoding
│   └── TokenEstimator.swift      # Rough token count estimation
│
├── RESEARCH.md                   # Research findings
├── SCOPE.md                      # Product scope document
└── ARCHITECTURE.md               # This file
```

---

## 12. Key Design Decisions

| Decision | Rationale |
|---|---|
| Zero third-party dependencies | Reduces App Store review friction, eliminates supply chain risk, keeps binary small. Apple's frameworks cover all needs. |
| Pre-fetch over tool calling | More predictable context window usage. Tool calling adds round-trip overhead that consumes tokens. |
| Per-query fresh session | Avoids context window exhaustion from accumulated conversation history. Each query gets maximum available space. |
| User-configurable SearXNG URL | Respects user privacy. Users can self-host. No single point of failure. |
| Aggressive source truncation | The 4K context window demands it. 400 tokens per source is enough for the model to extract key facts. |
| Snippet fallback mode | Ensures the app can still provide answers even when web page fetching fails. Degrades gracefully. |
| SwiftData over UserDefaults for history | Structured queries, proper querying, and future extensibility (tags, favorites, etc.). |
| Streaming by default | Immediate user feedback. On-device generation is fast but not instant; streaming makes it feel responsive. |
