# AI Generation System

## Overview

AISight generates answers on-device using Apple's FoundationModels framework (iOS 26+). A ~3B parameter language model runs entirely on the device's Neural Engine. No data is sent to cloud AI services.

## Framework

- **Import:** `import FoundationModels`
- **Availability:** `@available(iOS 26.0, macOS 26.0, *)`
- **Model:** `SystemLanguageModel.default` (~3B parameters)
- **Context window:** ~4096 tokens
- **Inference:** On-device, private, no network required

## Session Management

### Creating a Session

```swift
let session = LanguageModelSession(instructions: systemPromptText)
```

- `instructions` parameter sets the system prompt
- **Fresh session per query** — no conversation history carried between queries
- This maximizes available context for sources and answer

### Streaming Response

```swift
let stream = session.streamResponse(to: query)
for try await partial in stream {
    streamingText = partial.content  // full accumulated text, not delta
}
```

- `partial.content` returns the **full** accumulated text each iteration
- UI updates on each chunk for real-time streaming effect

### Availability Check

```swift
if SystemLanguageModel.default.availability == .available {
    // Model is ready
}
```

Model may be unavailable if:
- Device lacks Apple Silicon (A17 Pro+, M1+)
- Apple Intelligence is disabled in Settings
- Model hasn't finished downloading

## System Prompt Design

Built by `SystemPrompt.build(query:sources:directAnswers:infoboxes:)`:

### Structure

```
You are AISight — a private, on-device answer engine...

## Rules
- Answer concisely in 2-4 paragraphs
- Cite EVERY factual claim using [1], [2]
- Synthesize information across sources (don't summarize each sequentially)
- When sources conflict, present both viewpoints
- If sources are insufficient, say so honestly
- NEVER fabricate or hallucinate
- NEVER use prior knowledge — only provided sources

## Direct Answers (optional)
- {instant answers from SearXNG}

## Knowledge Panel (optional)
{Wikipedia/infobox content, truncated to 800 chars}

## Sources
[1] {Title}
URL: {url}
Content: {truncated text}

[2] ...

## User Query
{user's question}
```

### No Sources Path

When search returns no results, the prompt tells the model to say it doesn't have enough information and suggest rephrasing.

## Token Budget

| Component | Budget | Constraint |
|-----------|--------|-----------|
| System prompt | ~150 tokens | Keep rules minimal |
| User query | ~100 tokens | Most queries short |
| Sources (up to 5) | ~2000 tokens | 5 x 1600 chars / 4 |
| Answer | ~1000 tokens | Remaining space |
| **Total** | ~3500 / ~4096 | |

## Error Handling

`LanguageModelSession.GenerationError` cases:

| Error | Meaning | App Response |
|-------|---------|-------------|
| `guardrailViolation` | Content safety triggered | "This query can't be answered on-device." |
| `exceededContextWindowSize` | Prompt too long | "The query is too long for the on-device model." |
| `unsupportedLanguageOrLocale` | Language not supported | "This language is not supported." |
| `rateLimited` | Too many requests | "Rate limited. Please try again shortly." |
| `assetsUnavailable` | Model not downloaded | "On-device model is not available." |
| `concurrentRequests` | Another request active | "Another request is in progress." |
| `refusal` | Model refused to answer | "This query can't be answered on-device." |

## Device Requirements

| Requirement | Details |
|-------------|---------|
| iPhone | 15 Pro, 15 Pro Max, 16 series or later (A17 Pro+) |
| iPad | M1 or later |
| Mac | M1 or later |
| OS | iOS 26.0+ / macOS 26.0+ |
| Apple Intelligence | Must be enabled in Settings |

## Key Implementation Details

- `AnswerSession` is `@MainActor` `@Observable` — properties drive SwiftUI views
- Content fetching happens inside `generateAnswer()` (sequential, not parallel)
- `#if canImport(FoundationModels)` enables compilation on older SDKs
- The model cannot be fine-tuned or customized
- Hallucination risk mitigated by grounding with search results and citation rules
