# SearXNG Deployment

> When to load: Setting up, configuring, or debugging the SearXNG instance.

## Overview

AISight requires a SearXNG instance for web search. The project includes a Docker Compose setup for local development. Users configure their instance URL in the app's Settings screen.

## Local Development Setup

### Prerequisites
- Docker and Docker Compose installed

### Start SearXNG

```bash
cd searxng
docker compose up -d
```

This starts SearXNG on `http://localhost:8888` with the following engines enabled:
- Google
- Bing
- Brave
- Wikipedia

### Stop SearXNG

```bash
cd searxng
docker compose down
```

## App Configuration

### Default URL

```swift
// AppConfig.swift
static let defaultSearXNGBaseURL = "http://localhost:8888"
```

### User Override

Stored in UserDefaults key `"searxng_base_url"`. Set via Settings screen.

```swift
static var effectiveSearXNGBaseURL: String {
    UserDefaults.standard.string(forKey: "searxng_base_url") ?? defaultSearXNGBaseURL
}
```

All service code uses `effectiveSearXNGBaseURL`, never the default directly.

## Availability Checking

### How It Works

`AppState.checkServerAvailability()` delegates to `SearXNGService.checkAvailability()`:

1. Sends a test query: `GET {baseURL}/search?q=test&format=json&engines=...&language=en`
2. Returns `true` if HTTP 2xx response
3. Returns `false` on any error

### When It Runs

- On app launch
- When app returns to foreground (`scenePhase` change)
- When user changes SearXNG URL in Settings
- When user taps "Test Connection" button

**No background polling timer** — all checks are event-driven.

### UI Indicators

| State | Display |
|-------|---------|
| Reachable | Green circle, "Connected" |
| Unreachable | Red circle, "Unreachable" |
| Checking | Gray spinner, "Checking..." |
| Not configured | Orange circle, "Not set" |

## API Contract

### Endpoint

```
GET {baseURL}/search?q={query}&format=json&engines=google,bing,brave&language={lang}&categories=general
```

### Timeout

10 seconds (`AppConfig.searchTimeoutSeconds`)

### Expected Response

```json
{
  "query": "...",
  "results": [
    {
      "url": "...",
      "title": "...",
      "content": "snippet text...",
      "engine": "google",
      "engines": ["google", "bing"],
      "score": 5.2,
      "positions": [1, 3],
      "category": "general"
    }
  ],
  "answers": ["direct answer text"],
  "suggestions": ["related query"],
  "infoboxes": [{ "infobox": "Title", "content": "..." }],
  "unresponsive_engines": []
}
```

### Error States

| Error | App Behavior |
|-------|-------------|
| Timeout (>10s) | `SearchError.timeout` → user message |
| HTTP 4xx/5xx | `SearchError.serverUnavailable` |
| Connection refused | `SearchError.serverUnavailable` |
| No internet | URLError caught → offline message |
| Empty results | `SearchError.noResults` |

## Device-Specific Notes

**Physical iOS device:** Replace `localhost` with your Mac's local IP address in the app's Settings tab. The device cannot reach `localhost` on your Mac.

**macOS app:** Add "Outgoing Connections (Client)" capability in Xcode → Signing & Capabilities. Without this, network requests will fail silently.

**Production deployment:** Deploy your own instance following the [SearXNG Docker guide](https://github.com/searxng/searxng-docker). Update `AppConfig.defaultSearXNGBaseURL` before shipping.

## Common Issues

| Issue | Fix |
|-------|-----|
| "Search server is unavailable" | Check Docker is running: `docker ps` |
| Timeout errors | SearXNG queries multiple engines — increase `searchTimeoutSeconds` |
| No results for queries | Check SearXNG logs: `docker compose logs -f` |
| 403 from upstream engines | Some engines rate-limit; try different engines |
| Can't connect from iPhone | Use Mac's IP instead of localhost |
