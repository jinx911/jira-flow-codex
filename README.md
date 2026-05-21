# Jira-Flow Codex

[中文](README.zh-CN.md) | **English**

Codex-native port of the original `jira-flow` workflow.

It coordinates a full Jira-driven development lifecycle:

```text
Jira Issue -> requirements -> design -> plan -> TDD implementation -> review -> verification -> finalization
```

The original version remains untouched. This repository carries a separate Codex skill layout and keeps former agents as role reference prompts.

## Repository

This project is currently developed as a local repository. After publishing, set the remote with:

```bash
git remote add origin <repository-url>
```

## Install

```bash
cd jira-flow-codex
./install-codex.sh
```

This links `skills/*` into `~/.codex/skills/`.
It also links command shims into `~/.codex/commands/` and `~/.codex/workflows/`.

## Usage

Preferred:

```text
/init-jira-flow
/jira-flow PROJ-123
```

Fallback if custom slash commands are not loaded in the current Codex environment:

```text
Use init-jira-flow for the current project
Use jira-flow for PROJ-123
```

## Layout

```text
skills/jira-flow/SKILL.md
skills/jira-flow/references/phases/
skills/jira-flow/references/roles/
skills/init-jira-flow/SKILL.md
skills/git-ops/SKILL.md
skills/team-orchestration/SKILL.md
commands/jira-flow.md
commands/init-jira-flow.md
```

## Runtime Model

- Default: Codex main session runs the workflow phase by phase.
- Optional: when the user explicitly asks for sub-agents or parallel agent work, role prompts under `references/roles/` can be injected into Codex sub-agents.
- Jira operations use Codex Atlassian Rovo tools.

## Migration

See [docs/migration-from-legacy.md](docs/migration-from-legacy.md) for legacy-to-Codex migration notes.
