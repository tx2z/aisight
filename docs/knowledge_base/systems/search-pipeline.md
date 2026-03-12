# Search Pipeline System

## Overview

AISight's search pipeline transforms a user's natural language question into a cited, AI-generated answer. The pipeline flows through 6 stages: query → search → rank → fetch → generate → save.

## Pipeline Stages

### 1. User Submits Query

`SearchViewModel.performSearch(modelContext:)` is called. The previous search task (if any) is cancelled. A new `Task` is created to run the pipeline.

### 2. SearXNG Search

`SearXNGService.search(query:language:)` sends an HTTP GET to the configured SearXNG instance:

```
GET {baseURL}/search?q={query}&format=json&engines=google,bing,brave&language={lang}&categories=general
```

- Timeout: 10 seconds
- Uses `URLComponents` for URL construction (never string interpolation)
- Uses `URLSession.shared` (Sendable, no stored session)
- Decodes `SearXNGResponse` with results, direct answers, suggestions, and infoboxes

### 3. Result Processing (RRF Ranking)

`SearXNGService.processResults()` filters, ranks, and deduplicates:

**Step 1 — Filter:** Remove results with snippets shorter than 30 characters (`minSnippetLength`).

**Step 2 — Build engine rankings:** Group results by search engine. Sort each engine's results by score to determine rank position.

**Step 3 — Deduplicate:** Normalize URLs (lowercase, strip tracking params, remove `www.`, strip trailing slash). When duplicates found, keep the result with the longer snippet.

**Step 4 — RRF scoring:**

```
score(d) = sum over all engines: 1 / (k + rank_i(d))
```

Where `k = 60` (standard constant from Cormack, Clarke, Butt paper). This fuses rankings from multiple engines — a result ranked #1 in Google and #3 in Bing scores higher than one ranked #1 in only Google.

**Step 5 — Select top results:** Sort by RRF score descending, take top 5 (`maxResults`).

### 4. Content Fetching

`AnswerSession.generateAnswer()` enriches results with full page content:

For each of the top 5 results:
1. Check if SearXNG snippet is too short (< 150 chars, `snippetThreshold`)
2. If short: fetch full page via `ContentFetcher.fetchContent(from:)`
3. If fetch fails: fall back to SearXNG snippet
4. Truncate to 1600 characters (`maxSnippetLength`, ~400 tokens)

**ContentFetcher** (actor) HTML stripping pipeline:
1. Remove `<script>`, `<style>`, `<nav>`, `<header>`, `<footer>` blocks with content
2. Remove all remaining HTML tags
3. Decode HTML entities (`&amp;`, `&lt;`, `&gt;`, `&quot;`, `&#39;`, `&nbsp;`)
4. Collapse whitespace
5. Trim

**Note:** Fetching is sequential (for loop), not parallel. Simplicity over speed.

### 5. Answer Generation

`AnswerSession` builds a prompt and streams the AI response:

1. **Build system prompt** via `SystemPrompt.build()`:
   - Rules: cite sources, synthesize, don't fabricate
   - Optional: direct answers from search engines
   - Optional: knowledge panel from infoboxes (truncated to 800 chars)
   - Numbered sources: `[1] Title / URL / Content`
   - User query

2. **Create session:** `LanguageModelSession(instructions: systemPromptText)`
   - Fresh session per query (no conversation history)

3. **Stream response:** `for try await partial in session.streamResponse(to: query)`
   - `partial.content` contains the full accumulated text
   - `streamingText` is updated each iteration → UI shows live progress

### 6. History Save

On success (no error, non-empty answer):
- Map sources to `[SourceInfo]` (url, title, engine)
- `QueryHistoryStore.save(query:answer:sources:)` creates `QueryEntry` in SwiftData
- Save failures are non-blocking (printed to console, answer still displayed)

## Token Budget

| Component | Budget | Notes |
|-----------|--------|-------|
| System prompt | ~150 tokens | Rules and format instructions |
| Direct answers / infoboxes | ~100 tokens | Optional, from SearXNG |
| User query | ~100 tokens | Most queries are short |
| Source content | ~2000 tokens | 5 sources x 400 tokens each |
| Generated answer | ~1000 tokens | Remaining space |
| Overhead | ~250 tokens | Formatting, markers |
| **Total** | **~3500 tokens** | Fits ~4096 context window |

## Cancellation

`SearchViewModel.currentTask` tracks the active pipeline. New searches cancel previous ones. `Task.isCancelled` is checked between every stage in both `SearchViewModel` and `AnswerSession`.

## Error Handling

| Stage | Error | User Message |
|-------|-------|-------------|
| Search | Server unavailable | "Search server is unavailable. Check your connection or update the server URL in Settings." |
| Search | Timeout | "Search took too long. The server may be overloaded — try again in a moment." |
| Search | No results | "No sources found for this query. Try rephrasing." |
| Search | No internet | "Connect to the internet to search. Previously answered questions are available in History." |
| Generate | Model unavailable | "AISight requires Apple Intelligence. Enable it in Settings → Apple Intelligence & Siri." |
| Generate | Content policy | "This query can't be answered on-device. Try a different question." |
| Generate | Empty response | "The model returned an empty response. Try rephrasing your question." |
