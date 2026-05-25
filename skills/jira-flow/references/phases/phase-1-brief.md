---
partOf: jira-flow
version: 1.0.0
description: Phase 1 complete instructions for requirements analysis. Leader reads this file when entering Phase 1.
---

# Phase 1: Requirements Analysis

## Step 1: Requirements Analysis + Proposal

Leader executes directly, or delegates to `requirements-analyst` only when the user explicitly enabled Codex team/sub-agent mode.

Leader / requirements-analyst task:
"Read Jira issue {issue_key} via Codex Atlassian Rovo tools (including description, comments when available, and linked context),
  analyze the requirements, and generate an OpenSpec proposal.md.

  [superpowers:brainstorming]
  First read the superpowers brainstorming SKILL.md for the full methodology.
  Key constraints:
  - Propose 2-3 implementation options, each including: architectural impact, implementation complexity, and risk factors
  - Provide a recommended option with rationale
  - Spec self-review (check after writing): no placeholders, internally consistent, scope is covered, no ambiguity

  Baseline correlation (if {baseline_path} exists and is non-empty):
  - Scan all spec.md files under {baseline_path} to identify baseline documents related to the current requirement
  - Annotate a 'Baseline Constraints' section in the proposal, citing key constraints from relevant baselines
  - Ensure the recommended option does not conflict with baselines; if a baseline must be violated, explicitly state the reason and impact

  Reference the format of existing specs under {changes_path}.
  Output to: {changes_path}/{spec_name}/proposal.md
  spec_name naming rule: <module-abbreviation>-<brief-description>, following the naming style of existing directories.
  On completion, report: spec_name, proposal summary, recommended option and rationale"

Wait for completion → record spec_name

## Step 2: Architecture Design + Design Doc

Leader executes directly, or delegates to `architect` only when Codex team/sub-agent mode is enabled.

Leader / architect task:
"Read {changes_path}/{spec_name}/proposal.md, generate design.md, and explore the related code architecture.
  Database: Reference {root_path}/.codex/jira-flow/project-config.md → databases (query table structures to assist design). If only a migrated legacy config exists, use it as read-only compatibility input.

  [superpowers:brainstorming — Design Principles]
  First read the superpowers brainstorming SKILL.md for the full methodology.
  Key constraints:
  - Module decomposition: each unit has a single responsibility, clear interfaces, and can be independently understood/tested
  - Follow existing code patterns; do not introduce unrelated refactoring
  - Design self-review: confirm no placeholders, type consistency, and complete file dependencies

  Output to: {changes_path}/{spec_name}/design.md
  On completion, report: design summary, whether backend/frontend changes are involved, and a list of key files"

Wait for completion

## Gate 1

Present the summaries → after confirmation, decide whether backend/frontend role references are needed. Spawn development sub-agents only if the user explicitly enabled team/sub-agent mode; otherwise continue in the main Codex session using the relevant role guidance.
