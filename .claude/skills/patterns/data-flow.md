# Data Flow Pattern

> When to load: Understanding or modifying the query-to-answer pipeline.

## Overview

AISight's core pipeline flows linearly: user query → web search → content fetch → AI generation → history save. `SearchViewModel` orchestrates the entire flow in a single `Task`, with cancellation support at each stage.

## Full Pipeline

```
User types query → SearchView → SearchViewModel.performSearch(modelContext:)
  |
  +-- 1. SearXNGService.search(query:language:)
  |     +-- Builds URL with URLComponents
  |     +-- Sends via URLSession.shared (10s timeout)
  |     +-- Decodes SearXNGResponse
  |     +-- processResults(): filter → RRF rank → dedup → top 5
  |     +-- Returns SearchOutput (results, directAnswers, suggestions, infoboxes)
  |
  +-- 2. SearchViewModel sets self.sources = searchOutput.results
  |     (UI updates: source cards appear)
  |     self.isSearching = false
  |
  +-- 3. AnswerSession.generateAnswer(for:with:)
  |     +-- For each result (up to maxResults=5):
  |     |   +-- Check shouldFetchFullContent (snippet < 150 chars?)
  |     |   +-- If yes: ContentFetcher.fetchContent(from: url)
  |     |   +-- Truncate to maxSnippetLength (1600 chars)
  |     +-- SystemPrompt.build(query:sources:directAnswers:infoboxes:)
  |     +-- LanguageModelSession(instructions: systemPromptText)
  |     +-- session.streamResponse(to: query)
  |     +-- For each partial: streamingText = partial.content
  |         (UI updates: answer text streams in)
  |
  +-- 4. Error check
  |     +-- answerSession.error? → set errorMessage
  |     +-- streamingText empty? → set errorMessage
  |
  +-- 5. Save to history (on success only)
        +-- QueryHistoryStore.save(query:answer:sources:)
        +-- Creates QueryEntry → modelContext.insert → modelContext.save
```

## Cancellation

```swift
// SearchViewModel
private var currentTask: Task<Void, Never>?

func performSearch(modelContext:) {
    currentTask?.cancel()           // Cancel previous search
    currentTask = Task {
        // Stage 1: search
        guard !Task.isCancelled else { return }
        // Stage 2: set sources
        guard !Task.isCancelled else { return }
        // Stage 3: generate answer (checks internally too)
        guard !Task.isCancelled else { return }
        // Stage 4-5: error check + save
    }
}
```

Each stage in both `SearchViewModel` and `AnswerSession` checks `Task.isCancelled`.

## Published State

SearchViewModel exposes state to SwiftUI views:

| Property | Updated At | Drives |
|----------|-----------|--------|
| `isSearching` | Stage 1 start/end | Loading indicator |
| `sources` | Stage 2 | Source card list |
| `streamingText` | Stage 3 (each chunk) | Streaming answer text |
| `isGenerating` | Stage 3 start/end | Generation indicator |
| `errorMessage` | Stage 4 | Error display |

`streamingText` and `isGenerating` are forwarded from `AnswerSession` via computed properties.

## Data Objects Through Pipeline

```
SearXNGResponse (JSON decode)
  → [SearXNGResult] (filtered, RRF-ranked, deduped)
    → SearchOutput (results + directAnswers + suggestions + infoboxes)
      → [(index, title, snippet, url)] tuples (with optional full content)
        → System prompt string (via SystemPrompt.build)
          → LanguageModelSession → streamed text
            → QueryEntry + [SourceInfo] (persisted to SwiftData)
```

## Important Notes

- **Single search, no duplication:** Search happens once in SearchViewModel. Results are passed to AnswerSession. The AI never re-searches.
- **Content fetching is conditional:** Only fetches full pages when snippet < 150 chars. This saves time and bandwidth.
- **Content fetching is sequential:** For loop in AnswerSession, not parallel. Simpler but slower.
- **History save is fire-and-forget:** Errors are printed, not surfaced to user.
- **Fresh session per query:** No conversation context between queries.
