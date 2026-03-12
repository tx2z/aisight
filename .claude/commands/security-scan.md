---
description: Run comprehensive OWASP security scan with specialized agents (project)
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(find:*), Bash(pnpm audit:*), Bash(npm audit:*), Bash(yarn audit:*), Bash(pip-audit:*), Read, Glob, Grep, Edit, Write, Task, AskUserQuestion, WebSearch
argument-hint: [scope: full|quick|api-only|web-only|secrets-only|category:A01-A10|category:API1-API10]
---

# Security Scanner

Comprehensive security scan based on **OWASP Top 10** (latest), **OWASP API Security Top 10** (latest), plus additional security checks (secrets, licenses, CVEs, Docker).

## Scan Scope

Parse `$ARGUMENTS` to determine scope:

| Argument | Description |
|----------|-------------|
| `full` (default) | All security checks (OWASP + secrets + licenses + CVEs + optional) |
| `quick` | Critical only (A01, A05, A07, API1, API2, secrets) |
| `api-only` | Backend/API scanning only |
| `web-only` | Frontend scanning only |
| `secrets-only` | Only scan for hardcoded secrets |
| `category:A01` | Single OWASP Web category (A01-A10) |
| `category:API1` | Single OWASP API category (API1-API10) |

---

## Step 1: Tech Stack Detection

Automatically detect the project's technology stack:

### 1.1 Check package.json files

Look for these patterns:

**Backend Frameworks:**
- `@nestjs/*` → NestJS
- `express` → Express.js
- `fastify` → Fastify
- `@hapi/*` → Hapi

**Frontend Frameworks:**
- `@angular/*` → Angular
- `react` → React
- `vue` → Vue.js
- `svelte` → Svelte
- `next` → Next.js

**ORMs/ODMs:**
- `typeorm` → TypeORM
- `prisma` → Prisma
- `sequelize` → Sequelize
- `mongoose` → Mongoose

**Auth Libraries:**
- `passport` → Passport.js
- `@nestjs/jwt` → NestJS JWT
- `jsonwebtoken` → JWT
- `bcrypt` or `bcryptjs` → Password hashing

### 1.2 Check config files

- `tsconfig.json` → TypeScript project
- `angular.json` → Angular project
- `nest-cli.json` → NestJS project
- `docker-compose.yml` → Docker deployment
- `.env*` files → Environment configuration

### 1.3 Directory structure

- `apps/api/` or `src/` with controllers/services → Backend API
- `apps/web/` or `src/app/` with components → Frontend SPA
- `packages/` or `libs/` → Monorepo structure

### 1.4 Present to user

After detection, show:

```
=== Detected Tech Stack ===

Backend:
- Framework: [NestJS 11 / Express / etc.]
- ORM: [TypeORM / Prisma / etc.]
- Auth: [Passport JWT / etc.]

Frontend:
- Framework: [Angular 20 / React / etc.]
- UI Library: [Tailwind / Material / etc.]

Structure: [Monorepo / Single app]

Is this correct? Provide any corrections or press Enter to continue.
```

Use `AskUserQuestion` to confirm or get corrections.

---

## Step 2: Run Security Agents

Based on scope, spawn Task agents for each security domain.

**CRITICAL: SEQUENTIAL BATCH EXECUTION**
- Do NOT spawn all agents in parallel (causes context limit exhaustion)
- Run agents in batches of **maximum 2 agents at a time**
- Wait for each batch to complete before starting the next
- Between batches, summarize findings and clear agent context

**Execution Order:**
1. **Batch 1:** Agent 1 (Auth & Access) + Agent 2 (Injection)
2. **Batch 2:** Agent 3 (Crypto & Data) + Agent 4 (Config & Infra)
3. **Batch 3:** Agent 5 (API-Specific) + Agent 6 (Design & Logging)
4. **Batch 4:** Agent 7 (Secret Scanner) + Agent 8 (License Compliance)
5. **Batch 5:** Agent 9 (CVE Checker) + conditional agents (10, 11)

### Full Scan Agents (run in batches of 2)

#### OWASP Agents (Always Run)

**Agent 1: Auth & Access Control**
- Categories: A01, A07, API1, API2, API3, API5
- Read: `.claude/security/agents/auth-access.md`
- Prompt: Include detected tech stack, focus on auth/access patterns

**Agent 2: Injection**
- Categories: A05
- Read: `.claude/security/agents/injection.md`
- Prompt: Include ORM type, check for SQL/NoSQL/XSS/Command injection

**Agent 3: Crypto & Data Protection**
- Categories: A04, A08
- Read: `.claude/security/agents/crypto-data.md`
- Prompt: Check encryption, hashing, sensitive data exposure

**Agent 4: Config & Infrastructure**
- Categories: A02, A03, API8
- Read: `.claude/security/agents/config-infra.md`
- Prompt: Check security headers, CORS, dependencies

**Agent 5: API-Specific**
- Categories: API4, API6, API7, API9, API10
- Read: `.claude/security/agents/api-specific.md`
- Prompt: Check rate limiting, SSRF, business logic

**Agent 6: Design & Logging**
- Categories: A06, A09, A10
- Read: `.claude/security/agents/design-logging.md`
- Prompt: Check secure design, logging, error handling

#### Additional Security Agents (Always Run)

