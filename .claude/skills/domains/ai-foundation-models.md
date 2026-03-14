# AI / FoundationModels Domain

> When to load: Modifying AnswerSession, SystemPrompt, or any FoundationModels integration.

## Overview

AISight uses Apple's FoundationModels framework (iOS 26+) for on-device answer generation. A ~3B parameter model with ~4096 token context window runs entirely on-device via `LanguageModelSession`. Each query creates a fresh session — no conversation history is carried between queries.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| AnswerSession.swift | `AnswerSession` | `AISight/AISight/Core/AI/` |
| AnswerError.swift | `AnswerError` | `AISight/AISight/Core/AI/` |
| GenerationErrorMessages.swift | `GenerationErrorMessages` | `AISight/AISight/Core/AI/` |
| SystemPrompt.swift | `SystemPrompt` | `AISight/AISight/Core/AI/` |
| DeepSearchPipeline.swift | `DeepSearchPipeline` | `AISight/AISight/Core/AI/` |
| QueryReformulator.swift | `QueryReformulator` | `AISight/AISight/Core/AI/` |

## AnswerSession

`@available(iOS 26.0, macOS 26.0, *)` `@MainActor` `@Observable`

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `streamingText` | `String` | Accumulated response text, updated per stream chunk |
| `isGenerating` | `Bool` | True while model is generating |
| `error` | `AnswerError?` | Set on failure, nil on success (`private(set)`) |

### reset()

Clears all state (`streamingText`, `isGenerating`, `error`) to prepare for a new query. Called by `SearchViewModel.resetSearch()`.

### generateAnswer(for:with:) Flow

1. Reset state (`streamingText = ""`, `isGenerating = true`, `error = nil`)
2. For each result in `searchOutput.results.prefix(maxResults)`:
   - If snippet too short (`< snippetThreshold`), fetch full page via `ContentFetcher`
   - Truncate to `maxSnippetLength` (1600 chars)
   - Build source tuple: (index, title, snippet, url)
3. Check `Task.isCancelled`
4. Build system prompt via `SystemPrompt.build(query:sources:directAnswers:infoboxes:)`
5. Create `LanguageModelSession(instructions: systemPromptText)`
6. Stream: `for try await partial in session.streamResponse(to: query)`
   - Set `streamingText = partial.content`
7. Catch `LanguageModelSession.GenerationError` → map to `AnswerError`

### AnswerError

| Case | Triggered By |
|------|-------------|
| `.searchFailed(SearchError)` | Search-layer errors |
| `.generationFailed(String)` | exceededContextWindowSize, unsupportedLanguageOrLocale, rateLimited, concurrentRequests, unsupportedGuide, decodingFailure |
| `.modelUnavailable` | assetsUnavailable |
| `.contentPolicy` | guardrailViolation, refusal |

### Availability Check

```swift
AnswerSession.checkAvailability() // → Bool
AnswerSession.availabilityStatus   // → SystemLanguageModel.Availability
// Checks: SystemLanguageModel.default.availability == .available
```

## QueryReformulator

`@available(iOS 26.0, macOS 26.0, *)` `@MainActor`

Generates 1-3 optimized keyword search queries from a conversational user question using a fresh LLM session. Short queries (≤3 words) pass through unchanged. Used by both normal search and deep search pipelines.

### reformulate(_:) → [String]

1. If query ≤3 words, return as-is
2. Create fresh `LanguageModelSession` with query optimizer instructions
3. Parse response into lines, return up to 3 queries
4. Fall back to original query on any error

## DeepSearchPipeline

`@available(iOS 26.0, macOS 26.0, *)` `@MainActor` `@Observable`

Multi-step research pipeline for complex queries. Uses 5 sequential LLM sessions (1 reformulator + 3 researchers + 1 synthesizer), each with independent ~4096 token context.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `streamingText` | `String` | Final synthesized answer, streamed |
| `isGenerating` | `Bool` | True while pipeline is running |
| `currentStep` | `DeepSearchStep` | Current pipeline stage for UI progress |
| `error` | `AnswerError?` | Set on failure |

