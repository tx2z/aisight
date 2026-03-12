# AISight Knowledge Base

Human-readable documentation for the AISight project. For AI-optimized skill files, see `.claude/skills/SKILL.md`.

## Systems

Core system specifications:

| Document | Description |
|----------|-------------|
| [Search Pipeline](systems/search-pipeline.md) | End-to-end search, ranking, content fetching, and answer generation |
| [AI Generation](systems/ai-generation.md) | On-device AI via FoundationModels, prompt design, context window |
| [Persistence Layer](systems/persistence-layer.md) | SwiftData models, history storage, settings |

## Features

Feature specifications:

| Document | Description |
|----------|-------------|
| [Query & Answer](features/query-answer.md) | Core Q&A feature: search, stream, cite |
| [History](features/history.md) | Query history persistence and browsing |
| [Settings & Onboarding](features/settings-onboarding.md) | SearXNG configuration and first-launch flow |

## Integrations

External service integrations:

| Document | Description |
|----------|-------------|
| [SearXNG API](integrations/searxng-api.md) | SearXNG JSON API contract, request/response format |

## Testing

| Document | Description |
|----------|-------------|
| [Manual Test Plan](testing/manual-test-plan.md) | 16 test scenarios for pre-release verification |

## Related Documentation

Detailed specs and research live alongside the source code:

- `AISight/ARCHITECTURE.md` — Full technical architecture with diagrams
- `AISight/SCOPE.md` — Product scope, capabilities, and limitations
- `AISight/DEVLOG.md` — Development decisions, shortcuts, and known issues
- `AISight/TESTING.md` — Original manual test plan
- `AISight/RESEARCH.md` — FoundationModels API, SearXNG API, App Store guidelines
