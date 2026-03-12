---
description: Bootstrap an AI-optimized knowledge base in any project
allowed-tools: Bash(ls:*), Bash(find:*), Bash(wc:*), Read, Glob, Grep, Write, Edit, Task, AskUserQuestion
argument-hint: [--minimal|--dry-run]
---

## Initialize Knowledge Base

Create a comprehensive, AI-optimized knowledge base for any project using specialized agents.

### Usage

- `/init-kb` - Full KB generation with plan mode
- `/init-kb --minimal` - Core structure only
- `/init-kb --dry-run` - Preview structure without creating

### Arguments: $ARGUMENTS

---

## Workflow

### Phase 1: Discovery (kb-analyzer)

**Step 1.1: Detect Tech Stack**

Read configuration files to identify the project's technology:

```bash
# Check for config files
ls -la package.json requirements.txt Cargo.toml go.mod pyproject.toml pom.xml build.gradle 2>/dev/null
```

Use the detection rules from `.claude/knowledge-base/config/tech-stacks.yaml` to identify:
- Language (TypeScript, Python, Go, Rust, Java, etc.)
- Framework (Expo, Next.js, Django, FastAPI, etc.)
- Package manager (npm, pip, cargo, etc.)
- Test framework (Jest, pytest, etc.)

**Step 1.2: Map Project Structure**

Analyze directory structure:

```bash
# Find source directories
ls -la src/ app/ lib/ services/ components/ providers/ 2>/dev/null

# Count files by type
find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" 2>/dev/null | wc -l
```

**Step 1.3: Detect Feature Domains**

Group files by feature patterns:
- `services/audio*.ts` → "audio" domain
- `services/auth*.ts` → "auth" domain
- `handlers/*.go` → handler domains
- etc.

**Step 1.4: Find Existing Documentation**

```bash
# Find existing docs
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" | head -50
```

**Step 1.5: Estimate Complexity**

Check thresholds from `.claude/knowledge-base/config/thresholds.yaml`:
- Small (<200 files): Proceed directly
- Medium (200-500 files): Note estimated time
- Large (500-2000 files): Ask for confirmation
- Enterprise (2000+ files): Require explicit confirmation

---

### Phase 2: User Configuration

**Use AskUserQuestion to gather configuration:**

**Question 1: Existing Documentation**

If existing docs are found:
```
Found existing documentation:
- docs/API.md
- docs/ARCHITECTURE.md
- README.md

How should I handle these?
```
Options:
1. Integrate into new KB structure (recommended)
2. Reference but don't move
3. Start fresh (keep existing separate)

**Question 2: Human Docs Location**

```
Where should human-readable documentation go?
```
Options:
1. docs/knowledge_base/ (recommended)
2. Keep in existing: docs/
3. Custom location

**Question 3: Analysis Depth (for large projects)**

```
Project has {count} files. Analysis options:
```
Options:
1. Full analysis (recommended for initial setup)
2. Quick analysis (core domains only)
3. Selective (choose specific directories)

---

### Phase 3: Plan Presentation

Display the proposed KB structure for user approval:

```
╔══════════════════════════════════════════════════════════════════╗
║                    KNOWLEDGE BASE INITIALIZATION PLAN             ║
╠══════════════════════════════════════════════════════════════════╣
║ Project: {project_name}                                          ║
║ Stack: {tech_stack}                                              ║
║ Detected: {domain_count} domains, {service_count} services       ║
╚══════════════════════════════════════════════════════════════════╝

STRUCTURE TO CREATE:
────────────────────

.claude/
├── skills/
│   ├── SKILL.md                    [NEW] Master index
│   ├── domains/                    Feature-specific knowledge
│   │   ├── {domain1}.md           [NEW]
│   │   ├── {domain2}.md           [NEW]
│   │   └── ...
│   ├── patterns/                   Cross-cutting patterns
│   │   ├── {pattern1}.md          [NEW]
│   │   └── ...
│   ├── infrastructure/             Infrastructure knowledge
│   │   └── ...
│   ├── references/                 Quick lookup tables
│   │   └── ...
│   └── onboarding/
│       └── ...
└── kb-meta.json                    [NEW]

{human_docs_path}/
├── README.md                       [NEW]
├── systems/                        Core system specs
├── features/                       Feature specs
├── integrations/                   Third-party integrations
└── testing/                        Test documentation

EXISTING DOCS INTEGRATION:
─────────────────────────
{for each existing doc}
  {source} → {target} ({action})
{end}

ESTIMATED OUTPUT:
─────────────────
  AI Skills: ~{skill_count} files
  Human Docs: ~{doc_count} files

Proceed with this plan? [Y/n/modify]
```

---

### Phase 4: Parallel Agent Execution

After user approval, spawn specialized agents:

**Agent 1: Core Structure**

Using Task tool with kb-analyzer as reference:
- Create `.claude/skills/` directory structure
- Generate `SKILL.md` master index
- Create `kb-meta.json`
- Update `CLAUDE.md` with KB references

