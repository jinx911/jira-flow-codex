---
name: git-ops
description: Codex-safe git operation guidance for Jira-Flow Codex.
version: 0.1.0
tags: [git, codex, jira-flow]
---

# Git Ops

## Rules

- Never run destructive git commands unless the user explicitly approves.
- Never revert unrelated user changes.
- Prefer non-interactive git commands.
- Before branch or commit operations, inspect `git status --short`.
- Commit only files that belong to the current Jira-Flow task.

## Common Operations

Create a branch:

```bash
git switch -c <issue-key>
```

Inspect changes:

```bash
git status --short
git diff --stat
git diff
```

Commit:

```bash
git add <paths>
git commit -m "<type>(<scope>): <intent>"
```

Push:

```bash
git push -u origin <branch>
```
