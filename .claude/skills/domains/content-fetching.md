# Content Fetching Domain

> When to load: Modifying ContentFetcher, HTML stripping, or content truncation logic.

## Overview

`ContentFetcher` is an actor that fetches web page content, strips HTML to plain text, and truncates to a character budget. It's used by `AnswerSession` to enrich search results with full page content when SearXNG snippets are too short.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| ContentFetcher.swift | `ContentFetcher` (actor) | `AISight/AISight/Core/Fetching/` |

## ContentFetcher API

### Init

```swift
ContentFetcher(
    timeout: TimeInterval = 10,         // per-request timeout
    snippetThreshold: Int = 150,        // chars below which to fetch full page
    maxSnippetLength: Int = 1600        // truncation limit (~400 tokens)
)
```

Creates its own `URLSession` with custom timeout configuration (not `URLSession.shared`).

### fetchContent(from: String) -> String

1. Validate URL
2. Fetch via `urlSession.data(from:)`
3. Validate HTTP 2xx
4. Decode as UTF-8 (fallback ASCII)
5. Strip HTML → truncate → return clean text

### shouldFetchFullContent(snippet: String) -> Bool

Returns `true` if `snippet.count < snippetThreshold` (150).

## HTML Stripping Pipeline

1. **Remove block elements with content:**
   - `<script>...</script>`
   - `<style>...</style>`
   - `<nav>...</nav>`
   - `<header>...</header>`
   - `<footer>...</footer>`
2. **Remove all remaining tags:** regex `<[^>]+>`
3. **Decode HTML entities:** `&amp;` `&lt;` `&gt;` `&quot;` `&#39;` `&nbsp;`
4. **Collapse whitespace:** regex `\s+` → single space
5. **Trim** leading/trailing whitespace

### Known Limitations

- Regex-based — doesn't parse DOM properly
- JavaScript-rendered content won't be extracted
- Complex nested markup may produce garbled output
- Only 6 HTML entities decoded — others pass through as-is
- No sentence-boundary-aware truncation (simple prefix cut)

## Actor Isolation

`ContentFetcher` is an `actor`, not a `class`. This means:
- All method calls from `@MainActor` code require `await`
- Internal state (URLSession, config) is safely isolated
- No need for locks or `@Sendable` closures

## Truncation

Simple `String.prefix(maxLength)` — no sentence boundary detection. This can cut mid-word or mid-sentence. The DEVLOG notes this as an improvement area.

## Important Constraints

- Actor isolation: calls from AnswerSession (which is @MainActor) cross isolation boundaries
- Creates its own URLSession (not shared) — has its own timeout config
- Sequential fetching in AnswerSession (for loop, not TaskGroup)
- Max 5 pages fetched (controlled by `AppConfig.maxResults`)

## Testing

`stripHTML()`, `removeTagBlock()`, and `truncate()` are `internal` (not private) for `@testable import` access. Test coverage in `ContentFetcherTests` (17 tests) covering HTML stripping, entity decoding, tag block removal, truncation, and `shouldFetchFullContent` threshold.

## Common Modifications

**Improving HTML stripping:** Replace regex approach with `AttributedString(html:)` or a proper parser. Keep it within system frameworks (no SwiftSoup).

**Adding sentence-boundary truncation:** Find last `. ` before limit, cut there. Add `[truncated]` marker.

**Parallel fetching:** Replace the for loop in AnswerSession with `TaskGroup` or `async let`.

**Adding caching:** Cache fetched content by URL to avoid re-fetching.
