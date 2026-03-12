---
description: Generate multi-format release notes from Git commit history (project)
allowed-tools: Bash(git:*), Bash(ls:*), Bash(cat:*), Read, Glob, Grep, Edit, Write, Task, AskUserQuestion, WebSearch
argument-hint: "[mode: technical|marketing|internal|security|full] [--from=<tag/commit>] [--to=<tag/commit>] [--version=<semver>] [--date=<date>]"
---

# Release Notes Generator

Generate comprehensive release notes for multiple audiences from Git commit history using specialized agents.

## Parse Arguments

Parse `$ARGUMENTS` to determine generation mode and parameters:

### Modes

| Mode | Description | Agent |
|------|-------------|-------|
| `technical` | GitHub/developer release notes | REL01 |
| `marketing` | App store/end-user notes | REL02 |
| `internal` | Team/stakeholder communication | REL03 |
| `security` | CVE/vulnerability documentation | REL04 |
| `full` | Generate all formats | All agents |
| (none) | Interactive mode | Ask user |

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `--from=<ref>` | Starting commit/tag | Auto-detect previous tag |
| `--to=<ref>` | Ending commit/tag | HEAD |
| `--version=<semver>` | Version number | Extract from tag or ask |
| `--date=<date>` | Release date | Today |

---

## Step 1: Validate Git Repository

Verify we're in a Git repository:

```bash
git rev-parse --is-inside-work-tree
```

If not a Git repository, inform user and exit.

---

## Step 2: Determine Commit Range

### 2.1 Auto-detect Previous Tag (if --from not provided)

```bash
# Get the most recent tag
git describe --tags --abbrev=0 HEAD~1 2>/dev/null

# If no tags exist, use first commit
git rev-list --max-parents=0 HEAD
```

### 2.2 Validate References

```bash
# Validate --from reference
git rev-parse --verify <from-ref>

# Validate --to reference
git rev-parse --verify <to-ref>
```

### 2.3 Get Commit Count

```bash
git rev-list --count <from>..<to>
```

Present to user:

```
=== Commit Range ===

From: <from-ref> (<commit-sha>)
To:   <to-ref> (<commit-sha>)
Commits: <count>

Is this correct? [Y/n]
```

Use `AskUserQuestion` to confirm or get corrections.

---

## Step 3: Extract Git Information

### 3.1 Get Commit Log

```bash
# Full commit log with author, date, and body
git log <from>..<to> --pretty=format:'---COMMIT---
HASH: %H
SHORT: %h
AUTHOR: %an
EMAIL: %ae
DATE: %ai
SUBJECT: %s
BODY:
%b
---END---' --no-merges
```

### 3.2 Get Contributors

```bash
# Unique contributors
git log <from>..<to> --pretty=format:'%an <%ae>' | sort -u
```

### 3.3 Get Co-Authors

```bash
# Extract co-authors from commit bodies
git log <from>..<to> --pretty=format:'%b' | grep -i 'co-authored-by:'
```

### 3.4 Get Statistics

```bash
# Files changed, insertions, deletions
git diff --stat <from>..<to>

# Short stats
git diff --shortstat <from>..<to>
```

### 3.5 Get Compare URL (if remote exists)

```bash
# Get remote URL
git remote get-url origin

# Parse for GitHub/GitLab compare URL construction
```

---

## Step 4: Parse Commits

For each commit, extract:

### 4.1 Conventional Commit Parsing

```
<type>(<scope>): <description>

[body]

[footer]
```

**Types to detect:**
- `feat` / `feature` - New features
- `fix` / `bugfix` - Bug fixes
- `perf` - Performance improvements
- `docs` - Documentation
- `style` - Code style
- `refactor` - Refactoring
- `test` - Testing
- `chore` - Maintenance
- `build` - Build system
- `ci` - CI/CD
- `revert` - Reverts

### 4.2 Breaking Change Detection

Look for:
- `BREAKING CHANGE:` in body or footer
- `!` after type (e.g., `feat!:`)
- `BREAKING:` prefix

### 4.3 Issue/PR Reference Extraction

Look for:
- `#123` - Issue/PR number
- `Fixes #123`
- `Closes #123`
- `Resolves #123`
- `Related to #123`

### 4.4 Scope Extraction

Extract scope from `type(scope):` format for grouping.

---

## Step 5: Determine Mode

If no mode specified in arguments, ask user:

