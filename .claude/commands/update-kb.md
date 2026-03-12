---
description: Update knowledge base with recent development changes
allowed-tools: Bash(git:*), Read, Glob, Grep, Edit, Write, Task, AskUserQuestion
argument-hint: [N (commits)|--dry-run]
---

## Update Knowledge Base

Analyze recent development and update both AI skills (`.claude/skills/`) and human documentation using context from previous initialization.

### Usage

- `/update-kb` - Analyze last 20 commits
- `/update-kb 50` - Analyze last N commits
- `/update-kb --dry-run` - Preview without applying

### Arguments: $ARGUMENTS

---

## Workflow

### Phase 1: Load Context

**Step 1.1: Read KB Metadata**

Load `.claude/kb-meta.json` to get:
- Last analyzed commit hash
- Tech stack (detected during init)
- File-to-documentation mappings
- Human docs location

```bash
# Check metadata exists
cat .claude/kb-meta.json 2>/dev/null
```

If metadata not found:
```
ERROR: KB metadata not found at .claude/kb-meta.json
Please run /init-kb first to initialize the knowledge base.
```

**Step 1.2: Load Mappings**

Use the `mappings.patterns` array from metadata to map file changes to documentation:

```json
{
  "glob": "services/*.ts",
  "skill": "domains/{name}.md",
  "humanDoc": "systems/SYS-XXX-{name}.md"
}
```

---

### Phase 2: Analyze Git Changes

**Step 2.1: Get Commits Since Last Update**

```bash
# Get last analyzed commit from metadata
LAST_COMMIT=$(cat .claude/kb-meta.json | grep lastCommitAnalyzed | cut -d'"' -f4)

# Get commits since then
git log --oneline --name-status $LAST_COMMIT..HEAD

# Get changed files
git diff $LAST_COMMIT..HEAD --name-only
```

Default to last 20 commits if no last commit or if specified:
```bash
git log --oneline --name-status -$N
```

**Step 2.2: Categorize Changes**

For each changed file:
1. Match against mapping patterns
2. Identify affected skill and human doc
3. Analyze change type (added, modified, deleted)

```
Changed File Analysis:
─────────────────────
| File                        | Type     | Skill           | Human Doc       |
|-----------------------------|----------|-----------------|-----------------|
| services/userService.ts     | MODIFIED | domains/user    | SYS-001-user    |
| services/newFeature.ts      | ADDED    | [NEW DOMAIN?]   | [NEW DOC?]      |
| utils/oldHelper.ts          | DELETED  | [DEPRECATION]   | [DEPRECATION]   |
```

**Step 2.3: Detect New Domains**

If new service files don't match existing patterns:
```
New files detected that don't match existing mappings:
- services/newFeatureService.ts
- services/newFeatureHelper.ts

Create new domain? [y/n]
Domain name: ___
```

---

### Phase 3: Update Proposal

**Step 3.1: Generate Proposal**

Display proposed updates for user approval:

```
╔══════════════════════════════════════════════════════════════════╗
║                      KB UPDATE PROPOSAL                           ║
╠══════════════════════════════════════════════════════════════════╣
║ Commits analyzed: {N} ({old_hash}..{new_hash})                   ║
║ Files changed: {count}                                            ║
║ Documents affected: {count}                                       ║
╚══════════════════════════════════════════════════════════════════╝

CHANGES BY DOMAIN:
──────────────────

1. USER SYSTEM ({file_count} files changed)
   ├── services/userService.ts
   │   ├── + createUser(): New function for user creation
   │   └── + updateProfile(): Profile update logic
   └── utils/userHelper.ts
       └── ~ Updated validation signature

   → Update: .claude/skills/domains/user.md
     + Add createUser() to key functions
     + Add updateProfile() example
     + Update validation signature

   → Update: {human_docs_path}/systems/SYS-001-user.md
     + Add "User Creation" section
     + Add "Profile Updates" section
     + Update API reference


2. TESTING ({file_count} files changed)
   ├── tests/user.test.ts [NEW]
   └── tests/helpers.ts [MODIFIED]

   → Update: .claude/skills/patterns/testing-patterns.md
     + Add user test example


3. REFERENCE INDEXES ({count} new files)
   ├── services/newService.ts [NEW]
   └── hooks/useNewFeature.ts [NEW]

   → Update: .claude/skills/references/services-index.md
     + Add newService entry

   → Update: .claude/skills/references/hooks-index.md
     + Add useNewFeature entry


SUMMARY:
────────
  AI Skills to update: {count}
  Human Docs to update: {count}
  Reference indexes to update: {count}
  New domains to create: {count}

Apply changes? [Y/n/selective]
```

