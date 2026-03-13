# Search / SearXNG Domain

> When to load: Modifying SearXNGService, search result models, RRF ranking, or search logic.

## Overview

AISight searches the web via a self-hosted SearXNG instance. `SearXNGService` sends queries, processes results with Reciprocal Rank Fusion (RRF) ranking, deduplicates by normalized URL, and returns the top results. The service is `Sendable` with no mutable state.

## Key Files

| File | Key Types | Location |
|------|-----------|----------|
| SearXNGService.swift | `SearXNGService` | `AISight/AISight/Core/Search/` |
| SearXNGResult.swift | `SearXNGResult`, `SearXNGResponse`, `SearXNGInfobox` | `AISight/AISight/Core/Search/` |
| SearchService.swift | `SearchOutput`, `SearchService` protocol | `AISight/AISight/Core/Search/` |
| SearchError.swift | `SearchError` | `AISight/AISight/Core/Search/` |

## SearXNGService

`final class SearXNGService: SearchService, Sendable`

### search(query:language:) -> SearchOutput

1. Build URL: `{effectiveSearXNGBaseURL}/search` with URLComponents
2. Query params: `q`, `format=json`, `engines`, `language`, `categories`
3. Send via `URLSession.shared` with `searchTimeoutSeconds` (10s) timeout
4. Error mapping:
   - `URLError.timedOut` → `SearchError.timeout`
   - Connection errors → `SearchError.serverUnavailable`
   - Non-2xx HTTP → `SearchError.serverUnavailable`
   - Decode failure → `SearchError.invalidResponse`
5. Process results via `processResults()` (see RRF below)
6. Empty results → `SearchError.noResults`
7. Return `SearchOutput(results, directAnswers, suggestions, infoboxes)`

### RRF Ranking (processResults)

1. **Filter:** Remove results with `snippetLength < minSnippetLength` (30 chars)
2. **Build engine rankings:** Group by engine, sort by score → rank position
3. **Deduplicate:** By normalized URL. Keep result with longer snippet.
4. **Compute RRF scores:** `score(d) = sum 1/(k + rank_i(d))` where `k = 60`
5. **Sort** by RRF score descending, take top `maxResults` (5)

### URL Normalization

For deduplication: lowercase → strip tracking params (utm_*, fbclid, gclid, msclkid, etc.) → remove fragment → strip `www.` → strip trailing `/` → append remaining query string.

### checkAvailability() -> Bool

Sends test query (`q=test`) to search endpoint. Returns true if HTTP 2xx.

## Models

### SearXNGResult (Codable, Identifiable, Sendable)

| Property | Type | Description |
|----------|------|-------------|
| `url` | `String` | Result page URL |
| `title` | `String` | Page title |
| `content` | `String?` | Snippet text |
| `engine` | `String?` | Primary engine |
| `score` | `Double?` | SearXNG relevance score |
| `engines` | `[String]?` | All engines returning this result |
| `positions` | `[Int]?` | Rank in each engine |
| `category` | `String?` | Result category |
| `publishedDate` | `String?` | Publication date |

**Computed properties:** `id` (url+engine), `engineCount`, `snippetLength`, `hasUsableSnippet`, `domain`

### SearchOutput

| Property | Type | Description |
|----------|------|-------------|
| `results` | `[SearXNGResult]` | Processed, ranked results |
| `directAnswers` | `[String]` | Instant answers from engines |
| `suggestions` | `[String]` | Related query suggestions |
| `infoboxes` | `[SearXNGInfobox]` | Knowledge panels |

### SearchError

`.serverUnavailable` | `.timeout` | `.noResults` | `.invalidResponse`

## Important Constraints

- URL built with `URLComponents` — never string interpolation
- Uses `URLSession.shared` (Sendable) — no stored session
- Timeout: 10 seconds (configurable via `AppConfig.searchTimeoutSeconds`)
- SearXNG must return JSON format (`format=json` param)
- No retry logic — failures surface immediately

## Common Modifications

**Adding search engines:** Edit `AppConfig.searchEngines` string.

**Changing ranking:** Modify `processResults()` or `rrfK` constant. Higher k reduces top-rank advantage.

**Adding pagination:** Add `pageno` query param. Currently hardcoded to page 1.

**Adding search categories:** Modify `AppConfig.searchCategories` or make it configurable.
