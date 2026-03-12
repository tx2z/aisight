# AISight Development Log

## What Was Built

AISight is a complete iOS 26 / macOS 26 answer engine that combines self-hosted web search (SearXNG) with on-device AI (Apple Intelligence via FoundationModels). The user types a question, the app searches the web, fetches and processes source content, then streams a cited answer — all with AI inference running privately on-device.

### Core features shipped:
- SearXNG integration for web search (aggregating Google, Bing, DuckDuckGo, Brave)
- On-device answer generation via FoundationModels with token-by-token streaming
- Inline citation rendering with numbered badges mapping to sources
- Source cards with engine badges and tap-to-open
- Content fetching pipeline (snippet-only fast path + full page fetch for deeper queries)
- Query history with SwiftData persistence
- Settings screen with custom SearXNG URL and "Test Connection" with latency display
- First-launch onboarding flow
- Dark mode / light mode support
- iOS 26 liquid glass design language

---

## Architecture Decisions

### Why SearXNG over direct search APIs?

Direct APIs (Google Custom Search, Bing Web Search) require API keys, have rate limits, and cost money per query. SearXNG is free, self-hosted, and aggregates multiple engines — giving better coverage without vendor lock-in. The user owns their search infrastructure. The tradeoff is that the user must deploy and maintain a SearXNG instance, but this keeps AISight independent of any commercial search provider.

### Why on-device AI instead of cloud LLMs?

Privacy is the core value proposition. Users ask personal, sensitive, and wide-ranging questions. Sending those to OpenAI/Anthropic/Google cloud APIs means the user's query data leaves their device and enters third-party systems. With Apple Intelligence and FoundationModels, all inference runs on the Neural Engine locally. The tradeoff is a smaller model (~3B parameters) with a limited 4,096 token context window, which means answers are less sophisticated than GPT-4 class models. For the target use case (factual Q&A with web sources), this is an acceptable tradeoff.

### Why SwiftData for history?

SwiftData is Apple's modern persistence framework and integrates natively with SwiftUI. It requires minimal boilerplate compared to Core Data, supports automatic schema migration, and keeps everything in the Apple ecosystem. For a simple history feature (query text, answer text, timestamp, sources), SwiftData is the right tool — no need for SQLite directly or third-party ORMs.

---

## Design Decisions

### KISS approach

The app follows a "Keep It Simple" philosophy throughout. There is one screen for searching, one for history, and one for settings. No complex navigation hierarchies, no nested tabs, no drawer menus. The user types a question and gets an answer.

### Standard Apple components

Rather than building custom UI components, AISight uses standard SwiftUI views wherever possible: `NavigationStack`, `TabView`, `List`, `TextField`, `ProgressView`. This ensures the app feels native, gets accessibility for free, and benefits from future SwiftUI improvements.

### Liquid glass design

iOS 26 introduced the liquid glass visual style. AISight adopts it for the tab bar and navigation elements to feel contemporary and platform-native. No custom theming or color overrides — the app respects the system appearance.

### No custom theme or brand colors

Deliberately avoided custom accent colors, branded headers, or visual identity beyond the app icon. This keeps the focus on content (the answer and sources) rather than chrome. The app looks like a well-built utility, not a brand experience.

---

## Shortcuts Taken

### No unit tests yet

The priority was shipping a functional app. The service layer (`SearXNGService`, `ContentFetcher`, `AnswerGenerator`) is structured to be testable — protocols and dependency injection are in place — but no `XCTest` targets exist yet. This is the highest-priority technical debt.

### Basic HTML stripping

Content fetched from web pages goes through a basic HTML tag stripping approach rather than proper DOM parsing. This works for most pages but can produce garbled output on JavaScript-heavy sites or pages with complex nested markup. A more robust solution would use `AttributedString` HTML parsing or a lightweight HTML-to-text library.

### No full Xcode project file

The Swift source files are organized by directory, but there is no `.xcodeproj` or `Package.swift` checked in. The project needs to be created in Xcode or converted to a Swift Package to build. This was a conscious shortcut to focus on code rather than project configuration during initial development.

### Hardcoded timeouts

Network timeouts (8 seconds for SearXNG, 5 seconds per page fetch) are hardcoded in the service layer rather than being configurable. For most users this is fine, but users with slow SearXNG instances or high-latency networks may hit timeouts unnecessarily.

### No retry logic

If a SearXNG request or page fetch fails, it fails. There is no retry with backoff. For a v1, this keeps complexity low, but it means transient network errors surface as user-facing failures.

---

## What's Most Important Next

### 1. Add the Xcode project file or convert to Swift Package

Without a `.xcodeproj` or `Package.swift`, nobody can build the app from a fresh clone. This is the most critical gap. Either generate the Xcode project and check it in, or define a `Package.swift` with the correct targets and dependencies.

### 2. Write unit tests for SearXNGService and ContentFetcher

These are the two most critical services. `SearXNGService` parses JSON from SearXNG and should be tested against real response fixtures. `ContentFetcher` strips HTML and should be tested against various page structures. Mock `URLSession` with `URLProtocol` for deterministic tests.

### 3. Add proper @Toolable tool calling

Currently the app always searches, fetches, and answers in a fixed pipeline. With `@Toolable` from FoundationModels, the model could decide *when* to search, *what* to search for, and whether a follow-up search is needed. This would enable multi-hop reasoning within the on-device model's capabilities.

### 4. Improve HTML content extraction

The current regex-based tag stripping is fragile. Better approaches:
- Use `NSAttributedString` with HTML import for simple pages
- Use `AttributedString(html:)` available in newer Foundation versions
- Consider a lightweight Swift HTML parser like SwiftSoup (though this adds a dependency)

### 5. Add conversation follow-up support

Currently each query is independent. Adding follow-up support means maintaining conversation context across turns. This requires careful context window management given the 4,096 token limit — likely summarizing previous turns before adding new search results.

---

## Known Issues to Watch For

- **Context window overflow:** When many sources are fetched, the combined prompt can exceed 4,096 tokens. The current truncation is simple (cut from the end). A smarter approach would prioritize the most relevant sources.

- **SearXNG rate limiting:** Some upstream engines (Google, Bing) may rate-limit the SearXNG instance if query volume is high. Users may see degraded results without a clear error message.

- **FoundationModels availability:** Apple Intelligence is not available in all regions and requires specific device hardware. The error handling for "model not available" needs to cover edge cases (e.g., device supported but user hasn't enabled Apple Intelligence, or device in unsupported region).

- **Memory usage on long sessions:** SwiftData history entries include full answer text. Over hundreds of queries, memory usage during history list rendering could grow. Consider lazy loading or pagination if this becomes an issue.

- **Content fetching blocked by sites:** Many websites block or challenge non-browser User-Agents. The current `URLSession` requests may get 403s or CAPTCHAs from sites like Reddit, StackOverflow, or news paywalls. A future improvement could use a more browser-like User-Agent or fall back to snippets when full fetch fails.

---

*Last updated: March 2026*
