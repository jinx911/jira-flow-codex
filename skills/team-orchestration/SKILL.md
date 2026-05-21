---
name: team-orchestration
description: Codex-native guidance for optional Jira-Flow role orchestration with sub-agents.
version: 0.1.0
tags: [agents, codex, jira-flow]
---

# Team Orchestration

## Rule

Use Codex sub-agents only when the user explicitly asks for sub-agents, delegation, a team, or parallel agent work.

## Roles

Role prompts live in:

```text
skills/jira-flow/references/roles/<role-name>.md
```

Core roles:

- `requirements-analyst.md`
- `architect.md`
- `planner.md`
- `backend-developer.md`
- `frontend-developer.md`
- `code-reviewer.md`
- `tester.md`

## Mapping

- Read-only exploration: prefer Codex `explorer` agents and inject `skills/jira-flow/references/roles/code-explorer.md` when role guidance is useful.
- Code changes or verification work: prefer `worker`.
- Assign disjoint write scopes to workers.
- Tell every worker they are not alone in the codebase and must not revert others' edits.

## Cleanup

When a role is no longer needed, close the associated sub-agent.
