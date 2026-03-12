---
description: Run comprehensive performance scan with specialized agents (project)
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(find:*), Bash(npm run build:*), Read, Glob, Grep, Edit, Write, Task, AskUserQuestion, WebSearch
argument-hint: "[scope: full|quick|frontend|backend|database|memory|bundle|runtime|network]"
---

# Performance Scanner

Comprehensive performance analysis detecting bottlenecks, optimization opportunities, and best practice violations across algorithm complexity, memory usage, database queries, frontend rendering, network efficiency, async patterns, and build configuration.

## Scan Scope

Parse `$ARGUMENTS` to determine scope:

| Argument | Description |
|----------|-------------|
| `full` (default) | All performance checks |
| `quick` | Critical bottlenecks only (faster) |
| `frontend` | Frontend performance only (PERF04, PERF07) |
| `backend` | Backend performance only (PERF01, PERF02, PERF03, PERF06) |
| `database` | Database optimization only (PERF03) |
| `memory` | Memory analysis only (PERF02) |
| `bundle` | Build/bundle analysis only (PERF07) |
| `runtime` | Runtime performance (PERF01, PERF06) |
| `network` | Network efficiency only (PERF05) |

---

## Step 1: Tech Stack Detection

Automatically detect the project's technology stack for targeted analysis.

### 1.1 Check package.json / Build Configuration

Look for these patterns:

**Frontend Frameworks:**
- `react`, `react-dom` - React
- `vue` - Vue.js
- `@angular/*` - Angular
- `svelte` - Svelte
- `next` - Next.js
- `nuxt` - Nuxt.js

**Backend Frameworks:**
- `express` - Express.js
- `@nestjs/*` - NestJS
- `fastify` - Fastify
- `koa` - Koa
- `django` (requirements.txt/pyproject.toml) - Django
- `fastapi` - FastAPI
- `flask` - Flask
- `laravel` (composer.json) - Laravel
- `spring-boot` (pom.xml/build.gradle) - Spring Boot

**Build Tools:**
- `webpack` - Webpack
- `vite` - Vite
- `rollup` - Rollup
- `esbuild` - esbuild
- `parcel` - Parcel
- `turbo` - Turborepo

**ORMs/Database:**
- `typeorm` - TypeORM
- `prisma` - Prisma
- `sequelize` - Sequelize
- `mongoose` - Mongoose
- `sqlalchemy` - SQLAlchemy
- `django.db` - Django ORM

### 1.2 Check Configuration Files

- `webpack.config.js` - Webpack project
- `vite.config.ts` - Vite project
- `next.config.js` - Next.js project
- `angular.json` - Angular project
- `tsconfig.json` - TypeScript project
- `Dockerfile` - Containerized app
- `.env*` files - Environment configuration
- `prisma/schema.prisma` - Prisma database
- `requirements.txt` / `pyproject.toml` - Python project
- `composer.json` - PHP project
- `pom.xml` / `build.gradle` - Java project
- `go.mod` - Go project

### 1.3 Analyze Directory Structure

- `src/components/` - Frontend components
- `src/pages/` or `app/` - Page-based routing
- `src/api/` or `src/controllers/` - Backend API
- `src/services/` - Business logic
- `src/models/` or `src/entities/` - Database models
- `public/` or `static/` - Static assets
- `migrations/` - Database migrations

### 1.4 Present to User

After detection, show:

```
=== Detected Tech Stack ===

Frontend:
- Framework: [React 18 / Vue 3 / Angular 17 / etc.]
- Build Tool: [Webpack / Vite / etc.]
- UI Library: [Tailwind / Material / etc.]

Backend:
- Framework: [NestJS / Express / Django / etc.]
- Runtime: [Node.js / Python / Go / etc.]
- ORM: [TypeORM / Prisma / SQLAlchemy / etc.]

Database:
- Type: [PostgreSQL / MySQL / MongoDB / etc.]

Is this correct? Provide any corrections or press Enter to continue.
```

Use `AskUserQuestion` to confirm or get corrections.

---

## Step 2: Run Performance Agents

Based on scope, spawn Task agents for each performance domain.

### Full Scan Agents (run sequentially)

#### Performance Agents

**Agent 1: Algorithm Complexity (PERF01)**
- Focus: Time complexity, data structure efficiency, memoization
- Read: `.claude/performance/agents/algorithm-complexity.md`
- Prompt: Include detected tech stack, analyze loops, recursion, sorting, searching

**Agent 2: Memory (PERF02)**
- Focus: Memory leaks, allocation patterns, cleanup
- Read: `.claude/performance/agents/memory.md`
- Prompt: Check for leaks, unbounded growth, closure retention

**Agent 3: Database (PERF03)**
- Focus: Query optimization, N+1, indexing
- Read: `.claude/performance/agents/database.md`
- Prompt: Include ORM type, analyze query patterns

**Agent 4: Frontend (PERF04)**
- Focus: Render performance, bundle size, Web Vitals
- Read: `.claude/performance/agents/frontend.md`
- Prompt: Check rendering, lazy loading, code splitting

