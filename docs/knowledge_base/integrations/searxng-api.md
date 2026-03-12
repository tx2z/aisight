# SearXNG API Integration

## Overview

AISight uses SearXNG as its web search backend. SearXNG is a free, open-source metasearch engine that aggregates results from multiple engines without tracking users.

## API Endpoint

```
GET {baseURL}/search
```

## Request Parameters

| Parameter | Value | Source |
|-----------|-------|--------|
| `q` | User's query (URL-encoded) | User input |
| `format` | `json` | Hardcoded |
| `engines` | `google,bing,brave` | `AppConfig.searchEngines` |
| `language` | `en` (default) | UserDefaults or `AppConfig.defaultSearchLanguage` |
| `categories` | `general` | `AppConfig.searchCategories` |

**Timeout:** 10 seconds (`AppConfig.searchTimeoutSeconds`)

## Response Format

```json
{
  "query": "what is the capital of france",
  "number_of_results": 54200000,
  "results": [
    {
      "url": "https://en.wikipedia.org/wiki/Paris",
      "title": "Paris - Wikipedia",
      "content": "Paris is the capital and largest city of France...",
      "engine": "google",
      "engines": ["google", "bing", "brave"],
      "score": 9.0,
      "category": "general",
      "positions": [1, 1, 2],
      "publishedDate": null
    }
  ],
  "answers": ["Paris"],
  "suggestions": ["capital cities of europe"],
  "infoboxes": [
    {
      "infobox": "Paris",
      "content": "Paris is the capital...",
      "urls": [{ "title": "Wikipedia", "url": "https://..." }]
    }
  ],
  "unresponsive_engines": []
}
```

## Fields Used by AISight

### Per Result

| Field | Usage |
|-------|-------|
| `url` | ContentFetcher target, citation link |
| `title` | Source card display, citation label |
| `content` | Snippet text; fallback if page fetch fails |
| `engine` | Engine badge on source cards |
| `engines` | RRF ranking (which engines returned this result) |
| `score` | Engine-level relevance for RRF rank building |

### Response-Level

| Field | Usage |
|-------|-------|
| `answers` | Direct answers injected into system prompt |
| `suggestions` | Not currently displayed in v1.0 |
| `infoboxes` | Knowledge panels injected into system prompt (truncated to 800 chars) |
| `unresponsive_engines` | Not currently displayed |

## URL Normalization for Deduplication

Before dedup, URLs are normalized:

1. Lowercase entire URL
2. Strip tracking query parameters: `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`, `ref`, `fbclid`, `gclid`, `msclkid`, `mc_cid`, `mc_eid`
3. Remove URL fragment (`#...`)
4. Strip `www.` prefix from host
5. Strip trailing `/` from path
6. Reconstruct with remaining query parameters

## RRF Ranking

Reciprocal Rank Fusion combines rankings from multiple engines:

```
score(d) = sum over engines i: 1 / (k + rank_i(d))
```

Where `k = 60` (standard constant). A result appearing in multiple engines with high ranks gets a higher combined score than a result appearing in only one engine.

## Error Handling

| HTTP Status | App Behavior |
|-------------|-------------|
| 200 | Parse results, proceed |
| 4xx/5xx | `SearchError.serverUnavailable` |
| Timeout | `SearchError.timeout` |
| Network error | `SearchError.serverUnavailable` |
| Empty results | `SearchError.noResults` |

## Rate Limiting

- Depends on SearXNG instance configuration
- Upstream engines (Google, Bing) may rate-limit the instance
- Self-hosted instances recommended for reliable access
- No retry logic in AISight v1.0

## Swift Models

```swift
struct SearXNGResult: Codable, Identifiable, Sendable {
    let url: String
    let title: String
    let content: String?
    let engine: String?
    let score: Double?
    let engines: [String]?
    let positions: [Int]?
    let category: String?
    let publishedDate: String?
}

struct SearXNGResponse: Codable, Sendable {
    let query: String?
    let results: [SearXNGResult]
    let numberOfResults: Int?   // "number_of_results"
    let answers: [String]?
    let suggestions: [String]?
    let infoboxes: [SearXNGInfobox]?
    let unresponsiveEngines: [[String]]?  // "unresponsive_engines"
}

struct SearXNGInfobox: Codable, Sendable {
    let infobox: String?
    let content: String?
    let urls: [SearXNGInfoboxURL]?
}
```
