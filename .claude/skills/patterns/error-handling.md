# Error Handling Patterns

> When to load: Adding/modifying error types or user-facing error messages.

## Overview

AISight has a layered error handling strategy: framework errors are caught at the service layer, mapped to domain-specific error enums, then converted to user-facing strings at the view model layer. Failures are graceful — the app degrades rather than crashes.

## Error Types

### SearchError (Core/Search/SearchError.swift)

| Case | Trigger |
|------|---------|
| `.serverUnavailable` | Connection errors, non-2xx HTTP |
| `.timeout` | `URLError.timedOut` |
| `.noResults` | SearXNG returns empty results after processing |
| `.invalidResponse` | JSON decode failure, bad URLComponents |

### AnswerError (Core/AI/AnswerSession.swift)

| Case | Trigger |
|------|---------|
| `.searchFailed(SearchError)` | Wraps search-layer errors |
| `.generationFailed(String)` | Most `GenerationError` cases |
| `.modelUnavailable` | `GenerationError.assetsUnavailable` |
| `.contentPolicy` | `GenerationError.guardrailViolation` or `.refusal` |

### LanguageModelSession.GenerationError (Apple framework)

| Case | Maps To |
|------|---------|
| `.guardrailViolation` | `AnswerError.contentPolicy` |
| `.exceededContextWindowSize` | `.generationFailed("The query is too long...")` |
| `.unsupportedLanguageOrLocale` | `.generationFailed("This language is not supported...")` |
| `.rateLimited` | `.generationFailed("...rate limited...")` |
| `.assetsUnavailable` | `.modelUnavailable` |
| `.concurrentRequests` | `.generationFailed("Another request is in progress...")` |
| `.refusal` | `.contentPolicy` |
| `.unsupportedGuide` | `.generationFailed(...)` |
| `.decodingFailure` | `.generationFailed(...)` |

## Error Flow

```
SearXNGService throws SearchError
    ↓
SearchViewModel catches → userFacingMessage(for: SearchError) → errorMessage

LanguageModelSession throws GenerationError
    ↓
AnswerSession catches → maps to AnswerError → sets self.error
    ↓
SearchViewModel reads answerSession.error → userFacingMessage(for: AnswerError) → errorMessage
```

## User-Facing Messages

| Error | Message |
|-------|---------|
| serverUnavailable / invalidResponse | "Search server is unavailable. Check your connection or update the server URL in Settings." |
| timeout | "Search took too long. The server may be overloaded — try again in a moment." |
| noResults | "No sources found for this query. Try rephrasing." |
| modelUnavailable | "AISight requires Apple Intelligence. Enable it in Settings → Apple Intelligence & Siri." |
| contentPolicy | "This query can't be answered on-device. Try a different question." |
| URLError.notConnectedToInternet | "Connect to the internet to search. Previously answered questions are available in History." |
| Empty model response | "The model returned an empty response. Try rephrasing your question." |
| generationFailed(msg) | "An error occurred while generating the answer: {msg}" |

## Graceful Degradation

| Failure | Fallback |
|---------|----------|
| Full page fetch fails for a source | Uses SearXNG snippet instead |
| All page fetches fail | Answer generated from snippets only |
| SwiftData save fails | Answer still displayed; error printed to console |
| Some search engines unresponsive | Results from remaining engines still used |
| Model returns empty | User sees "empty response" message, can retry |

## Rules

1. **Never crash on errors** — always catch and display user-facing message
2. **SearchViewModel is the single error display point** — `errorMessage: String?`
3. **Non-blocking persistence** — save failures don't affect the answer display
4. **No retry logic** in v1.0 — failures surface immediately with clear messaging
5. **Content fetch failures are silent** — falls back to snippet without user notification