**Step 3.2: Handle Selective Updates**

If user chooses "selective":
```
Select updates to apply:
[x] 1. User system updates
[ ] 2. Testing updates
[x] 3. Reference index updates
```

---

### Phase 4: Parallel Update Execution

After approval, spawn update agents:

**Agent 1: AI Skills Updates**

Using Task tool with kb-skill-writer reference:
- Read current skill content
- Read changed source files
- Generate additions (never delete, only add/deprecate)
- Apply minimal, targeted updates

Update rules:
- **ADD** to existing sections
- **DEPRECATE** rather than delete
- **UPDATE** examples with new signatures
- **PRESERVE** manual edits (detect by `<!-- MANUAL -->` comments)

**Agent 2: Human Docs Updates**

Using Task tool with kb-doc-writer reference:
- Read current document
- Analyze change significance
- Generate new sections
- Add to changelog

Content to add:
- New feature sections
- Updated diagrams (if structure changed)
- New code examples
- Changelog entries

**Agent 3: Reference Indexes**

Using Task tool:
- For each new file: parse exports, categorize, add to index
- For deleted files: add deprecation notice
- Update counts in SKILL.md

---

### Phase 5: Finalization

**Step 5.1: Update Metadata**

```json
{
  "lastUpdate": "{new_timestamp}",
  "lastCommitAnalyzed": "{new_commit_hash}",
  "updateHistory": [
    {
      "date": "{timestamp}",
      "commit": "{hash}",
      "action": "update",
      "changes": {
        "skills": ["domains/user.md", "patterns/testing-patterns.md"],
        "humanDocs": ["systems/SYS-001-user.md"],
        "indexes": ["references/services-index.md"]
      }
    },
    ...existing history
  ]
}
```

**Step 5.2: Generate Summary**

```
KB Update Complete
==================
Commits analyzed: {N} ({old_hash}..{new_hash})

Updated:
✓ AI Skills: {N} files
  - domains/user.md (2 functions added)
  - patterns/testing-patterns.md (1 example added)

✓ Human Docs: {N} files
  - systems/SYS-001-user.md (2 sections added)

✓ Reference Indexes: {N} files
  - services-index.md (+1 entry)
  - hooks-index.md (+1 entry)

Metadata updated: .claude/kb-meta.json

Next update will analyze from commit: {new_hash}
```

---

## Safety Rules

- **NEVER delete content** - Add deprecation notices instead
- **Always show proposals** before applying
- **Track changes** in kb-meta.json updateHistory
- **Preserve manual edits** - Look for `<!-- MANUAL -->` markers
- **Maintain consistency** - Keep skill summaries aligned with full docs
- **Atomic updates** - Update metadata only after successful changes

---

## Update Content Guidelines

### For AI Skills (concise)

Add to existing sections:
```markdown
## Key Functions

...existing functions...

### createUser() [NEW]

```typescript
// Code example
```
```

### For Human Docs (comprehensive)

Add new sections:
```markdown
## User Creation [Added: YYYY-MM-DD]

Creating new users with validation...

### Implementation

```typescript
// Full code example
```

### Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
...
```

### For Reference Indexes

Add entries:
```markdown
| newService | `services/newService.ts` | Brief description |
```

---

## Handling Edge Cases

### New Domain Detected

If files don't match existing patterns:
1. Ask user if it's a new domain
2. Get domain name
3. Add to mappings in kb-meta.json
4. Create new skill file
5. Create new human doc (if applicable)

### Deleted Files

Don't delete from docs, add deprecation:
```markdown
### oldFunction() [DEPRECATED: YYYY-MM-DD]

> This function has been removed. Use `newFunction()` instead.
```

### Conflicts

If manual edits detected:
```
WARNING: Manual edits detected in domains/user.md
Lines 45-60 contain <!-- MANUAL --> marker.
Skipping this section. Please review and merge manually.
```

---

## Agent References

The following agents are used by this command:

- `.claude/knowledge-base/agents/kb-skill-writer.md` - Skill updates
- `.claude/knowledge-base/agents/kb-doc-writer.md` - Doc updates

---

## Adaptive Behavior

This command adapts to the project's tech stack:
- Uses mappings from kb-meta.json (set during init)
- Respects custom human_docs path
- Applies stack-specific patterns from init analysis
- Preserves existing structure and conventions
