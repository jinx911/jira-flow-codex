# Jira-Flow Codex

Codex-native port of the original `jira-flow` workflow.

It coordinates a full Jira-driven development lifecycle:

```text
Jira Issue -> requirements -> design -> plan -> TDD implementation -> review -> verification -> finalization
```

The original version remains untouched. This repository carries a separate Codex skill layout and keeps former agents as role reference prompts.

## Install

```bash
cd /Users/eliojin/IdeaProjects/jira-flow-codex
./install-codex.sh
```

This links `skills/*` into `~/.codex/skills/`.

## Layout

```text
skills/jira-flow/SKILL.md
skills/jira-flow/references/phases/
skills/jira-flow/references/roles/
skills/init-jira-flow/SKILL.md
skills/git-ops/SKILL.md
skills/team-orchestration/SKILL.md
```

## Runtime Model

- Default: Codex main session runs the workflow phase by phase.
- Optional: when the user explicitly asks for sub-agents or parallel agent work, role prompts under `references/roles/` can be injected into Codex sub-agents.
- Jira operations use Codex Atlassian Rovo tools.