**Agent 5: Network (PERF05)**
- Focus: Request efficiency, caching, compression
- Read: `.claude/performance/agents/network.md`
- Prompt: Analyze API calls, caching strategies, payload sizes

**Agent 6: Async Operations (PERF06)**
- Focus: Parallel execution, batching, debouncing
- Read: `.claude/performance/agents/async-operations.md`
- Prompt: Check async patterns, Promise usage, event handling

**Agent 7: Build/Bundle (PERF07)**
- Focus: Dependencies, tree shaking, minification
- Read: `.claude/performance/agents/build-bundle.md`
- Prompt: Include build tool, analyze bundle composition

### Quick Scan Agents

Only run Agents 1, 3, and 4 for critical performance checks:
- Algorithm Complexity (critical bottlenecks)
- Database (N+1 and missing indexes)
- Frontend (render blocking, large bundles)

### Scope-Specific Agents

| Scope | Agents |
|-------|--------|
| `frontend` | PERF04 (Frontend) + PERF07 (Build/Bundle) |
| `backend` | PERF01 (Algorithm) + PERF02 (Memory) + PERF03 (Database) + PERF06 (Async) |
| `database` | PERF03 (Database) only |
| `memory` | PERF02 (Memory) only |
| `bundle` | PERF07 (Build/Bundle) only |
| `runtime` | PERF01 (Algorithm) + PERF06 (Async) |
| `network` | PERF05 (Network) only |

---

## Step 3: Collect Findings

Each agent returns findings in this format:

```
FINDING: [PERF-ID] Title
IMPACT: Critical|High|Medium|Low
EFFORT: Low|Medium|High
FILE: path/to/file.ts:lineNumber
DESCRIPTION: What the performance issue is
SLOW_CODE:
```typescript
// Current slow implementation
```
OPTIMIZED_CODE:
```typescript
// Recommended optimized implementation
```
ESTIMATED_GAIN: Description of expected improvement
BENCHMARK: How to measure the improvement
```

Aggregate all findings and:
1. Deduplicate similar findings
2. Calculate Performance Score (0-100)
3. Sort by impact (Critical -> Low)
4. Group by category
5. Identify Quick Wins (Low effort + High/Medium impact)

---

## Step 4: Generate Report

Create report at: `performance-reports/YYYY-MM-DD-HHmm-scan.md`

Use the template from `.claude/performance/templates/performance-report.md`

Report structure:
1. **Performance Score** - Overall score with breakdown
2. **Executive Summary** - Key findings overview
3. **Critical Bottlenecks** - Immediate action items
4. **Quick Wins** - Low effort, high impact fixes
5. **Major Optimizations** - Significant improvements requiring effort
6. **Medium/Low Findings** - Other improvements
7. **Benchmark Suggestions** - How to measure improvements
8. **Monitoring Recommendations** - Ongoing performance tracking

---

## Step 5: Optimization Mode

After generating the report:

```
=== Performance Scan Complete ===

Report saved to: performance-reports/YYYY-MM-DD-HHmm-scan.md

Performance Score: XX/100

Summary:
- Critical: X bottlenecks
- Quick Wins: X opportunities
- High Impact: X optimizations
- Medium/Low: X improvements

Would you like to apply Quick Win optimizations?
```

If user confirms, for each Quick Win:

1. Show the finding details
2. Display current code with context
3. Propose optimized version with explanation
4. Ask for confirmation before applying
5. Apply fix using Edit tool
6. Run type-check/lint after fixes
7. Move to next finding

---

## Performance Categories Reference

### Performance Agents

| ID | Name | Focus Areas |
|----|------|-------------|
| PERF01 | Algorithm Complexity | O(n^2) loops, memoization, data structures, sorting |
| PERF02 | Memory | Leaks, unbounded caches, closures, cleanup |
| PERF03 | Database | N+1 queries, indexes, query optimization, pooling |
| PERF04 | Frontend | Web Vitals, bundle size, lazy loading, rendering |
| PERF05 | Network | Compression, caching, batching, CDN |
| PERF06 | Async Operations | Promise.all, debounce, throttle, batching |
| PERF07 | Build/Bundle | Dependencies, tree shaking, minification |

### Impact Levels

| Level | Description | Action Timeline |
|-------|-------------|-----------------|
| Critical | Severe performance degradation, user-facing impact | Immediate |
| High | Significant slowdown, noticeable to users | This sprint |
| Medium | Measurable impact, affects responsiveness | Within 30 days |
| Low | Minor optimization, best practice | When convenient |

### Effort Levels

| Level | Description |
|-------|-------------|
| Low | < 1 hour, simple code change |
| Medium | 1-4 hours, moderate refactoring |
| High | > 4 hours, significant redesign |

---

## Customization Points

To adapt for other projects, modify:

1. **Tech stack detection** (Step 1) - Add patterns for your frameworks
2. **Agent prompts** (Step 2) - Customize for your tech stack
3. **Report path** - Change `performance-reports/` if needed
4. **Impact thresholds** - Adjust what counts as Critical/High/etc.
5. **Quick Win criteria** - Modify effort/impact thresholds
