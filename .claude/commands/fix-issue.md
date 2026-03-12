---
description: Investigate and fix an issue from docs/issues with a proper plan
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, EnterPlanMode, ExitPlanMode
---

## Fix Issue Command

Investigate, plan, and fix a documented issue following KISS, DRY, and Clean Code principles.

### Step 0: Validate Issue File

**If an issue file path is provided in `$ARGUMENTS`:**

- Read the file and validate it's a proper issue (has Summary, Root Cause, Definition of Done)
- If valid, proceed to Step 1

**If a GitHub Issue number is provided:**

- Look for matching issue in `docs/issues/`
- If not found, suggest running `/add-issue` first

**If NO issue specified:**

- Read `docs/issues/README.md` to see all issues with priorities
- Ask: "Which issue would you like to fix?"
- Wait for user response

---

### Step 1: Understand the Issue

1. **Read the issue file** completely
2. **Extract key information:**
   - Summary
   - Root Cause Analysis
   - **Definition of Done** (this defines success)
   - Files to Modify

3. **If Definition of Done is unclear:** Ask the user to clarify before proceeding.

---

### Step 2: Enter Plan Mode

Use `EnterPlanMode` tool. Do NOT start coding until plan is approved.

---

### Step 3: Investigate

#### 3.1 Read Project Context

- `CLAUDE.md` — Project conventions and constraints
- Relevant source files in `AISight/AISight/`

#### 3.2 Explore Affected Code

Use Glob, Grep, Read to:

1. Find files mentioned in issue
2. Understand current implementation
3. Identify **actual** root cause (not assumed)

**Key questions:**

- Where exactly is the bug?
- What triggers it?
- Why does it happen? (Get evidence, don't guess)

---

### Step 4: Create the Fix Plan (KISS)

**CRITICAL: Apply KISS principle — only fix what's proven broken.**

#### 4.1 Root Cause (Evidence-Based)

- Explain why the bug occurs with **evidence** (code traces, logs)
- Reference specific file:line numbers
- If root cause is unclear, add logging first to diagnose

#### 4.2 Solution Design

**KISS Checklist — Before adding any fix, ask:**

- [ ] Is this fix proven necessary, or speculative?
- [ ] Is this the simplest solution that works?
- [ ] Am I changing only what's broken?
- [ ] Would a senior dev approve this scope?

**DO:**

- Fix the actual problem with minimal changes
- Follow existing patterns in the codebase
- Ensure it works on both iOS and macOS

**DON'T:**

- Add retry logic "just in case"
- Add validation "to be safe"
- Refactor nearby code while you're there
- Add features disguised as bug fixes

#### 4.3 Files to Modify

List each file with:

- File path
- What changes needed
- Why this fixes the issue

#### 4.4 Testing Strategy

- Build for iOS simulator: Cmd+B
- Build for macOS: switch to My Mac, Cmd+B
- Manual testing of the specific fix

#### 4.5 Definition of Done Checklist

Map each item from issue's Definition of Done to verification step.

---

### Step 5: Request Plan Approval

Use `ExitPlanMode`. Wait for user approval before coding.

---

### Step 6: Implement (Minimal Changes)

1. **Make code changes** following the plan exactly
2. **Verify builds** on both iOS and macOS
3. **Test** the specific fix manually

---

### Step 7: Verify Definition of Done

Go through EACH item:

- [ ] Execute verification
- [ ] Confirm pass
- [ ] Document result

**All items must pass.**

---

### Step 8: Update Issue Status

1. Change Status to "Fixed" in issue file
2. Update `docs/issues/README.md` statistics

---

## KISS Principles Reminder

### What KISS Means for Bug Fixes

| Instead of...                                  | Do this...                                                  |
| ---------------------------------------------- | ----------------------------------------------------------- |
| Adding retry logic "in case of network issues" | Fix the actual error first, add retry only if proven needed |
| Adding validation "to be safe"                 | Only validate if missing validation caused the bug          |
| Refactoring while fixing                       | Make separate PR for refactoring                            |
| Adding logging everywhere                      | Add logging only where needed to diagnose                   |
| Fixing multiple issues at once                 | One issue per fix                                           |

### Red Flags — Stop and Reconsider

- "While I'm here, I should also..."
- "This might fail if..."
- "Let me add some defensive code..."
- "I'll refactor this to be cleaner..."
- Plan has more than 3-5 files to modify for a bug fix

### Good Signs

- Fix is < 50 lines of changes
- Changes are in 1-3 files
- Solution matches existing patterns
- You can explain fix in one sentence

---

## Code Quality (Non-Negotiable)

- No `try!` or force unwraps in production code
- `@MainActor` on all `@Observable` classes
- `@available(iOS 26.0, macOS 26.0, *)` on FoundationModels code
- Use `#if os(iOS)` for platform-specific modifiers
- Test on both iOS and macOS builds

---

## Quick Commands

| Step         | Command                                           |
| ------------ | ------------------------------------------------- |
| List issues  | `Read({ file_path: "docs/issues/README.md" })`    |
| Read issue   | `Read({ file_path: "docs/issues/ISSUE-XXX.md" })` |
| Find code    | `Grep({ pattern: "functionName" })`               |
| Build iOS    | Cmd+B (iPhone simulator)                          |
| Build macOS  | Cmd+B (My Mac)                                    |
