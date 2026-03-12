# History Feature

## Overview

AISight persists all successful queries and answers locally using SwiftData. Users can browse past questions, view full answers with citations, and delete entries.

## User Flow

1. Navigate to History tab
2. See list of past queries sorted by most recent first
3. Each entry shows: query text and timestamp
4. Tap entry to view full answer with citations and source list
5. Swipe left on entry to delete
6. "Clear All" button removes all history (with confirmation prompt)

## Data Model

Each history entry is a `QueryEntry` (`@Model`):

| Field | Type | Content |
|-------|------|---------|
| `id` | `UUID` | Unique identifier |
| `query` | `String` | The original question |
| `answer` | `String` | Complete AI-generated answer |
| `sources` | `[SourceInfo]` | Array of (url, title, engine) |
| `timestamp` | `Date` | When the query was made |

## When History Is Saved

After a successful search and answer generation:
1. `SearchViewModel` checks: no error and answer is non-empty
2. Maps `SearXNGResult` sources to `[SourceInfo]`
3. Calls `QueryHistoryStore.save(query:answer:sources:)`
4. Save failure is non-blocking — error printed to console

History is **not** saved when:
- Search fails
- Model generation fails
- Model returns empty response
- Task is cancelled

## Operations

| Operation | Method | Notes |
|-----------|--------|-------|
| View all | `fetchHistory()` | Sorted by timestamp descending |
| Delete one | `deleteEntry(_:)` | Swipe-to-delete gesture |
| Clear all | `clearAll()` | Confirmation prompt required |

## Persistence

- Data persists across app restarts (SwiftData)
- No sync or cloud backup
- No export or sharing mechanism in v1.0
- No pagination — all entries loaded at once
