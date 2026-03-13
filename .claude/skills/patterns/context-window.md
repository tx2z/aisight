# Context Window Management

> When to load: Adjusting token budgets, source limits, truncation, or prompt structure.

## Overview

The on-device ~3B model has a ~4096 token context window. This is the primary architectural constraint. The system prompt, user query, source content, and generated answer must all fit. AISight uses fixed budget allocation with aggressive source truncation.

## Token Budget

| Component | Budget | Config |
|-----------|--------|--------|
| System prompt (rules) | ~150 tokens | Hardcoded in `SystemPrompt.build()` |
| Direct answers / infoboxes | ~100 tokens | Infoboxes truncated to 800 chars |
| User query | ~100 tokens | Most queries are short |
| Source content (up to 5) | ~2000 tokens | `maxResults=5` x `maxSnippetLength=1600` chars (~400 tokens each) |
| Generated answer | ~1000 tokens | Remaining space |
| Overhead (formatting) | ~250 tokens | Source labels, newlines, markers |
| **Total** | **~3500 tokens** | Fits ~4K window |

## AppConfig Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `maxResults` | `5` | Max sources included in prompt |
| `maxSnippetLength` | `1600` | Max chars per source (~400 tokens at 4 chars/token) |
| `snippetThreshold` | `150` | Snippet shorter than this → fetch full page |
| `minSnippetLength` | `30` | Discard results with shorter snippets |

## Truncation Strategy

**Source content:** Simple `String.prefix(maxSnippetLength)` — prefix cut at 1600 characters. No sentence boundary detection. Can cut mid-word.

**Infobox content:** Truncated to 800 chars in `SystemPrompt.build()` with "..." appended.

**No adaptive source count** in current implementation — always uses up to `maxResults` (5) sources regardless of query length. The ARCHITECTURE.md documents reducing to 3 sources for long queries as a design goal, but this is not yet implemented.

## Prompt Assembly Order

```
1. System instructions (rules, format)
2. Direct answers section (optional)
3. Knowledge panel section (optional, truncated to 800 chars)
4. Sources section: [1] Title / URL / Content (up to 5)
5. User query
```

Built by `SystemPrompt.build()` and passed as `instructions` to `LanguageModelSession`.

## No Conversation History

Each query creates a fresh `LanguageModelSession`. No prior turns are carried forward. This is intentional:
- Maximizes available space for source content and answer
- Avoids context window exhaustion from accumulated history
- Simpler implementation — no summarization of prior turns needed

## Key Relationships

- Doubling `maxResults` from 5→10 would add ~2000 tokens → overflow
- Halving `maxSnippetLength` from 1600→800 frees ~1000 tokens but reduces source quality
- Longer system prompts directly reduce space for sources and answer
- `exceededContextWindowSize` GenerationError is caught and shown to user

## Common Modifications

**Reducing source count for long queries:** Check estimated query tokens, if > threshold, reduce `maxResults` to 3.

**Sentence-boundary truncation:** Find last `. ` before `maxSnippetLength`, cut there, append `[truncated]`.

**Dynamic token counting:** Replace 4-chars-per-token heuristic with a more accurate tokenizer if one becomes available.

**Adding conversation history:** Would require summarizing prior turns to fit within budget. Complex tradeoff — each turn of history reduces space for sources.
