# Quickstart Guide

> When to load: New contributor getting started with AISight development.

## Prerequisites

- **Xcode 26+** (beta)
- **Docker** (for local SearXNG)
- **Device:** iPhone 15 Pro+ or Mac with M1+ for testing Apple Intelligence
- **OS:** iOS 26 / macOS 26

## Setup Steps

### 1. Clone and start SearXNG

```bash
git clone <repo>
cd aisight/searxng
docker compose up -d
```

SearXNG starts on `http://localhost:8888` with Google, Bing, Brave, and Wikipedia.

### 2. Open in Xcode

```bash
open AISight/AISight.xcodeproj
```

### 3. Configure (optional)

Default SearXNG URL is `http://localhost:8888`. Change in `AISight/App/AppConfig.swift` if needed.

### 4. Build and run

Select target (iPhone simulator or My Mac) → **Cmd+R**

### Platform notes

- **macOS:** Add "Outgoing Connections (Client)" capability in Signing & Capabilities
- **Physical device:** Replace `localhost` with your Mac's local IP in the app's Settings tab

## Project Structure

```
AISight/AISight/
├── App/              Entry point, config, global state
├── Core/
│   ├── AI/           FoundationModels integration (AnswerSession, SystemPrompt)
│   ├── Search/       SearXNG API client (SearXNGService, models, errors)
│   ├── Fetching/     Web content extraction (ContentFetcher actor)
│   └── Persistence/  SwiftData models (QueryEntry, QueryHistoryStore)
├── Features/
│   ├── Search/       Main search UI + view model
│   ├── History/      Query history
│   ├── Settings/     SearXNG URL config
│   └── Onboarding/   First-launch flow
└── UI/
    ├── Components/   CitationText, SourceCardView, etc.
    └── Theme/        Empty — uses system defaults
```

## Key Files to Read First

1. **`AppConfig.swift`** — All configuration values and their defaults
2. **`SearchViewModel.swift`** — Orchestrates the full search → generate → save pipeline
3. **`AnswerSession.swift`** — Core AI integration with FoundationModels
4. **`SearXNGService.swift`** — Search with RRF ranking and deduplication

## Key Constraints

- **Zero external packages** — everything uses Apple frameworks
- **~4096 token context window** — max 5 sources at ~400 tokens each
- **`@available(iOS 26.0, macOS 26.0, *)`** required on FoundationModels code
- **`@MainActor` on all `@Observable` classes** — Swift 6 strict concurrency
- **No force unwraps** in production code

## Testing

- **Simulator:** Layout and navigation testing only. FoundationModels unavailable.
- **Physical device:** Must be iPhone 15 Pro+ with Apple Intelligence enabled. Required for end-to-end testing.
- **Manual test plan:** See `AISight/TESTING.md` for 16 test scenarios.
