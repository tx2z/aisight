---
description: Run comprehensive multi-perspective code review with specialized agents
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(find:*), Read, Glob, Grep, Edit, Write, Task, AskUserQuestion, WebSearch
argument-hint: "[mode: full|quick|peer|arch|security|product|cto|pr] [path/to/file-or-directory]"
---

# Multi-Perspective Code Review

Comprehensive code review using specialized AI agents representing different stakeholder perspectives: Peer Developer, Architect, Security, Product, and CTO/Strategic.

## Review Modes

Parse `$ARGUMENTS` to determine mode and target:

| Argument | Description |
|----------|-------------|
| `full` (default) | All perspectives (Peer + Architect + Security + Product + CTO) |
| `quick` | Quick review (Peer + Security only) |
| `peer` | Peer developer perspective only |
| `arch` | Software architect perspective only |
| `security` | Security reviewer perspective only |
| `product` | Product perspective only |
| `cto` | CTO/strategic perspective only |
| `pr` | Pull request mode (focus on git diff) |
| `path/to/file` | Review specific file with all perspectives |
| `path/to/directory/` | Review specific directory with all perspectives |

---

## Step 1: Target and Context Detection

### 1.1 Determine Review Target

Based on `$ARGUMENTS`:

1. **No path specified**: Review entire project (exclude node_modules, vendor, dist, build, .git)
2. **File path**: Review single file
3. **Directory path**: Review all files in directory
4. **PR mode**: Get diff with `git diff main...HEAD` or `git diff HEAD~1`

### 1.2 Tech Stack Detection

Automatically detect the project's technology stack:

**Check package.json / requirements.txt / go.mod / Cargo.toml / *.csproj:**

**TypeScript/JavaScript:**
- `@nestjs/*` -> NestJS
- `express` -> Express.js
- `fastify` -> Fastify
- `react` / `next` -> React/Next.js
- `@angular/*` -> Angular
- `vue` -> Vue.js

**Python:**
- `django` -> Django
- `flask` -> Flask
- `fastapi` -> FastAPI
- `sqlalchemy` -> SQLAlchemy ORM

**PHP:**
- `laravel/*` -> Laravel
- `symfony/*` -> Symfony

**.NET/C#:**
- `Microsoft.AspNetCore.*` -> ASP.NET Core
- `EntityFrameworkCore` -> EF Core

**Go:**
- `github.com/gin-gonic/gin` -> Gin
- `github.com/labstack/echo` -> Echo
- `github.com/gofiber/fiber` -> Fiber

**Java:**
- `spring-boot` -> Spring Boot
- `jakarta.*` -> Jakarta EE

**Rust:**
- `actix-web` -> Actix
- `axum` -> Axum
- `rocket` -> Rocket

### 1.3 Present Detection Summary

```
=== Code Review Setup ===

Target: [File/Directory/Project/PR Diff]
Path: [path or "entire project"]

Detected Stack:
- Language: [TypeScript/Python/Go/etc.]
- Framework: [NestJS/Django/Spring/etc.]
- Testing: [Jest/Pytest/Go test/etc.]

Review Mode: [full/quick/peer/arch/security/product/cto/pr]
Perspectives: [List of agents to run]

Press Enter to continue or provide corrections.
```

Use `AskUserQuestion` to confirm or get corrections.

---

## Step 2: Run Review Agents

Based on mode, spawn Task agents for each perspective.

### Full Review Agents (run sequentially)

**Agent 1: Peer Developer (PEER01)**
- Read: `.claude/review/agents/peer-developer.md`
- Prompt: Include detected tech stack, focus on code quality and readability
- Output: Inline PR-style comments

**Agent 2: Software Architect (ARCH01)**
- Read: `.claude/review/agents/architect.md`
- Prompt: Include architecture patterns, evaluate design decisions
- Output: Architecture assessment with Mermaid diagrams

**Agent 3: Security Reviewer (SEC01)**
- Read: `.claude/review/agents/security-reviewer.md`
- Prompt: Check for vulnerabilities, security best practices
- Output: Security findings with severity ratings