```
=== Release Notes Generator ===

What format would you like to generate?

1. Technical - GitHub release notes (developers)
2. Marketing - App store release notes (end users)
3. Internal - Team/stakeholder communication
4. Security - CVE/vulnerability documentation
5. Full - Generate all formats

Enter number or mode name:
```

Use `AskUserQuestion` to get selection.

---

## Step 6: Run Appropriate Agents

Based on selected mode, spawn Task agents.

### Technical Mode (REL01)

Read: `.claude/release/agents/technical-notes.md`

Provide to agent:
- Parsed commit list
- Version number
- Release date
- Contributors list
- Statistics
- Compare URL

### Marketing Mode (REL02)

Read: `.claude/release/agents/marketing-notes.md`

Provide to agent:
- Feature commits (user-facing)
- Bug fix commits
- Performance commits
- Version number

### Internal Mode (REL03)

Read: `.claude/release/agents/internal-notes.md`

Provide to agent:
- All parsed commits
- Statistics
- Breaking changes
- Version number
- Release date

### Security Mode (REL04)

Read: `.claude/release/agents/security-notes.md`

Provide to agent:
- Security-related commits
- Version number
- Previous version
- Release date

### Full Mode

Run all agents sequentially:
1. REL01 - Technical Notes
2. REL02 - Marketing Notes
3. REL03 - Internal Notes
4. REL04 - Security Notes (if security commits exist)
5. REL05 - Changelog Update

---

## Step 7: Generate Output

### 7.1 Create Output Directory

```bash
mkdir -p release-notes
```

### 7.2 File Naming

Format: `YYYY-MM-DD-<version>-<type>.md`

Examples:
- `release-notes/2025-01-15-v1.1.0-technical.md`
- `release-notes/2025-01-15-v1.1.0-marketing.md`
- `release-notes/2025-01-15-v1.1.0-internal.md`
- `release-notes/2025-01-15-v1.1.0-security.md`

### 7.3 Changelog Update

For changelog mode or full mode, update `CHANGELOG.md` in project root.

Read: `.claude/release/agents/changelog.md`

---

## Step 8: Post-Generation Actions

### 8.1 Summary

```
=== Release Notes Generated ===

Files created:
- release-notes/2025-01-15-v1.1.0-technical.md
- release-notes/2025-01-15-v1.1.0-marketing.md
- (etc.)

Summary:
- Total commits: X
- Features: X
- Bug fixes: X
- Breaking changes: X
- Contributors: X

Would you like to:
1. Review the generated notes
2. Update CHANGELOG.md
3. Copy to clipboard
4. Done
```

### 8.2 Optional: Update CHANGELOG.md

If user wants to update CHANGELOG.md:

```
Would you like to update CHANGELOG.md with this release?
This will add a new version section with all changes.
```

Run REL05 changelog agent if confirmed.

---

## Commit Categories Reference

### Conventional Commits

| Type | Category | Marketing Name |
|------|----------|----------------|
| `feat` | Added | New Features |
| `fix` | Fixed | Bug Fixes |
| `perf` | Changed | Performance |
| `docs` | Changed | Documentation |
| `style` | Changed | - (skip) |
| `refactor` | Changed | - (skip) |
| `test` | Changed | - (skip) |
| `chore` | Changed | - (skip) |
| `build` | Changed | - (skip) |
| `ci` | Changed | - (skip) |
| `BREAKING` | Removed | Important Updates |
| `deprecate` | Deprecated | Deprecated |
| `security` | Security | Security Updates |

### Non-Conventional Commits

For commits without conventional prefixes, analyze:
- Subject line keywords (add, fix, update, remove, etc.)
- File changes (new files = feature, test files = tests)
- Commit message content

---

## Error Handling

### No Commits in Range

```
No commits found between <from> and <to>.
Please verify your commit range.
```

### Invalid References

```
Could not find reference '<ref>'.
Available tags: <list recent tags>
```

### No Tags Available

```
No tags found in repository.
Please specify --from with a commit SHA or branch name.
```

---

## Templates

All output uses templates from `.claude/release/templates/`:

- `technical-release.template.md` - GitHub release format
- `marketing-release.template.md` - App store format
- `internal-release.template.md` - Team communication
- `CHANGELOG.template.md` - Keep a Changelog format

---

## Customization Points

1. **Commit patterns** - Modify type detection in Step 4
2. **Character limits** - Adjust in marketing agent
3. **Output path** - Change `release-notes/` location
4. **Template format** - Edit template files
5. **Categories** - Modify category mappings
