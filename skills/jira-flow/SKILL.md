---
name: jira-flow
description: "Use when the user provides a Jira issue key or URL and wants Codex to run the full development lifecycle: requirements, design, planning, TDD implementation, review, verification, finalization, and Jira updates."
version: 0.1.0
tags: [jira, codex, workflow, tdd, code-review, atlassian-rovo]
---

# Jira-Flow Codex

## Purpose

Run a Jira-driven development workflow in Codex-native runtime.

Input examples:

- `/jira-flow PROJ-123`
- `/jira-flow https://example.atlassian.net/browse/PROJ-123`
- `PROJ-123`
- `https://example.atlassian.net/browse/PROJ-123`

## Runtime Model

The default Leader is the current Codex session.

Codex sub-agents may be used only when the user explicitly asks for sub-agents, a team, delegation, or parallel agent work. When sub-agents are allowed, inject role prompts from `references/roles/*.md` plus `references/team-rules.md`.

## Legacy-To-Codex Mapping

| Legacy concept | Codex equivalent |
| --- | --- |
| `/jira-flow <issue>` | `commands/jira-flow.md` shim that invokes this skill |
| `/init-jira-flow [path]` | `commands/init-jira-flow.md` shim that invokes the init skill |
| Workflow command | This skill |
| Team creation command | `team-orchestration` reference workflow plus optional `spawn_agent` |
| Message routing | `send_input` to an existing sub-agent when team mode is explicitly enabled |
| Task tracking APIs | `update_plan` and phase state file |
| Agent prompt files | `references/roles/*.md` |
| Atlassian MCP names | Atlassian Rovo tools available in Codex |

## Required References

Read only what is needed for the current phase:

- `references/gate.md`
- `references/resume.md`
- `references/team-rules.md`
- `references/phases/phase-1-brief.md`
- `references/phases/phase-2-brief.md`
- `references/phases/phase-3-brief.md`
- `references/phases/phase-4-brief.md`
- `references/phases/phase-5-brief.md`
- `references/phases/phase-6-brief.md`

## Variable Substitution

Before entering a phase, substitute these variables in the phase brief:

| Variable | Source |
| --- | --- |
| `{issue_key}` | Parsed Jira issue key, such as `PROJ-123` |
| `{changes_path}` | Project config `openspec.changes_path` |
| `{baseline_path}` | Project config `openspec.baseline_path` |
| `{spec_name}` | Phase 1 proposal directory name |
| `{branch}` | Phase 2 branch name |
| `{repo_path}` | Primary implementation repository path |
| `{backend_repo_path}` | Backend repository path |
| `{frontend_repo_path}` | Frontend repository path |
| `{repo_paths}` | All repositories involved in verification |
| `{root_path}` | Project root path |
| `{deploy_branch}` | Optional deploy branch from project config |

## Superpowers References

Phase briefs use `[superpowers:<skill-name>]` annotations. In Codex, these mean: read and follow the named superpowers skill if it is available in the current environment; otherwise follow the local phase constraints and note the missing skill in the Gate summary.

## Workflow

### Phase 0: Preflight

1. Parse the Jira issue key from user input.
2. Locate Codex project config:
   - Prefer `<project-root>/.codex/jira-flow/project-config.md`.
   - Fall back to legacy project config only when explicitly migrating an older project.
3. Verify Atlassian Rovo availability using the current Codex Atlassian tools.
4. Detect an existing state file at `<project-root>/.codex/jira-flow/state/{issue_key}.json`.
5. Ask the user before enabling sub-agent/team mode unless they already requested it explicitly.
6. Check whether `.codegraph/` exists under `{root_path}`:
   - Exists: use CodeGraph guidance from `references/team-rules.md` for code exploration.
   - Missing: ask whether to initialize CodeGraph if the environment has `codegraph`; otherwise continue with standard `rg` and file reads.
   - Declined or unavailable: continue without CodeGraph and note it in the Gate summary only if it affects exploration confidence.

### Phase 1: Requirements + Design

Use `references/phases/phase-1-brief.md` as the source procedure, translated to Codex tools.

Key Codex adjustments:

- Fetch Jira data with the Codex Atlassian Rovo `mcp__codex_apps__atlassian_rovo._getjiraissue` tool and comments/related context when available.
- Write OpenSpec files under the configured `openspec.changes_path`.
- Use `superpowers:brainstorming` methodology for alternatives and self-review.

### Phase 2: Planning + Branch

Use `references/phases/phase-2-brief.md`.

Key Codex adjustments:

- Use `update_plan` and the state file for task tracking.
- Use shell git commands for branch work, respecting Codex sandbox escalation rules.

### Phase 3: TDD Development

Use `references/phases/phase-3-brief.md`.

Key Codex adjustments:

- Use `superpowers:test-driven-development` before implementation.
- Preserve user changes and never reset or revert unrelated work.
- Use worktrees only when the task requires isolation and the user approves the path.
- Track long-running progress in the state file so interrupted or context-exhausted work can resume without restarting completed steps.

### Phase 4: Code Review

Use `references/phases/phase-4-brief.md`.

Key Codex adjustments:

- Default to Codex code review response format: findings first, severity ordered, exact file and line.
- Apply project-specific review rules when available.

### Phase 5: Verification

Use `references/phases/phase-5-brief.md`.

Key Codex adjustments:

- Use `superpowers:verification-before-completion`.
- Report command, output summary, and exit status for every claim.
- Use Browser plugin only when a local frontend target is known or requested.

### Phase 6: Finalization

Use `references/phases/phase-6-brief.md`.

Key Codex adjustments:

- Use project-specific commit discipline when available.
- Use Codex Atlassian Rovo tools such as `mcp__codex_apps__atlassian_rovo._gettransitionsforjiraissue`, `mcp__codex_apps__atlassian_rovo._transitionjiraissue`, `mcp__codex_apps__atlassian_rovo._editjiraissue`, and `mcp__codex_apps__atlassian_rovo._addcommenttojiraissue`.
- Preserve the Jira wrap-up order: transition the main issue first, discover auto-created sub-issues, fill testing notes on sub-issues, then complete sub-issues.
- Do not create merge requests unless the user explicitly asks.

## Gate Rules

At the end of every phase, read `references/gate.md` and present:

- Deliverables
- Key decisions
- Risks
- Quality: Pass or Fail
- Next phase and role changes

Semi-auto mode is the default. Full-auto mode must be explicitly requested.

## State

Write state under:

```text
<project-root>/.codex/jira-flow/state/{issue_key}.json
```

Do not write state under legacy runtime directories.