**Agent 2: Domain Skills (parallel)**

Using Task tool with kb-skill-writer:
- Read source files for each domain
- Generate concise skill files (300-500 lines each)
- Create cross-references

**Agent 3: Patterns & Infrastructure (parallel)**

Using Task tool with kb-skill-writer:
- Detect patterns (common error handling, state management, etc.)
- Generate pattern skill files
- Generate infrastructure skill files

**Agent 4: Human Documentation (parallel)**

Using Task tool with kb-doc-writer:
- Create comprehensive system docs (1000+ lines)
- Create feature documentation
- Include diagrams, flows, configuration

**Agent 5: References & Onboarding (parallel)**

Using Task tool with kb-skill-writer:
- Generate reference indexes (services, components, etc.)
- Create onboarding guides

**Agent 6: Documentation Refactor (if needed)**

Using Task tool with kb-refactor:
- Migrate existing documentation
- Create deprecation notices
- Update cross-references

---

### Phase 5: Finalization

**Step 5.1: Verify Output**

Check that all planned files were created:
```bash
find .claude/skills -name "*.md" | wc -l
find {human_docs_path} -name "*.md" | wc -l
```

**Step 5.2: Update Metadata**

Create/update `.claude/kb-meta.json`:

```json
{
  "version": "2.0.0",
  "created": "{timestamp}",
  "lastUpdate": "{timestamp}",
  "lastCommitAnalyzed": "{commit_hash}",
  "project": {
    "name": "{project_name}",
    "stack": "{tech_stack}",
    "language": "{language}",
    "framework": "{framework}"
  },
  "paths": {
    "aiSkills": ".claude/skills/",
    "humanDocs": "{human_docs_path}/"
  },
  "structure": {
    "domains": {count},
    "patterns": {count},
    "infrastructure": {count},
    "references": {count},
    "onboarding": {count}
  },
  "mappings": {
    "patterns": [
      {
        "glob": "services/*.ts",
        "skill": "domains/{name}.md",
        "humanDoc": "systems/SYS-XXX-{name}.md"
      }
    ]
  },
  "updateHistory": [
    {
      "date": "{timestamp}",
      "commit": "{hash}",
      "action": "initial_creation",
      "sections": ["all"]
    }
  ]
}
```

**Step 5.3: Generate Summary**

```
Knowledge Base Initialized
==========================
Project: {name}
Tech stack: {stack}

Created:
✓ Master skill: .claude/skills/SKILL.md
✓ Domain skills: {N} created
✓ Pattern skills: {N} created
✓ Infrastructure skills: {N} created
✓ Reference indexes: {N} created
✓ Onboarding guides: 3 created
✓ Human docs: {N} created
✓ Metadata: .claude/kb-meta.json

{if existing_docs_migrated}
Migrated:
✓ Existing docs integrated: {N} files
{end}

Files created: {total}
Estimated lines: {total}

Next steps:
1. Review generated content in .claude/skills/SKILL.md
2. Customize domain skills as needed
3. Run /update-kb after development to keep KB current
```

---

## Tech Stack Detection Reference

| Config Files | Detected Stack |
|--------------|---------------|
| `package.json` + `expo/app.json` | React Native/Expo |
| `package.json` + `next.config.*` | Next.js |
| `package.json` + `nuxt.config.*` | Nuxt.js |
| `package.json` + `@angular/*` | Angular |
| `requirements.txt` + `django` | Django |
| `requirements.txt` + `fastapi` | FastAPI |
| `requirements.txt` + `flask` | Flask |
| `pyproject.toml` | Python (generic) |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml` | Java/Maven |
| `build.gradle` | Java/Gradle |

See `.claude/knowledge-base/config/tech-stacks.yaml` for complete detection rules.

---

## Directory Pattern Detection

| Directory | Domain Suggestion |
|-----------|-------------------|
| `services/` | Service layer pattern |
| `providers/` | Context/Provider pattern |
| `hooks/` | React hooks |
| `components/` | UI component library |
| `handlers/` | Request handlers |
| `controllers/` | MVC controllers |
| `utils/` | Utility functions |
| `config/` | Configuration |
| `tests/`, `__tests__/` | Testing |

---

## Agent References

The following agents are used by this command:

- `.claude/knowledge-base/agents/kb-analyzer.md` - Codebase analysis
- `.claude/knowledge-base/agents/kb-skill-writer.md` - AI skill generation
- `.claude/knowledge-base/agents/kb-doc-writer.md` - Human doc generation
- `.claude/knowledge-base/agents/kb-refactor.md` - Doc migration

---

## Portability Notes

This command works on any project by:

1. **Auto-detecting** tech stack from config files
2. **Using configurable rules** from tech-stacks.yaml
3. **Generating structure** based on actual codebase analysis
4. **Creating project-specific** navigation and references
5. **Adapting templates** to detected framework patterns