**Agent 7: Secret Scanner**
- Purpose: Detect hardcoded secrets, API keys, passwords, tokens
- Read: `.claude/security/agents/secrets.md`
- Prompt: Scan for AWS keys, API tokens, passwords, private keys, .env files

**Agent 8: License Compliance**
- Purpose: Check for problematic licenses (GPL, AGPL in commercial projects)
- Read: `.claude/security/agents/licenses.md`
- Prompt: Check package.json, requirements.txt, etc. for license issues

**Agent 9: CVE Checker**
- Purpose: Check for known CVE vulnerabilities in dependencies
- Read: `.claude/security/agents/cve-check.md`
- Prompt: Check dependency versions against known CVEs, use WebSearch if needed

#### Conditional Agents (Run if detected)

**Agent 10: Dependency Audit** (if package manager detected)
- Condition: Run only if `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `requirements.txt`, etc. exists
- Read: `.claude/security/agents/dependency-audit.md`
- Prompt: Run native audit command (npm audit, pnpm audit, pip-audit, etc.)

**Agent 11: Docker Security** (if Docker files detected)
- Condition: Run only if `Dockerfile` or `docker-compose.yml` exists
- Read: `.claude/security/agents/docker-security.md`
- Prompt: Check Dockerfile and docker-compose for security issues

### Quick Scan Agents

Only run Agents 1, 2, and 7 (Auth/Access + Injection + Secrets) for critical checks.

### Secrets-Only Scan

Only run Agent 7 (Secret Scanner).

### Category-Specific Scan

Run only the agent that covers the requested category.

---

## Step 3: Collect Findings

Each agent returns findings in this format:

```
FINDING: [OWASP-ID] Title
SEVERITY: Critical|High|Medium|Low|Info
FILE: path/to/file.ts:lineNumber
DESCRIPTION: What the vulnerability is
CODE:
```typescript
// Code snippet
```
REMEDIATION: How to fix
```

Aggregate all findings and:
1. Deduplicate similar findings
2. Sort by severity (Critical → Info)
3. Group by OWASP category

---

## Step 4: Generate Report

Create report at: `security-reports/YYYY-MM-DD-HHmm-scan.md`

Use the template from `.claude/security/templates/report-template.md`

Report structure:
1. **Executive Summary** - Severity counts, risk assessment
2. **Critical Findings** - Full details with remediation
3. **High Findings** - Full details with remediation
4. **Medium Findings** - Abbreviated format
5. **Low Findings** - List format
6. **Informational** - Bullet list
7. **Recommendations** - Prioritized action items
8. **Appendix** - Scan metadata

---

## Step 5: Fix Mode

After generating the report:

```
=== Security Scan Complete ===

Report saved to: security-reports/YYYY-MM-DD-HHmm-scan.md

Summary:
- Critical: X
- High: X
- Medium: X
- Low: X

Would you like to review and fix Critical/High issues?
```

If user confirms, for each Critical/High finding:

1. Show the finding details
2. Display vulnerable code with context (5 lines before/after)
3. Propose a fix with explanation
4. Ask for confirmation before applying
5. Apply fix using Edit tool
6. Run `pnpm verify` or type-check after fixes
7. Move to next finding

---

## Security Categories Reference

### OWASP Top 10 (Web)

| ID | Name | Agent |
|----|------|-------|
| A01 | Broken Access Control | auth-access |
| A02 | Security Misconfiguration | config-infra |
| A03 | Software Supply Chain Failures | config-infra |
| A04 | Cryptographic Failures | crypto-data |
| A05 | Injection | injection |
| A06 | Insecure Design | design-logging |
| A07 | Authentication Failures | auth-access |
| A08 | Data Integrity Failures | crypto-data |
| A09 | Security Logging & Alerting Failures | design-logging |
| A10 | Mishandling of Exceptional Conditions | design-logging |

### OWASP API Security Top 10

| ID | Name | Agent |
|----|------|-------|
| API1 | Broken Object Level Authorization (BOLA) | auth-access |
| API2 | Broken Authentication | auth-access |
| API3 | Broken Object Property Level Authorization | auth-access |
| API4 | Unrestricted Resource Consumption | api-specific |
| API5 | Broken Function Level Authorization (BFLA) | auth-access |
| API6 | Unrestricted Access to Sensitive Business Flows | api-specific |
| API7 | Server-Side Request Forgery (SSRF) | api-specific |
| API8 | Security Misconfiguration | config-infra |
| API9 | Improper Inventory Management | api-specific |
| API10 | Unsafe Consumption of APIs | api-specific |

### Additional Security Checks (Language Agnostic)

| ID | Name | Agent | Condition |
|----|------|-------|-----------|
| SECRET | Hardcoded Secrets | secrets | Always |
| LICENSE | License Compliance | licenses | Always |
| CVE | Known Vulnerabilities | cve-check | Always |
| AUDIT | Dependency Audit | dependency-audit | If package manager detected |
| DOCKER | Docker Security | docker-security | If Dockerfile/compose detected |

---

## Customization Points

To adapt for other projects, modify:

1. **Tech stack detection** (Step 1) - Add patterns for your frameworks
2. **Agent prompts** (Step 2) - Customize for your tech stack
3. **Report path** - Change `security-reports/` if needed
4. **Severity thresholds** - Adjust what counts as Critical/High/etc.
