---
partOf: jira-flow
version: 1.0.0
description: Phase 2 complete instructions for task planning and branching. Leader reads this file when entering Phase 2.
---

# Phase 2: Task Planning + Branching

## Step 2a: Task Breakdown

Leader executes directly, or delegates to `planner` only when Codex team/sub-agent mode is enabled.

Leader / planner task:
"Break down tasks, write tasks.md, and create tracking entries via Codex `update_plan` or the state file (annotating blockedBy when useful).

    [superpowers:writing-plans]
    First read the superpowers writing-plans SKILL.md for the full methodology.
    Key constraints:
    - Appropriate granularity: each step takes 2-5 minutes (test → verify → implement → verify → commit)
    - TDD steps: RED → Verify RED → GREEN → Verify GREEN → REFACTOR → Commit
    - Zero placeholders: no TBD/TODO allowed — every step must include complete code and commands
    - Exact paths: annotate file paths for each step
    - Self-check: spec coverage is complete, no placeholders, type consistency
    Output to: {changes_path}/{spec_name}/tasks.md + Codex plan/state entries"

Wait → Gate 2a: present task list → confirm

## Step 2b: Create Branch

Use the Codex `git-ops` skill guidance to create branch `{config.branch_naming.format}`.

Default command:

```bash
git switch -c {branch}
```

Respect Codex sandbox approval rules and inspect `git status --short` before changing branches.

Wait → Gate 2b: present branch info → confirm
