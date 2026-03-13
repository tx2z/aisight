# AISight Knowledge Base — Master Index

> This file indexes all AI skill files for the AISight project.
> Load specific skills when working on related code.

## Domains

| Skill | Path | When to Load |
|-------|------|-------------|
| AI / FoundationModels | `domains/ai-foundation-models.md` | Modifying AnswerSession, SystemPrompt, or FoundationModels integration |
| Search / SearXNG | `domains/search-searxng.md` | Modifying SearXNGService, RRF ranking, result models, or search logic |
| Content Fetching | `domains/content-fetching.md` | Modifying ContentFetcher, HTML stripping, or truncation |
| Persistence | `domains/persistence.md` | Modifying SwiftData models, QueryHistoryStore, or history features |
| UI / Features | `domains/ui-features.md` | Modifying views, view models, or UI components |

## Patterns

| Skill | Path | When to Load |
|-------|------|-------------|
| Concurrency | `patterns/concurrency.md` | Working with async/await, actors, @MainActor, or Sendable |
| Error Handling | `patterns/error-handling.md` | Adding/modifying error types or user-facing error messages |
| Context Window | `patterns/context-window.md` | Adjusting token budgets, source limits, or truncation |
| Data Flow | `patterns/data-flow.md` | Understanding or modifying the query-to-answer pipeline |

## Infrastructure

| Skill | Path | When to Load |
|-------|------|-------------|
| SearXNG Deployment | `infrastructure/searxng-deployment.md` | Setting up, configuring, or debugging the SearXNG instance |

## References

| Skill | Path | When to Load |
|-------|------|-------------|
| File Index | `references/file-index.md` | Finding which file contains a specific type or feature |
| Config Reference | `references/config-reference.md` | Understanding or modifying AppConfig values |

## Onboarding

| Skill | Path | When to Load |
|-------|------|-------------|
| Quickstart | `onboarding/quickstart.md` | New contributor getting started |
| Architecture Overview | `onboarding/architecture-overview.md` | Understanding the high-level system design |
| Common Tasks | `onboarding/common-tasks.md` | How-to guide for frequent development tasks |

## Existing Documentation

These docs live alongside the source code and contain detailed specs:

| Document | Path | Content |
|----------|------|---------|
| Architecture | `AISight/ARCHITECTURE.md` | Detailed technical architecture, data flow diagrams, component list |
| Scope | `AISight/SCOPE.md` | Product scope, capabilities, limitations, success criteria |
| Dev Log | `AISight/DEVLOG.md` | Architecture decisions, shortcuts taken, known issues |
| Testing | `AISight/TESTING.md` | Manual test plan with 16 scenarios |
| Research | `AISight/RESEARCH.md` | FoundationModels API, SearXNG API, App Store guidelines |

## Human Documentation

Comprehensive docs for developers live in `docs/knowledge_base/`:

| Document | Path |
|----------|------|
| KB Overview | `docs/knowledge_base/README.md` |
| Search Pipeline | `docs/knowledge_base/systems/search-pipeline.md` |
| AI Generation | `docs/knowledge_base/systems/ai-generation.md` |
| Persistence | `docs/knowledge_base/systems/persistence-layer.md` |
| Query & Answer | `docs/knowledge_base/features/query-answer.md` |
| History | `docs/knowledge_base/features/history.md` |
| Settings & Onboarding | `docs/knowledge_base/features/settings-onboarding.md` |
| SearXNG API | `docs/knowledge_base/integrations/searxng-api.md` |
| Test Plan | `docs/knowledge_base/testing/manual-test-plan.md` |
