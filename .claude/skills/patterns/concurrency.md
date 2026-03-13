# Concurrency Patterns

> When to load: Working with async/await, actors, @MainActor, Sendable, or task cancellation.

## Overview

AISight targets Swift 6 strict concurrency. Every `@Observable` class used by SwiftUI is `@MainActor`. `ContentFetcher` is an actor. `SearXNGService` is `Sendable`. Task cancellation is cooperative via `Task.isCancelled` checks.

## @MainActor on @Observable Classes

**All** `@Observable` classes that feed SwiftUI views are `@MainActor`:

| Class | Reason |
|-------|--------|
| `AnswerSession` | `streamingText` and `isGenerating` drive UI updates |
| `SearchViewModel` | `query`, `sources`, `errorMessage` bound to views |
| `AppState` | `serverAvailable`, `hasSeenOnboarding` observed by views |
| `QueryHistoryStore` | Used from @MainActor SearchViewModel |

**Do NOT remove `@MainActor`** from these classes. Swift 6 strict concurrency requires it for `@Observable` properties accessed from SwiftUI views.

## Actor Isolation: ContentFetcher

`ContentFetcher` is an `actor` (not a class):

```swift
actor ContentFetcher {
    private let urlSession: URLSession  // isolated state
    func fetchContent(from url: String) async throws -> String
    func shouldFetchFullContent(snippet: String) -> Bool
}
```

- Isolates its `URLSession` and config from concurrent access
- Calls from `@MainActor` code (e.g., AnswerSession) require `await`
- No locks or `@Sendable` closures needed

## Sendable: SearXNGService

```swift
final class SearXNGService: SearchService, Sendable
```

- `Sendable` because it has **no mutable stored state**
- Uses `URLSession.shared` (which is Sendable)
- Per-request timeout set on `URLRequest`, not on a stored session
- Safe to call from any isolation domain

## Task Cancellation

`SearchViewModel` manages the active search task:

```swift
private var currentTask: Task<Void, Never>?

func performSearch(modelContext:) {
    currentTask?.cancel()       // cancel previous
    currentTask = Task {
        // ... each stage checks:
        guard !Task.isCancelled else { return }
    }
}
```

Cancellation is checked at these stage boundaries:
1. After SearXNG search completes
2. Before building the prompt (in AnswerSession)
3. Inside the streaming loop (each chunk)
4. After streaming completes

## Conditional Compilation

```swift
#if canImport(FoundationModels)
import FoundationModels
#endif
```

Used in `SearchViewModel` and `AppState` to enable compilation when FoundationModels SDK is unavailable (e.g., older Xcode).

`@available(iOS 26.0, macOS 26.0, *)` is required on:
- `AnswerSession` (uses `LanguageModelSession`)
- `SearchViewModel` (owns `AnswerSession`)

## No Parallel Content Fetching

Content fetching in `AnswerSession.generateAnswer()` is sequential:

```swift
for (i, result) in searchOutput.results.prefix(maxResults).enumerated() {
    if await contentFetcher.shouldFetchFullContent(snippet: snippet) {
        if let fullContent = try? await contentFetcher.fetchContent(from: result.url) {
            snippet = fullContent
        }
    }
}
```

This is a simplicity choice. Could be parallelized with `TaskGroup` or `async let` for better performance.

## Rules

1. Never remove `@MainActor` from `@Observable` classes
2. Always use `await` when calling `ContentFetcher` methods from `@MainActor`
3. Keep `SearXNGService` stateless to maintain `Sendable` conformance
4. Always check `Task.isCancelled` between async stages
5. Use `#if canImport(FoundationModels)` for SDK compatibility
