# Persistence Domain

> When to load: Modifying SwiftData models, QueryHistoryStore, or history features.

## Overview

AISight uses SwiftData for query history persistence and UserDefaults for lightweight settings. Each completed query saves a `QueryEntry` with the question, answer, sources, and timestamp. Settings (SearXNG URL, onboarding state) use UserDefaults since they're simple key-value pairs.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| QueryEntry.swift | `QueryEntry` (@Model), `SourceInfo` | `AISight/AISight/Core/Persistence/` |
| QueryHistoryStore.swift | `QueryHistoryStore` | `AISight/AISight/Core/Persistence/` |

## Models

### QueryEntry (@Model)

| Property | Type | Description |
|----------|------|-------------|
| `id` | `UUID` | Auto-generated unique identifier |
| `query` | `String` | User's question text |
| `answer` | `String` | Complete generated answer |
| `sources` | `[SourceInfo]` | Array of source metadata |
| `timestamp` | `Date` | When the query was made |

### SourceInfo (Codable, Hashable, Sendable)

| Property | Type | Description |
|----------|------|-------------|
| `url` | `String` | Source page URL |
| `title` | `String` | Source page title |
| `engine` | `String?` | Search engine that found this source |

## QueryHistoryStore

`@Observable class QueryHistoryStore`

Takes `ModelContext` in init. All operations are synchronous (SwiftData main-thread access).

### Methods

| Method | Description |
|--------|-------------|
| `save(query:answer:sources:)` | Creates QueryEntry, inserts into context, saves |
| `fetchHistory() -> [QueryEntry]` | Fetches all entries sorted by timestamp descending |
| `deleteEntry(_:)` | Deletes single entry and saves |
| `clearAll()` | Fetches all entries, deletes each, saves |

### Error Handling

All operations catch errors and `print()` to console. **Non-blocking** — save failures don't prevent the answer from being displayed. This is intentional: the answer is more important than the history record.

## UserDefaults Keys

| Key | Type | Default | Used By |
|-----|------|---------|---------|
| `"searxng_base_url"` | `String?` | `nil` (falls back to `AppConfig.defaultSearXNGBaseURL`) | `AppConfig.effectiveSearXNGBaseURL` |
| `"search_language"` | `String?` | `nil` (falls back to `AppConfig.defaultSearchLanguage`) | `SearchViewModel.language` |
| `"hasSeenOnboarding"` | `Bool` | `false` | `AppState.hasSeenOnboarding` |

## Important Constraints

- SwiftData container set up in `AISightApp.swift` entry point
- `SourceInfo` is stored as a `Codable` array within `QueryEntry` (not a separate @Model)
- No migration strategy documented yet — schema changes may require manual migration
- `QueryHistoryStore` is not `@MainActor` but is used from `@MainActor` context via `SearchViewModel`

## Common Modifications

**Adding a new persisted field to QueryEntry:** Add property, provide default in init. SwiftData handles lightweight migration for additions.

**Adding favorites/bookmarks:** Add `isFavorite: Bool` to QueryEntry, filter in fetchHistory.

**Adding search within history:** Use `Predicate` in FetchDescriptor to filter by query text.

**Pagination for large history:** Add `fetchLimit` and offset to FetchDescriptor.
