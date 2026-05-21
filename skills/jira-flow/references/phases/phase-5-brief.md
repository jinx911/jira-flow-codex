---
partOf: jira-flow
version: 1.0.0
description: Phase 5 complete instructions for test verification. Leader reads this file when entering Phase 5.
---

# Phase 5: Test Verification

Use `tester` role guidance. Spawn a tester sub-agent only when the user explicitly enabled Codex team/sub-agent mode; otherwise perform verification in the main Codex session.

Prerequisite: If frontend changes are involved → run the frontend build first (command reference: {root_path}/.codex/jira-flow/project-config.md → build_commands.frontend)

Leader / tester task:
"Read proposal.md + tasks.md, and execute test verification.

  [superpowers:verification-before-completion]
  First read the superpowers verification SKILL.md for the full methodology.
  Key constraints:
  - Evidence rule: every completion claim must be backed by immediate verification evidence
  - Forbidden: 'should work now' / 'looks fine' / 'should pass'
  - For each verification provide: command + output summary + exit code
  - Bug reports: reproduction steps + expected + actual + evidence

  Test environment credentials: Reference {root_path}/.codex/jira-flow/project-config.md → test_environments.
  E2E testing: Reference {root_path}/.codex/jira-flow/project-config.md → e2e_testing (prefer the Codex Browser plugin for known local browser targets).
  Test scope: existing unit tests + selection based on change type (backend-only → API/integration tests, frontend involved → E2E tests).
  Repository paths: {repo_paths}.
  Database verification: Use configured database tools to query the corresponding database and verify data correctness.
  If a bug is found → report to Leader/user: 'Bug: <description>, Steps: <reproduction>, Expected: <expected>, Actual: <actual>'
  If all pass → report: 'All tests passed, report: ...'"

## Test-Fix Loop (all routed through Leader)

tester finds bug → Leader determines ownership → development agent or main session fixes → tester/main session re-verifies
If not passed, run another round. After multiple unresolved rounds (>3) → Leader asks the user

## Gate 5

Present test report → confirm