### DeepSearchStep

| Case | Description |
|------|-------------|
| `.idle` | Not running |
| `.reformulating` | "Reformulating query..." |
| `.searching` | "Searching the web..." |
| `.researching(current:total:)` | "Analyzing sources (N/M)..." |
| `.synthesizing` | "Writing answer..." |

### execute(query:language:searchService:) Flow

1. **Reformulate** — reuses `QueryReformulator` → 3 keyword queries
2. **Search** — parallel `SearXNGService.multiSearch()` → merged results
3. **Research** — 3 sequential researchers, each gets one query group's results. Fresh `LanguageModelSession` each. Outputs key findings summary.
4. **Synthesize** — fresh session gets all researcher summaries + source list. Streams final cited answer.

**Graceful degradation:** If a researcher fails, remaining summaries still go to synthesizer. If all fail, returns error and caller can fall back to normal mode.

**Researchers run sequentially** — on-device model throws `concurrentRequests` if parallel sessions are used.

## SystemPrompt

`enum SystemPrompt` with static `build()` method.

### Parameters

| Param | Type | Description |
|-------|------|-------------|
| `query` | `String` | User's question |
| `sources` | `[(index, title, snippet, url)]` | Numbered source tuples |
| `directAnswers` | `[String]` | Instant answers from SearXNG |
| `infoboxes` | `[SearXNGInfobox]` | Knowledge panels (e.g., Wikipedia) |

### Prompt Structure

**No sources path:** Returns prompt saying "no search results available."

**With sources:**
```
You are AISight — a private, on-device answer engine...

## Rules
- Answer concisely in 2-4 paragraphs
- Attribute inline using (via domain.com) format
- Synthesize across sources, don't summarize each sequentially
- Use **bold** for key terms and bullet lists when listing items
- Base answer on provided sources; supplement with general knowledge only when needed
- Never fabricate specific statistics, quotes, dates, or claims

## Direct Answers (if any)
## Knowledge Panel (if any, truncated to 800 chars)

## Sources
<source domain="example.com">
Title: ...
Content: ...
</source>

## User Query
{query}
```

## Important Constraints

- `@available(iOS 26.0, macOS 26.0, *)` is **required** — FoundationModels doesn't exist on older OS
- Fresh `LanguageModelSession` per query — no conversation continuity
- `partial.content` gives the full accumulated text (not just the delta)
- Device requirements: A17 Pro+, M1+, Apple Intelligence enabled in Settings
- Content fetching is sequential (for loop), not parallel TaskGroup

## Common Modifications

**Changing the system prompt:** Edit `SystemPrompt.build()`. Keep total prompt under ~500 tokens.

**Adding tool calling:** Define a `Tool` conforming type, register with session. Note: v1.0 uses pre-fetch approach instead for predictable token usage.

**Changing source limits:** Modify `AppConfig.maxResults` and `AppConfig.maxSnippetLength`. Ensure total stays under ~4096 tokens.

**Adding conversation follow-ups:** Would require maintaining session across calls and managing context window accumulation. Not in v1.0.

**Adjusting deep search researcher count:** Change `AppConfig.deepSearchResearcherCount`. More researchers = more thorough but slower.

**Modifying researcher/synthesizer prompts:** Edit `DeepSearchPipeline.runResearcher()` and `runSynthesizer()` instructions strings.

## Recent Changes (2026-03-13)

- **Single-type-per-file refactor:** `AnswerError` extracted from `AnswerSession.swift` into its own file. `GenerationErrorMessages` added for localized error strings across all 9 supported languages.
- **QueryReformulator:** Removed branded example from prompt to avoid bias.
- **DeepSearchPipeline:** Modernized with Swift 6 concurrency improvements.
- **SystemPrompt:** Refined instruction structure for better answer quality.
