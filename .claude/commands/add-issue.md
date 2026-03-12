---
description: Add a new issue to docs/issues and optionally create a GitHub Issue
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh issue:*)
---

## Add Issue to Tracker

Create a new issue in `docs/issues/` following the project's issue template.

### Step 1: Determine Next Issue ID

1. Read `docs/issues/README.md` to find existing issues
2. Determine the next ID number (e.g., if ISSUE-010 exists, next is ISSUE-011)

**Issue ID Format:** `ISSUE-XXX-short-description.md`

### Step 2: Gather Issue Information

**Option A: From GitHub Issue**

If user provides a GitHub issue number or URL:

1. Use `gh issue view <number>` to fetch issue details
2. Extract: title, body, labels, assignees

```bash
gh issue view <number> --json title,body,labels,state,assignees
```

**Option B: From Conversation**

If no external ID provided:

- Analyze the current session for recent errors or issues discussed
- Ask clarifying questions if critical information is missing

### Step 3: Handle Screenshots

**If user provided an image:**

1. Save the image to `docs/issues/screenshots/`
2. Use naming convention: `ISSUE-XXX-description.png`
3. Reference in the Screenshots/Evidence section

### Step 4: Create the Issue File

Create new file: `docs/issues/ISSUE-XXX-short-description.md`

```markdown
# ISSUE-XXX: Title

## Status: Open
## Priority: [Critical/High/Medium/Low]
## Created: YYYY-MM-DD

## Summary

Brief description of the issue.

## Steps to Reproduce

1. ...
2. ...

## Expected Behavior

What should happen.

## Actual Behavior

What actually happens.

## Root Cause Analysis

Investigation findings. Reference specific file:line numbers.

## Files to Modify

- `path/to/file.swift` — what needs to change

## Definition of Done

- [ ] Specific criteria 1
- [ ] Specific criteria 2
- [ ] Builds without errors on iOS and macOS

## External References

- GitHub Issue: #XXX (if applicable)
```

### Step 5: Investigate Root Cause

Use codebase exploration to find the root cause:

```
Grep({ pattern: "error message or function name" })
Glob({ pattern: "**/*Service*.swift" })
Read({ file_path: "/path/to/affected/file.swift" })
```

### Step 6: Update the README

Edit `docs/issues/README.md`:

1. Add new row to the Open Issues table
2. Update Issue Statistics counts

### Step 7: Optionally Create GitHub Issue

Ask user if they want a GitHub Issue created:

```bash
gh issue create --title "ISSUE-XXX: Title" --body "See docs/issues/ISSUE-XXX-description.md" --label "bug"
```

### Step 8: Report Back

Show:

- Created file path
- Issue ID and title
- Priority level
- Brief summary
- GitHub Issue link if created

---

## Priority Guidelines

| Priority | When to Use                                                        |
| -------- | ------------------------------------------------------------------ |
| Critical | App crashes, data loss, security vulnerabilities                   |
| High     | Core feature broken, blocks user workflow                          |
| Medium   | Feature partially broken, has workaround                           |
| Low      | Minor annoyance, cosmetic issues, edge cases                       |

---

## Examples

**User:** `/add-issue #5`
→ Fetch from GitHub Issues, investigate codebase, create issue doc

**User:** `/add-issue The streaming answer doesn't show citations on Mac`
→ Investigate codebase, create issue doc, ask for repro steps if unclear

**User:** `/add-issue` + [attached screenshot]
→ Save screenshot, analyze error, create appropriate issue doc
