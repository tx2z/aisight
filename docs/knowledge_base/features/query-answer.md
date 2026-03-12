# Query & Answer Feature

## Overview

The core feature of AISight: users type a question, the app searches the web, and an on-device AI streams a cited answer.

## User Flow

1. User types question in search text field
2. Taps search / presses return
3. Loading indicator appears during SearXNG search
4. Source cards appear with titles, domains, and engine badges
5. Answer streams in token-by-token with inline citation badges `[1]` `[2]`
6. Completed answer is saved to history

## State Management

`SearchViewModel` (`@MainActor`, `@Observable`) manages all state:

| State | Type | Description |
|-------|------|-------------|
| `query` | `String` | Bound to text field |
| `sources` | `[SearXNGResult]` | Search results for source card display |
| `errorMessage` | `String?` | User-facing error, nil when no error |
| `isSearching` | `Bool` | True during SearXNG API call |
| `streamingText` | `String` | Live answer text (forwarded from AnswerSession) |
| `isGenerating` | `Bool` | True during model generation (forwarded) |

## Citation Rendering

`CitationText` parses `[N]` patterns in the answer text:

- Scans character-by-character through the text
- When `[` is found, looks ahead for digits followed by `]`
- Matched citations render as blue background, white text badges (`.caption2.bold()`)
- Unmatched brackets render as normal body text
- Uses `AttributedString` for styling

Citations map to the numbered sources in the source card list.

## Source Cards

`SourceCardView` displays each search result:

- Title of the source page
- Domain name (extracted from URL, `www.` stripped)
- Engine badge (Google, Bing, Brave)
- Tappable to open the source URL

## Cancellation

Starting a new search cancels the previous one:
- `SearchViewModel.currentTask?.cancel()` before starting new task
- `Task.isCancelled` checked between every pipeline stage
- Prevents stale results from appearing

## Error States

| Error | Display |
|-------|---------|
| Server unavailable | "Search server is unavailable. Check your connection or update the server URL in Settings." |
| Timeout | "Search took too long. The server may be overloaded — try again in a moment." |
| No results | "No sources found for this query. Try rephrasing." |
| No internet | "Connect to the internet to search. Previously answered questions are available in History." |
| Model unavailable | "AISight requires Apple Intelligence. Enable it in Settings → Apple Intelligence & Siri." |
| Content policy | "This query can't be answered on-device. Try a different question." |
| Empty response | "The model returned an empty response. Try rephrasing your question." |
