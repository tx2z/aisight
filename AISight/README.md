# AISight

A native iOS/macOS answer engine that combines web search with on-device AI. AISight searches the web via a self-hosted [SearXNG](https://github.com/searxng/searxng) instance and synthesizes answers using Apple Intelligence — all AI processing happens privately on your device.

## What it can do
- Answer factual, encyclopedic, and "how-to" questions with cited sources
- Search the web via SearXNG (aggregates Google, Bing, DuckDuckGo, Brave)
- Summarize and cite web content on-device — AI never leaves your device
- Stream responses token by token
- Persist query history locally via SwiftData
- Let power users point at their own SearXNG instance

## What it cannot do
- Deep research or multi-hop reasoning (on-device model is ~3B parameters)
- Real-time news with high freshness guarantees
- Complex math or coding assistance
- Image understanding (text-only)
- Work without internet (search requires connectivity)
- Run on devices older than iPhone 15 Pro / iOS 26

## Setup

Two steps required:

### 1. Deploy a SearXNG instance
Follow the [SearXNG Docker guide](https://github.com/searxng/searxng-docker) to deploy your own instance. It needs a public HTTPS URL reachable from iOS devices. Enable JSON format in your SearXNG settings (`search.formats: [html, json]`).

### 2. Configure the app
Open `AISight/App/AppConfig.swift` and set `defaultSearXNGBaseURL` to your instance URL:
```swift
static let defaultSearXNGBaseURL = "https://search.yourdomain.com"
```
Build and run with Xcode 26+ targeting iOS 26.0 or macOS 26.0.

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full technical design.

**Data flow:**
```
User Query -> SearXNG Search -> Content Fetch -> On-device AI -> Streamed Answer with Citations
```

**Tech stack:** Swift 6.1+, SwiftUI, FoundationModels, SwiftData, URLSession

## Privacy

All AI inference runs on-device via Apple Intelligence. Data that leaves your device:
1. Search queries sent to your SearXNG instance
2. HTTP GETs to source URLs for content fetching

No analytics. No tracking. No third-party AI services.

## Known Limitations
- On-device model has a 4,096 token context window — complex queries with many sources may be truncated
- SearXNG can be slow when aggregating multiple engines (8 second timeout configured)
- Model knowledge cutoff is end of 2023 — it relies on search results for current information

## Roadmap (v1.1 ideas)
- Per-user SearXNG onboarding flow
- Focus modes (Academic, Reddit, News)
- Voice input via Speech framework
- Follow-up questions in conversation
- Share/export answers

---
Built for iOS 26 | Apple Intelligence | On-device AI | Self-hosted search via SearXNG
