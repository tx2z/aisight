# File Index

> When to load: Finding which file contains a specific type, protocol, or feature.

## App Layer

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| AISightApp.swift | `AISight/AISight/App/` | `AISightApp` | @main entry point, SwiftData container setup, TabView (Search/History/Settings) |
| AppConfig.swift | `AISight/AISight/App/` | `AppConfig` (enum) | Centralized config: SearXNG URL, search params, RRF constant, snippet limits, tracking params |
| AppState.swift | `AISight/AISight/App/` | `AppState` | @MainActor @Observable: server availability, onboarding flag, Apple Intelligence availability check |

## Core/AI

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| AnswerSession.swift | `AISight/AISight/Core/AI/` | `AnswerSession`, `AnswerError` | @MainActor @Observable: orchestrates content fetch, prompt build, FoundationModels streaming. Maps GenerationError to AnswerError |
| SystemPrompt.swift | `AISight/AISight/Core/AI/` | `SystemPrompt` (enum) | Builds LLM instruction text with rules, direct answers, infoboxes, numbered sources, and user query |

## Core/Search

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| SearXNGService.swift | `AISight/AISight/Core/Search/` | `SearXNGService` | Sendable: SearXNG API client, RRF ranking, URL normalization, dedup, availability check |
| SearXNGResult.swift | `AISight/AISight/Core/Search/` | `SearXNGResult`, `SearXNGResponse`, `SearXNGInfobox`, `SearXNGInfoboxURL` | Codable models for SearXNG JSON response |
| SearchService.swift | `AISight/AISight/Core/Search/` | `SearchOutput`, `SearchService` (protocol) | Aggregated search output struct and protocol definition |
| SearchError.swift | `AISight/AISight/Core/Search/` | `SearchError` | Error enum: serverUnavailable, timeout, noResults, invalidResponse |

## Core/Fetching

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| ContentFetcher.swift | `AISight/AISight/Core/Fetching/` | `ContentFetcher` (actor) | Fetches web pages, strips HTML (script/style/nav/header/footer + all tags), decodes entities, truncates to char limit |

## Core/Persistence

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| QueryEntry.swift | `AISight/AISight/Core/Persistence/` | `QueryEntry` (@Model), `SourceInfo` | SwiftData model: id, query, answer, sources, timestamp |
| QueryHistoryStore.swift | `AISight/AISight/Core/Persistence/` | `QueryHistoryStore` | @Observable: save/fetch/delete/clearAll via ModelContext |

## Features

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| SearchView.swift | `AISight/AISight/Features/Search/` | `SearchView` | Main search UI: text field, source cards, streaming answer |
| SearchViewModel.swift | `AISight/AISight/Features/Search/` | `SearchViewModel` | @MainActor @Observable: orchestrates search, generate, save pipeline with cancellation |
| StreamingAnswerView.swift | `AISight/AISight/Features/Search/` | `StreamingAnswerView` | Displays answer text as it streams from the model |
| HistoryView.swift | `AISight/AISight/Features/History/` | `HistoryView` | List of past queries, swipe-delete, clear all |
| HistoryViewModel.swift | `AISight/AISight/Features/History/` | `HistoryViewModel` | History data management |
| SettingsView.swift | `AISight/AISight/Features/Settings/` | `SettingsView` | SearXNG URL config, Test Connection, server status |
| OnboardingView.swift | `AISight/AISight/Features/Onboarding/` | `OnboardingView` | First-launch flow, sets hasSeenOnboarding |

## UI Components

| File | Path | Key Types | Responsibility |
|------|------|-----------|---------------|
| CitationText.swift | `AISight/AISight/UI/Components/` | `CitationText` | Parses markdown + `(via domain)` attributions into styled inline text |
| SourceCardView.swift | `AISight/AISight/UI/Components/` | `SourceCardView` | Source card: favicon with letter fallback, domain, title, expandable snippet, scroll transitions |
| CitationBadge.swift | `AISight/AISight/UI/Components/` | `CitationBadge` | Individual numbered citation badge |
| LoadingDots.swift | `AISight/AISight/UI/Components/` | `LoadingDots` | 3 bouncing dots with staggered spring animations |
| ShimmerEffect.swift | `AISight/AISight/UI/Components/` | `ShimmerModifier`, `SkeletonBlock`, `SearchSkeletonView` | Shimmer gradient mask modifier and skeleton loading views |
| TypingCursor.swift | `AISight/AISight/UI/Components/` | `TypingCursor` | Blinking cursor (PhaseAnimator) appended to streaming text |
| ServerStatusView.swift | `AISight/AISight/UI/Components/` | `ServerStatusView` | Server status with SF Symbol indicators and symbol effects |

## Theme

| File | Path | Notes |
|------|------|-------|
| AppTheme.swift | `AISight/AISight/UI/Theme/` | **Intentionally empty.** Uses system colors (.primary, .secondary), system fonts (.body), numeric spacing. No custom theme. |

## Important Notes

- `@available(iOS 26.0, macOS 26.0, *)` required on AnswerSession, SearchViewModel, and any code using FoundationModels
- `#if canImport(FoundationModels)` used in SearchViewModel and AppState for SDK compatibility
- `Package.swift` exists for syntax validation only — build via Xcode project
- No external Swift packages — system frameworks only
