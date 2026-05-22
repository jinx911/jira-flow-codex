---
partOf: jira-flow
version: 1.0.0
description: Breakpoint recovery logic. When jira-flow detects a state.json file, follow this procedure to resume the interrupted workflow.
---

# Breakpoint Recovery

> When the Codex `jira-flow` skill detects an existing `{issue_key}.json` state file, follow this recovery procedure.

## State File

Location: `{root_path}/.codex/jira-flow/state/{issue_key}.json`

```json
{
  "issue_key": "{issue_key}",
  "mode": "semi-auto",
  "branch": "<branch-name>",
  "current_phase": 3,
  "spawned_roles": ["requirements-analyst", "architect", "planner", "backend-developer"],
  "openspec_name": "{spec_name}",
  "completed_tasks": ["task-id-1"],
  "pending_tasks": ["task-id-2"],
  "gate_summaries": {
    "1": "proposal: xxx, design: xxx",
    "2": "tasks: 12 total, branch: PROJ-123"
  },
  "phase_decisions": {
    "1": {
      "scope": "Backend API for user auth",
      "key_files": ["src/auth/controller.ts", "tests/auth/controller.test.ts"],
      "architecture_choice": "JWT with refresh token rotation",
      "risks": ["New table requires migration review"]
    }
  },
  "agent_context_snapshots": {
    "backend-developer": {
      "last_progress": "Step 5/8: implementing auth service",
      "last_files_changed": ["src/auth/service.ts", "tests/auth/service.test.ts"],
      "last_update": "2026-05-22T10:30:00Z"
    }
  },
  "updated_at": "<ISO>"
}
```

### State Fields

| Field | Purpose | Updated When |
|-------|---------|-------------|
| `gate_summaries` | User-facing checkpoint summaries by phase | After each Gate passes |
| `phase_decisions` | Compact decisions needed to resume without rereading the whole conversation | After each Gate passes |
| `agent_context_snapshots` | Latest known worker progress and changed files | On progress updates, completion reports, and Phase 3 task completion |
| `completed_tasks` / `pending_tasks` | Phase 3 resume source of truth in single-session Codex mode | When task status changes |

## Recovery Procedure

```
1. Read `{root_path}/.codex/jira-flow/state/{issue_key}.json`
2. Ask the user: "Found incomplete workflow for {issue_key} (Phase {n}/6). Resume?"
   → No: Delete state, start from scratch
   → Yes:
3. Re-spawn roles listed in `state.spawned_roles` only if the user explicitly requested Codex team/sub-agent mode; otherwise continue in the main Codex session
4. Inject compact context before resuming:
   - `phase_decisions[current_phase]` gives prior phase decisions
   - `agent_context_snapshots[role]` gives the previous worker's latest known point
   - Instruction for replacement workers: "Previous context ended. Continue from the latest snapshot. Do not restart completed work."
5. Determine breakpoint → jump to the corresponding Phase:
   current_phase == 1: proposal.md exists → Phase 2, otherwise → Phase 1
   current_phase == 2: tasks.md exists → Phase 3, otherwise → Phase 2
   current_phase == 3: pending_tasks is non-empty → continue Phase 3, otherwise → Phase 4
   current_phase == 4-6: Start from that Phase
6. Main session or spawned roles read context from disk files (proposal/design/tasks) plus state `phase_decisions`
```

## Persistence Timing

After each Gate confirmation, the Leader updates the state file with `gate_summaries`, `phase_decisions`, `current_phase`, and `updated_at`.
During Phase 3, update `agent_context_snapshots` on progress/completion and update task lists as tasks complete.
After Phase 6 completes, the state file is deleted.

## Exception Recovery Scenarios

### Sub-Agent Spawn Failure

```
Spawning a specific role fails → Leader records the failed role name in state.failed_roles
→ Retry spawn (up to 2 times)
→ Still failing → ask the user whether to continue without that role, continue single-session, or abort the workflow
```

### Leader Session Crash

```
On recovery, the Leader reads the state:
  - current_phase < 3 → prior deliverables (proposal/design/tasks) are on disk, can resume directly
  - current_phase == 3 → check completed_tasks and pending_tasks in state
    → re-spawn dev role only if team/sub-agent mode is enabled; otherwise continue in the main session
  - current_phase >= 4 → check git log to confirm code state, resume from the corresponding Phase
  - gate_summaries records each Gate's summary for user reference during recovery
```

### MCP Connection Lost

```
Atlassian Rovo tools unavailable (Phase 1 reads Jira / Phase 6 updates Jira):
  → Leader asks: "Atlassian Rovo connection failed. Retry?"
  → Retry up to 2 times
  → Still failing → save state, prompt user to restore the connector/tooling then re-run jira-flow

Database tool unavailable (Phase 5 database verification):
  → Tester skips the database verification step, notes in test report "DB verification skipped (MCP unavailable)"
  → Does not block the workflow
```

### Worker Context Exhausted

```
Sub-agent or long-running worker appears context-exhausted:
  → Ping once after the phase-specific silence threshold
  → If no response and the last progress snapshot is older than 15 minutes:
      - Read `agent_context_snapshots[role]`
      - Continue in the main session, or spawn one replacement role if team/sub-agent mode is enabled
      - Inject original task, `phase_decisions[current_phase]`, and the latest snapshot
      - Update state to replace/reset the exhausted role snapshot
  → If the replacement also exhausts context, ask the user before continuing
```

### External Config Modified Mid-Workflow

```
{root_path}/.codex/jira-flow/project-config.md was modified:
  → Leader detects it by comparing against cached config summary
  → Ask the user: "Project config has changed. Continue with the new config?"
  → Yes: reload config, notify running agents
  → No: continue with the previous config
```
