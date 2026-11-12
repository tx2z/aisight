# AppConfig Reference

> When to load: Understanding or modifying configuration values in `AISight/AISight/App/AppConfig.swift`.

`AppConfig` is a `Sendable` enum (no instances) containing all compile-time configuration constants.

## SearXNG Connection

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `defaultSearXNGBaseURL` | `String` | `"http://localhost:8888"` | Default SearXNG instance URL. Override before shipping. |
| `effectiveSearXNGBaseURL` | `String` (computed) | — | Reads `UserDefaults["searxng_base_url"]`, falls back to `defaultSearXNGBaseURL`. All service code uses this. |

**Used by:** `SearXNGService.search()`, `SearXNGService.checkAvailability()`, `SettingsView`

## Search Parameters

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `searchEngines` | `String` | `"google,bing,brave"` | Comma-separated SearXNG engine names |
| `searchCategories` | `String` | `"general"` | SearXNG search category |
| `maxResults` | `Int` | `5` | Max search results used as sources. Directly impacts context window budget (~400 tokens each). |
| `supportedLanguages` | `[(code, englishName, nativeName)]` | 9 languages | The only language list (prompts and Settings pickers). `supportedLanguageCode(from:)` extracts a supported base code from an identifier. |
| `effectiveSearchLanguage` | `String` | device language, else `"en"` | UserDefaults `"search_language"` when set, else the device language when supported, else `"en"`. |
| `searchLanguage(detected:stored:preferredLanguages:)` | `String` | — | Pure resolution: detected question language, stored, device, `"en"`. |
| `todayISODate()` / `currentYear()` | `String` / `Int` | — | Current date helpers for prompts and recency queries. |
| `searchTimeoutSeconds` | `TimeInterval` | `10` | URLRequest timeout for SearXNG queries |

**Used by:** `SearXNGService.search()`, `SearchViewModel` (request language resolved once per search)

## Content Processing

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `maxSnippetLength` | `Int` | `1600` | Max characters per source content (~400 tokens at 4 chars/token) |
| `snippetThreshold` | `Int` | `150` | If SearXNG snippet shorter than this, fetch full page content |
| `minSnippetLength` | `Int` | `30` | Discard search results with snippets shorter than this |

**Used by:** `AnswerSession.generateAnswer()`, `ContentFetcher`, `SearXNGService.processResults()`

## RRF Ranking

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `rrfK` | `Double` | `60` | Reciprocal Rank Fusion constant (from Cormack, Clarke, Butt paper). Formula: `score(d) = sum 1/(k + rank_i(d))`. Higher k reduces the impact of high rankings. |

**Used by:** `SearXNGService.processResults()`

## URL Deduplication

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `trackingParams` | `Set<String>` | `utm_source, utm_medium, utm_campaign, utm_term, utm_content, ref, fbclid, gclid, msclkid, mc_cid, mc_eid` | URL query parameters stripped during normalization for dedup |

**Used by:** `SearXNGService.normalizeURL()`

## Constraints and Relationships

- **Context window (~4096 tokens):** `maxResults * (maxSnippetLength / 4)` = 5 x 400 = 2000 tokens for sources. Changing `maxResults` or `maxSnippetLength` directly impacts whether prompts fit.
- **Snippet threshold chain:** `minSnippetLength` (30) filters bad results → `snippetThreshold` (150) decides fetch-vs-skip → `maxSnippetLength` (1600) truncates content.
- **No runtime config UI** for most values — only `effectiveSearXNGBaseURL` and `search_language` are user-configurable via Settings.