**Agent 4: Product Perspective (PROD01)**
- Read: `.claude/review/agents/product-perspective.md`
- Prompt: Evaluate UX impact, accessibility, i18n
- Output: Product impact assessment

**Agent 5: CTO/Strategic (CTO01)**
- Read: `.claude/review/agents/cto-strategic.md`
- Prompt: Assess strategic alignment, long-term implications
- Output: Executive summary with recommendations

### Quick Review Agents

Only run Agents 1 (Peer) and 3 (Security) for rapid feedback.

### Single Perspective

Run only the requested agent.

### PR Mode

1. Get the diff: `git diff main...HEAD` or specified base
2. Focus all agents only on changed lines
3. Provide before/after context

---

## Step 3: Collect Findings

Each agent returns findings in this format:

```
FINDING: [PERSPECTIVE-ID] Title
SEVERITY: Critical|High|Medium|Low|Info
CATEGORY: [Category within perspective]
FILE: path/to/file.ext:lineNumber
DESCRIPTION: What the issue is
CODE:
```language
// Code snippet
```
SUGGESTION: How to improve
RATIONALE: Why this matters
```

Aggregate all findings and:
1. Deduplicate similar findings across perspectives
2. Sort by severity (Critical -> Info)
3. Group by perspective
4. Cross-reference findings that multiple perspectives flagged

---

## Step 4: Generate Report

Create report at: `review-reports/YYYY-MM-DD-HHmm-review.md`

Use the template from `.claude/review/templates/review-report.md`

Report structure:
1. **Executive Summary** - High-level overview, key concerns
2. **Review Statistics** - Findings by severity and perspective
3. **Critical Findings** - Full details with suggestions
4. **High Priority Findings** - Full details with suggestions
5. **Medium Priority Findings** - Abbreviated format
6. **Low Priority Findings** - List format
7. **Perspective Summaries** - Summary from each agent
8. **Recommended Actions** - Prioritized action items
9. **Appendix** - Review metadata

---

## Step 5: Interactive Mode

After generating the report:

```
=== Code Review Complete ===

Report saved to: review-reports/YYYY-MM-DD-HHmm-review.md

Summary by Perspective:
- Peer Developer: X findings (Y critical, Z high)
- Architect: X findings (Y critical, Z high)
- Security: X findings (Y critical, Z high)
- Product: X findings (Y critical, Z high)
- CTO/Strategic: X findings (Y critical, Z high)

Total: X findings (Y critical, Z high, W medium, V low)

Would you like to:
1. Review and apply fixes for Critical/High issues
2. View detailed findings for a specific perspective
3. Export as GitHub PR comments format
4. End review
```

If user chooses to apply fixes:

For each Critical/High finding:
1. Show the finding details
2. Display code with context (5 lines before/after)
3. Show suggested fix with explanation
4. Ask for confirmation before applying
5. Apply fix using Edit tool
6. Run relevant tests/linting after fix if available
7. Move to next finding

---

## Perspective Reference

### Agent Mapping

| ID | Perspective | Focus Areas |
|----|-------------|-------------|
| PEER01 | Peer Developer | Code quality, readability, best practices |
| ARCH01 | Architect | Design patterns, architecture, scalability |
| SEC01 | Security | OWASP, vulnerabilities, secure coding |
| PROD01 | Product | UX, accessibility, i18n, analytics |
| CTO01 | CTO/Strategic | Strategy, maintainability, compliance |

### Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| Critical | Must fix before merge | Block PR |
| High | Should fix before merge | Strong recommendation |
| Medium | Should fix soon | Plan for next sprint |
| Low | Nice to have | Address when convenient |
| Info | Informational | No action required |

---

## Customization Points

To adapt for your project:

1. **Add custom rules** - Modify agent files in `review/agents/`
2. **Adjust severity** - Change thresholds in agent files
3. **Tech stack patterns** - Add detection patterns in Step 1.2
4. **Report format** - Modify `review/templates/review-report.md`
5. **Skip patterns** - Add paths to ignore in Step 1.1
