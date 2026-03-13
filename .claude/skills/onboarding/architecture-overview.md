# Architecture Overview

> When to load: Understanding the high-level system design of AISight.

## Pipeline

```
User Query → SearXNG (search) → ContentFetcher (HTML→text) → FoundationModels (on-device AI) → Streamed Answer with Citations → SwiftData (history)
```

## Layer Map

| Layer | Path | Key Classes | Responsibility |
|-------|------|-------------|---------------|
| App | `App/` | AISightApp, AppConfig, AppState | Entry point, configuration, global state |
| AI | `Core/AI/` | AnswerSession, SystemPrompt | FoundationModels session, prompt building |
| Search | `Core/Search/` | SearXNGService, SearXNGResult, SearchOutput | SearXNG API, RRF ranking, result models |
| Fetching | `Core/Fetching/` | ContentFetcher | URL → clean text extraction |
| Persistence | `Core/Persistence/` | QueryEntry, QueryHistoryStore | SwiftData models and store |
| Features | `Features/` | SearchViewModel, HistoryViewModel | MVVM view models |
| UI | `UI/` | CitationText, SourceCardView | Reusable view components |

## Key Architectural Decisions

### Fresh session per query
Each query creates a new `LanguageModelSession`. No conversation history. Maximizes the ~4096 token context window for source content and answer generation.

### Pre-fetch, not tool-calling
Sources are searched and fetched **before** invoking the model. The model receives sources as context in the prompt. This gives predictable token usage vs. tool-calling which would consume tokens for round-trips.

### RRF ranking (k=60)
Results from multiple search engines (Google, Bing, Brave) are fused using Reciprocal Rank Fusion. Formula: `score(d) = sum 1/(60 + rank_i(d))`. This produces better rankings than any single engine.

### Actor for ContentFetcher
`ContentFetcher` is a Swift actor, isolating its `URLSession` and config. Thread-safe by design without locks.

### @MainActor for UI-bound state
All `@Observable` classes (`AnswerSession`, `SearchViewModel`, `AppState`) are `@MainActor` for Swift 6 strict concurrency compliance.

### Sendable SearXNGService
No mutable state. Uses `URLSession.shared`. Safe to call from any context.

### No custom theme
`AppTheme.swift` is intentionally empty. System colors (`.primary`, `.secondary`), system fonts, numeric spacing. Matches the native iOS 26 design language with automatic liquid glass on navigation elements.

### UserDefaults for settings, SwiftData for history
Simple key-value settings (SearXNG URL, language, onboarding flag) use UserDefaults. Structured query history uses SwiftData with `@Model` classes.

## Context Window Budget

The ~4096 token limit shapes the entire architecture:

| Component | Tokens |
|-----------|--------|
| System prompt | ~150 |
| User query | ~100 |
| Sources (5 x 400) | ~2000 |
| Answer | ~1000 |
| Overhead | ~250 |
| **Total** | **~3500** |

## Concurrency Model

```
@MainActor: AnswerSession, SearchViewModel, AppState, QueryHistoryStore
     actor: ContentFetcher
  Sendable: SearXNGService, SearXNGResult, SearchOutput, SourceInfo
```

## Error Strategy

Layered: framework errors → domain errors → user-facing strings. Never crashes. Degrades gracefully (snippet fallback, non-blocking saves).
