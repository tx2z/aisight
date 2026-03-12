---
description: Create logical git commits grouped by feature/change
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---

## Create Git Commits

Create well-formatted git commits, **grouping changes logically**:

1. **Check status**: Run `git status` and `git diff` to see all changes
2. **Analyze changes**: Group files by logical feature/purpose
3. **Check style**: Run `git log --oneline -5` to match commit message style
4. **Create separate commits**: For each logical group:
   - Stage only related files with `git add <files>`
   - Commit with a focused message
   - Repeat for next group

**Example:** If session included adding commands AND fixing a bug:

- Commit 1: `feat: add Claude Code slash commands` (only command files)
- Commit 2: `fix: resolve citation rendering on macOS` (only UI files)

**Commit message format:**

```
<type>: <description>

[optional body explaining why]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

**Types:**

- `feat:` new features
- `fix:` bug fixes
- `chore:` maintenance tasks
- `refactor:` code refactoring
- `docs:` documentation
- `test:` test changes
- `style:` formatting changes
- `perf:` performance improvements

**Important:**

- Verify the project builds before committing (Cmd+B in Xcode)
- Never commit secrets or credentials
- Keep commits atomic: one logical change per commit
- Use HEREDOC for multi-line commit messages
- **NEVER use `--no-verify` without explicit user permission**
