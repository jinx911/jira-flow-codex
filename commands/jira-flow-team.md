---
description: "Run Jira-Flow Codex for a Jira issue in sub-agent team mode"
argument-hint: "<Jira issue key or URL>"
---

Use the `jira-flow` skill with these arguments:

```text
$ARGUMENTS
```

If no issue key or Jira URL is provided, ask the user for one concise clarification.

Treat this command as equivalent to:

```text
使用 jira-flow 处理 $ARGUMENTS，并启用 Codex sub-agents team 模式
```

Run in Codex sub-agent team mode:

- Keep the main Codex session as Leader.
- Use `team-orchestration` guidance.
- Spawn Codex sub-agents only for useful, bounded work.
- Prefer `explorer` agents for requirements, architecture, planning, and code exploration.
- Prefer `worker` agents for backend/frontend implementation, review, and verification.
- Inject role prompts from `skills/jira-flow/references/roles/*.md` plus `skills/jira-flow/references/team-rules.md`.
- The Leader owns Gate decisions, state file updates, conflict coordination, and final Jira updates.

Follow the Codex-native workflow in `skills/jira-flow/SKILL.md`.
