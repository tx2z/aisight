# Persistence Domain

> When to load: Modifying SwiftData models, QueryHistoryStore, or history features.

## Overview

AISight uses SwiftData for query history persistence and UserDefaults for lightweight settings. Each completed query saves a `QueryEntry` with the question, answer, sources, and timestamp. Settings (SearXNG URL, onboarding state) use UserDefaults since they're simple key-value pairs.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| QueryEntry.swift | `QueryEntry` (@Model) | `AISight/AISight/Core/Persistence/` |
| SourceInfo.swift | `SourceInfo` | `AISight/AISight/Core/Persistence/` |
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
| `isDeepSearch` | `Bool` | Whether this query used Deep Search pipeline (default: `false`) |

### SourceInfo (Codable, Hashable, Sendable)

| Property | Type | Description |
|----------|------|-------------|
| `url` | `String` | Source page URL |
| `title` | `String` | Source page title |
| `engine` | `String?` | Search engine that found this source |
| `wasUsed` | `Bool` | Whether this source was used in the AI answer (default: `true`, backwards-compatible decoder) |

## QueryHistoryStore

`@Observable class QueryHistoryStore`

Takes `ModelContext` in init. All operations are synchronous (SwiftData main-thread access).

### Methods

| Method | Description |
|--------|-------------|
| `save(query:answer:sources:isDeepSearch:)` | Creates QueryEntry, inserts into context, saves |
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

## Recent Changes (2026-03-25)

- **Deep Search tracking:** `QueryEntry.isDeepSearch` field records whether query used Deep Search pipeline.
- **Source attribution:** `SourceInfo.wasUsed` field distinguishes sources used in AI answer from unused results. Decoder handles backwards compatibility.
- **QueryHistoryStore:** `save()` now accepts `isDeepSearch` parameter.

## Recent Changes (2026-03-13)

- **Single-type-per-file refactor:** `SourceInfo` extracted from `QueryEntry.swift` into its own file.
- **QueryHistoryStore:** Modernized with Swift 6 concurrency improvements.
- **Settings "Delete All Data":** Renamed from "Clear Cache" with stronger confirmation dialog.
