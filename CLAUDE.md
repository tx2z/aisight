# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AISight is a native iOS 26 / macOS 26 answer engine. It searches the web via a self-hosted SearXNG instance and synthesizes answers on-device using Apple's FoundationModels framework (Apple Intelligence). Zero external dependencies.

## Build & Run

- **Xcode 26+** required. No SPM dependencies.
- The `Package.swift` exists for syntax validation only — the real build uses an Xcode project.
- Set `AppConfig.defaultSearXNGBaseURL` in `AISight/App/AppConfig.swift` before building.
- Deployment target: iOS 26.0 / macOS 26.0. Will not run on older OS versions.
- **Before building**, check available simulators — don't assume device names. Use `xcodebuild -project AISight/AISight.xcodeproj -scheme AISight -showdestinations` or pick from known available: `iPhone 17 Pro` (iOS 26.2). Device names change across Xcode versions.

## Architecture

```
User Query → SearXNGService (search) → ContentFetcher (HTML→text) → AnswerSession (on-device AI) → Streamed Answer with Citations → SwiftData (history)
```

### Key design decisions

- **Single search, no duplication**: `SearchViewModel` fetches results once, passes them to `AnswerSession.generateAnswer(for:with:)`. The AI never re-searches.
- **@MainActor on all @Observable classes**: `AnswerSession`, `SearchViewModel`, and `AppState` are all `@MainActor` to satisfy Swift 6 strict concurrency. Don't remove this.
- **SearXNGService is Sendable**: Uses `URLSession.shared` with per-request timeouts (no stored session). This is intentional for Swift 6 compliance.
- **ContentFetcher is an actor**: Isolates mutable state for HTML fetching. Uses basic regex stripping, not a full HTML parser.
- **No custom theme**: `AppTheme.swift` is intentionally empty. Use system colors (`.primary`, `.secondary`), system fonts (`.font(.body)`), and numeric spacing directly. This follows KISS — matches ChatGPT/Claude/Perplexity iOS patterns.
- **Liquid glass**: iOS 26 liquid glass is automatic on TabView, NavigationStack, toolbars. Only custom glass usage is `.regularMaterial` on source cards. Don't add `.glassEffect()` to content views.

### Layer structure

| Layer | Path | Responsibility |
|-------|------|---------------|
| App | `AISight/App/` | Entry point, config, global state |
| Core/AI | `AISight/Core/AI/` | FoundationModels session, system prompt |
| Core/Search | `AISight/Core/Search/` | SearXNG API client, models, errors |
| Core/Fetching | `AISight/Core/Fetching/` | URL→clean text extraction |
| Core/Persistence | `AISight/Core/Persistence/` | SwiftData models and store |
| Features | `AISight/Features/` | MVVM: Search, History, Onboarding, Settings |
| UI/Components | `AISight/UI/Components/` | Reusable views: CitationText, SourceCard, etc. |

### Critical files

- **`AnswerSession.swift`** — Core AI integration. `@available(iOS 26.0, macOS 26.0, *)` required. Uses `LanguageModelSession` with `streamResponse(to:)`.
- **`SearchViewModel.swift`** — Orchestrates search→generate→save flow. Owns `currentTask` for cancellation support.
- **`SearXNGService.swift`** — Builds URLs with `URLComponents` (not string interpolation). Handles timeout, connectivity, and empty results.
- **`SystemPrompt.swift`** — Builds the LLM instruction with numbered sources. Has a separate path when no sources are available.
- **`CitationText.swift`** — Shared citation parser (AttributedString). Used in both StreamingAnswerView and HistoryDetailView.

## Constraints

- **`@available(iOS 26.0, macOS 26.0, *)` required** on everything touching FoundationModels.
- **No `try!` or force unwraps** in production code.
- **No external Swift packages** — system frameworks only.
- **SearXNG URL stored in UserDefaults** (not Keychain — it's not a secret).
- **SearXNG timeout is 8 seconds** — it queries multiple engines in parallel and can be slow.
- **Context window is ~4096 tokens** — max 5 sources, each truncated to 1600 chars (~400 tokens).

## FoundationModels API (iOS 26)

```swift
// Init — verify exact params against SDK; guardrails/tools may not exist
let session = LanguageModelSession(model: .default, instructions: systemPromptText)

// Stream
let stream = session.streamResponse(to: query)
for try await partial in stream { ... }

// Errors: LanguageModelSession.GenerationError
// .guardrailViolation, .exceedsContextWindowSize, .unsupportedLanguage, .rateLimited

// Availability
SystemLanguageModel.default.availability // .available, .unavailable(reason)
```

## Known issues to verify in Xcode

- `LanguageModelSession` init signature — the `guardrails:` and `tools:` params need confirmation against actual SDK headers.
- `"\(partial)"` string interpolation on stream response — may need `.text` or `.currentText` property instead.
- `Package.swift` declares a library target but `AISightApp.swift` has `@main` — build via Xcode project, not SPM.
