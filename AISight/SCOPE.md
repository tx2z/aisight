# AISight — Product Scope (v1.0)

> Last updated: 2026-03-11

---

## Onboarding Disclaimer

> AISight answers your questions using web sources and on-device AI. All AI processing happens privately on your device — your data never leaves to a cloud AI service. For best results, ask clear factual questions; complex research or real-time topics may be beyond what on-device AI can handle.

---

## What AISight CAN Do (v1.0)

### Core Capabilities

- **Factual Q&A with cited sources** — Users ask a question in natural language; AISight searches the web, reads relevant pages, and synthesizes an answer with inline citations linking back to the original sources.

- **Web search via SearXNG** — Queries are sent to a SearXNG instance (self-hosted or public), which aggregates results from multiple search engines (Google, Bing, DuckDuckGo, etc.) without tracking the user.

- **Fully on-device AI processing** — All language model inference runs on-device using Apple's FoundationModels framework. No user data is sent to any cloud AI service. The only network traffic is search queries to SearXNG and HTTP fetches of web page content.

- **Streaming answers** — Answers appear token-by-token as the on-device model generates them, providing immediate feedback and a responsive feel.

- **Conversation history** — Past queries and answers are persisted locally using SwiftData. Users can revisit previous questions and answers.

- **Configurable SearXNG URL** — Users can point AISight at any SearXNG instance via a settings screen. This supports privacy-conscious users who run their own instance.

- **SearXNG availability indicator** — The app checks whether the configured SearXNG instance is reachable on launch and displays a status indicator. If unreachable, a banner informs the user.

- **Source preview** — Each cited source displays its title, URL, and a brief snippet so users can evaluate credibility before tapping through.

### User Experience

- Clean, native SwiftUI interface optimized for iOS 26.
- Single-screen query interface with streaming answer display.
- Settings screen for SearXNG URL configuration and connection status.
- History view for browsing past queries and answers.
- Error states and loading indicators for all async operations.

---

## What AISight CANNOT Do (v1.0)

### Explicit Limitations

| Limitation | Reason |
|---|---|
| **Deep multi-step research** | The 3B on-device model has a ~4K token context window, insufficient for synthesizing large volumes of information across many sources. AISight is designed for direct factual questions, not investigative research. |
| **Real-time or breaking news** | Search results depend on SearXNG's upstream engines and their indexing speed. Very recent events may not appear in results. The on-device model has a training data cutoff and cannot reason about events after that date without search grounding. |
| **Mathematical computation** | The on-device model does not have a calculator or math engine. It may attempt arithmetic but results are unreliable for anything beyond simple operations. |
| **Code generation or execution** | While the model can produce code-like text, it cannot execute code, verify correctness, or provide reliable programming assistance. This is not a development tool. |
| **Image, audio, or video understanding** | The FoundationModels text model does not process images, audio, or video. AISight is text-only. |
| **Multi-turn conversation / follow-ups** | v1.0 treats each query as independent. There is no conversational context carried between queries (each query starts a fresh session with the model). |
| **Offline operation** | While AI inference is on-device, search and content fetching require an internet connection. Without internet, the app cannot answer new questions. |
| **Non-English fluency** | The on-device model is primarily English-trained. Other languages may work but with reduced quality. |

### Device and OS Requirements

| Requirement | Details |
|---|---|
| **Operating System** | iOS 26 or later (macOS 26 for Mac) |
| **Device** | iPhone 15 Pro, iPhone 15 Pro Max, iPhone 16 series, or later (A17 Pro chip or newer). iPad and Mac with M1 or later. |
| **Apple Intelligence** | Must be enabled in Settings. The on-device model must be downloaded. |
| **Internet** | Required for search and web content fetching. Not required for AI inference. |

### Why These Limitations Exist

The ~4K token context window of the on-device 3B model is the primary constraint. This is roughly equivalent to 3,000 words — the system prompt, user query, search results, and generated answer must all fit within this budget. This forces a design that prioritizes concise, well-sourced answers to direct questions over open-ended exploration.

These are honest trade-offs for a v1.0 product that delivers fully private, on-device AI with zero cloud AI dependencies.

---

## Future Considerations (Post-v1.0)

The following are **not in scope** for v1.0 but are worth tracking for future versions:

- Multi-turn conversational follow-ups within a session.
- Larger context windows if Apple ships larger on-device models.
- Image search and display (using SearXNG's image category).
- Bookmarking and sharing of answers.
- Widget or Shortcut integration for quick queries.
- macOS companion app.
- Localization for non-English languages.
- Advanced search filters (date range, specific sites, etc.).

---

## Success Criteria for v1.0

1. A user can type a factual question and receive a sourced, coherent answer within 15 seconds.
2. Each answer includes at least one citation with a tappable link to the source.
3. The answer streams in real-time as it is generated.
4. The user can configure a custom SearXNG URL and see its connection status.
5. Past queries are saved and browsable.
6. The app handles errors gracefully: no crashes, clear messaging for network failures, model unavailability, or empty search results.
7. Zero data sent to cloud AI services — verifiable via network inspection.
