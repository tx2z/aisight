# Persistence Layer System

## Overview

AISight uses two persistence mechanisms:
- **SwiftData** for structured query history (questions, answers, sources, timestamps)
- **UserDefaults** for lightweight key-value settings (SearXNG URL, language, onboarding flag)

## SwiftData Models

### QueryEntry

The primary persisted model, annotated with `@Model`:

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Auto-generated unique identifier |
| `query` | `String` | The user's question text |
| `answer` | `String` | Complete AI-generated answer text |
| `sources` | `[SourceInfo]` | Array of source metadata (Codable) |
| `timestamp` | `Date` | When the query was made |

### SourceInfo

A `Codable`, `Hashable`, `Sendable` struct stored as an array within `QueryEntry`:

| Property | Type | Description |
|----------|------|-------------|
| `url` | `String` | Source page URL |
| `title` | `String` | Source page title |
| `engine` | `String?` | Search engine that found this result |

`SourceInfo` is **not** a separate `@Model` — it's embedded as a Codable array within `QueryEntry`.

## QueryHistoryStore

`@Observable` class that wraps `ModelContext` operations:

| Method | Description |
|--------|-------------|
| `save(query:answer:sources:)` | Creates and persists a new `QueryEntry` |
| `fetchHistory()` | Returns all entries sorted by timestamp (newest first) |
| `deleteEntry(_:)` | Removes a single history entry |
| `clearAll()` | Deletes all history entries |

### Error Handling

All database operations are wrapped in do-catch. Errors are **printed to console** but **never thrown** — this is intentional. A failed save should not prevent the user from seeing their answer.

### Usage

```swift
let store = QueryHistoryStore(modelContext: modelContext)
store.save(query: "What is...", answer: "Paris is...", sources: [...])
let history = store.fetchHistory()
```

## UserDefaults Keys

| Key | Type | Default | Purpose |
|-----|------|---------|---------|
| `"searxng_base_url"` | `String?` | `nil` → `AppConfig.defaultSearXNGBaseURL` | User's SearXNG instance URL |
| `"search_language"` | `String?` | `nil` → `"en"` | Search language preference |
| `"hasSeenOnboarding"` | `Bool` | `false` | Whether onboarding has been completed |

### Why UserDefaults?

These values are:
- Simple key-value pairs (no relationships)
- Not sensitive (SearXNG URL is not a secret)
- Needed before SwiftData container is ready (e.g., `effectiveSearXNGBaseURL`)

## SwiftData Container Setup

The `ModelContainer` is configured in `AISightApp.swift` (the `@main` entry point) and injected into the SwiftUI environment. All views access it via `@Environment(\.modelContext)`.

## Migration Strategy

No explicit migration strategy is in place. SwiftData handles lightweight migrations automatically (adding new properties with defaults). Schema changes that remove or rename properties would require manual migration handling.

## Performance Considerations

- `fetchHistory()` loads all entries — no pagination. For hundreds of entries, consider adding `fetchLimit` to the `FetchDescriptor`.
- Answer text is stored in full — over many queries, storage grows. No archival or cleanup mechanism exists in v1.0.
- `clearAll()` fetches all entries then deletes one by one. Could be optimized with a batch delete if SwiftData supports it.
