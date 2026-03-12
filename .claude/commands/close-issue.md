---
description: Close an issue after fix is complete, update trackers and archive
allowed-tools: Read, Edit, Bash(git:*), Bash(gh issue:*), Bash(mv:*), Grep, Skill
---

## Close Issue Command

After fixing an issue, update GitHub Issues and local docs to mark it as closed.

---

### Step 1: Identify Issue File

**If `$ARGUMENTS` contains an issue file path:**

- Read the issue file directly

**If `$ARGUMENTS` contains an issue ID (e.g., ISSUE-003):**

- Look for `docs/issues/ISSUE-003*.md`

**If NO argument provided:**

- List recent issues from `docs/issues/README.md`
- Ask: "Which issue would you like to close?"

---

### Step 2: Extract External References

Read the issue file and extract:

1. **GitHub Issue numbers** — Look for patterns like `#XXX` or GitHub URLs

---

### Step 3: Update GitHub Issue (if applicable)

For each GitHub Issue found:

```bash
gh issue close <number> --comment "Fixed. See docs/issues/ISSUE-XXX-description.md"
```

---

### Step 4: Update Local Issue File

Edit the issue file:

1. Change status from "Open" to "Fixed"
2. Add closing information:

```markdown
## Resolution

- **Closed:** YYYY-MM-DD
- **GitHub Issue:** #XXX → Closed
```

---

### Step 5: Move Issue to CLOSED.md and Archive

1. **Find the issue row in README.md** — Look for the line containing the issue ID
2. **Remove from README.md** — Delete the table row for this issue
3. **Move the issue file to archive:**
   ```bash
   mv docs/issues/ISSUE-XXX-description.md docs/issues/archive/
   ```
4. **Add to CLOSED.md** — Add the row to the table in CLOSED.md with `./archive/` link prefix:
   ```markdown
   | Fixed | [ISSUE-XXX](./archive/ISSUE-XXX-description.md) | Medium | Title | Source |
   ```
5. **Update statistics** in both files:
   - README.md: Decrement "Total Open" and the appropriate priority count
   - CLOSED.md: Increment "Total Closed"

---

### Step 6: Commit Changes

After updating the local issue file and moving it to CLOSED.md, commit all changes:

```
Skill({ skill: "commit" })
```

---

### Step 7: Report Summary

Display:

```
## Issue Closed: ISSUE-XXX

### Trackers Updated:

| Tracker | ID | Status |
|---------|------|--------|
| GitHub | #XXX | Closed |
| Local | ISSUE-XXX | Archived |
```

---

## Examples

**Close a specific issue:**

```
/close-issue docs/issues/ISSUE-003-citation-rendering.md
```

**Close by issue ID:**

```
/close-issue ISSUE-003
```
