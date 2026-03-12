# Query & Answer Feature

## Overview

The core feature of AISight: users type a question, the app searches the web, and an on-device AI streams a cited answer.

## User Flow

1. User types question in bottom input bar (chat-style, like ChatGPT/Claude/Perplexity)
2. Taps send button (arrow.up.circle.fill) or presses return
3. Input bar disappears, "Thinking..." indicator appears centered on screen
4. Answer streams in with markdown formatting and inline citation badges `[1]` `[2]`
5. Source cards appear below the answer with titles, domains, and engine badges
6. Completed answer is saved to history
7. User taps "New Search" toolbar button (square.and.pencil) to start over

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

## Markdown & Citation Rendering

`CitationText` renders the AI response with full markdown support and inline citation badges:

- **Block-level:** Splits text into headings (`##`), list items (`-`), code blocks, paragraphs
- **Headings** render with `.title`/`.title2`/`.title3` fonts
- **List items** render with bullet `•` or number prefix in an `HStack`
- **Code blocks** render in monospaced font with background
- **Inline markdown:** `AttributedString(markdown:)` handles bold, italic, code, links within each block
- **Citations:** `[N]` patterns are escaped to `\u{FFFC}` placeholders before markdown parsing, then replaced with blue/white badge `AttributedString` segments after parsing

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

## Deep Search Mode

When Deep Search is enabled in Settings, the pipeline uses a multi-agent research approach:

### User Flow (Deep Search)

1. User types question and taps send
2. Progress indicator shows current step:
   - "Reformulating query..."
   - "Searching the web..."
   - "Analyzing sources (1/3)..." → "2/3" → "3/3"
   - "Writing answer..."
3. Answer streams in with same markdown + citation rendering
4. Source cards appear grouped by search query
5. Result saved to history

### State Management (Deep Search)

Additional state in `SearchViewModel`:

| State | Type | Description |
|-------|------|-------------|
| `deepSearchPipeline` | `DeepSearchPipeline` | Manages multi-step pipeline |
| `isDeepSearch` | `Bool` | Reads UserDefaults `"deep_search_enabled"` |
| `searchStepDescription` | `String?` | Step label for progress UI |

`streamingText` and `isGenerating` forward from `DeepSearchPipeline` instead of `AnswerSession` when in deep search mode.
