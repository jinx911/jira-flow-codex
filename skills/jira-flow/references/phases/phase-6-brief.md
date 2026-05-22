---
partOf: jira-flow
version: 1.0.0
description: Phase 6 complete instructions for wrap-up. Leader reads this file when entering Phase 6.
---

# Phase 6: Wrap-Up

## 1. Development Branch Finalization

Leader executes directly, or delegates to **backend-developer** only when Codex team/sub-agent mode is enabled:
"Finalize the development branch:
   [superpowers:finishing-a-development-branch]
   - Confirm all tests pass (run the full test suite, not incremental)
   - Confirm no leftover debug code (console.log/dd/dump/var_dump, etc.)
   - Commit and push the branch using Codex `git-ops` guidance — push the branch only; MR is created manually by the user unless explicitly requested"

## 2. Deploy Branch Merge (Optional)

If deploy_branch is configured in project-config:
Leader / backend-developer task: "Merge the development branch into {deploy_branch} and push"
- checkout {deploy_branch} → pull → merge {development branch} → push → checkout {development branch}
- Purpose: trigger automatic deployment to the test environment

If deploy_branch is not configured → skip this step

## 3. Confirm Final State

- All repository branches have been pushed
- deploy_branch has been merged (if configured)
- Update `{root_path}/.codex/jira-flow/state/{issue_key}.json`

## 4. Jira Wrap-Up

Leader executes directly, or delegates to requirements-analyst only when Codex team/sub-agent mode is enabled:
"Perform Jira wrap-up operations:
   Reference {root_path}/.codex/jira-flow/project-config.md → jira_workflow if configured.
   If jira_workflow is not configured, use these defaults:
   - testing_status: auto-detect a transition/status containing 'Test' or '测试'
   - auto_creates_sub: true
   - sub_completion_status: auto-detect a transition/status containing 'Done' or '完成'
   - testing_note_template: built-in 5-field template: Change overview, Affected modules, Testing highlights, Prerequisites, Verification steps

   a. `mcp__codex_apps__atlassian_rovo._gettransitionsforjiraissue` → find the transition ID for the main issue testing status.
      Configured: use jira_workflow.testing_status.
      Default: choose the available transition/status containing 'Test' or '测试'. If there are multiple plausible matches, ask the user to choose.

   b. Transition the MAIN Jira issue to the testing status with `mcp__codex_apps__atlassian_rovo._transitionjiraissue`.
      Important: this transition may trigger automatic creation of testing sub-issues. Wait briefly for auto-creation to complete before searching.

   c. If jira_workflow.auto_creates_sub is omitted or true:
      use `mcp__codex_apps__atlassian_rovo._searchjiraissuesusingjql` with:
      `parent = {issue_key} ORDER BY created DESC`
      Record each sub-issue key/link for the Gate 6 summary.

   d. Fill testing notes on EACH SUB-ISSUE, not the main issue, using `mcp__codex_apps__atlassian_rovo._editjiraissue` when the testing note field is known, otherwise `mcp__codex_apps__atlassian_rovo._addcommenttojiraissue`.
      Content source: proposal summary + change scope + test results.
      Configured: use jira_workflow.testing_note_template.
      Default:
        - Change overview: <summary of changes>
        - Affected modules: <modules involved>
        - Testing highlights: <key test results>
        - Prerequisites: <what needs to be set up before testing>
        - Verification steps: <how to verify the changes>

   e. Transition EACH SUB-ISSUE to completion status.
      Configured: use jira_workflow.sub_completion_status.
      Default: choose the available transition/status containing 'Done' or '完成'. If there are multiple plausible matches, ask the user to choose."

## 5. Cleanup

Close any spawned Codex sub-agents. In single-session mode, no cleanup is needed.

## Gate 6

Final summary (branch name + sub-issue links + reminder that MR must be created manually)
