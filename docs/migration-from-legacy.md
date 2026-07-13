# Migration From Legacy Jira-Flow To Dev-Flow Codex

This repository now follows the `dev-flow` architecture instead of the old monolithic `jira-flow` layout.

## Naming Changes

| Legacy name | New name |
| --- | --- |
| `jira-flow` | `dev-flow` |
| `init-jira-flow` | `init-dev-flow` |
| `skills/jira-flow/` | `skills/dev-flow/` |
| `skills/init-jira-flow/` | `skills/init-dev-flow/` |
| `commands/jira-flow.md` | `commands/dev-flow.md` |
| `commands/init-jira-flow.md` | `commands/init-dev-flow.md` |
| `install-codex.sh` | `install.sh` |

## Structure Changes

| Legacy structure | New structure |
| --- | --- |
| Single `jira-flow` skill with 6 phase briefs | Thin `dev-flow` orchestrator + 4 stage skills |
| `skills/jira-flow/references/phases/*.md` | `skills/spec-author/`, `skills/dev-loop/`, `skills/review-test/`, `skills/ship/` |
| `skills/jira-flow/references/roles/*.md` | `agents/*.md` |
| `.codex/jira-flow/state/` | `.dev-flow/*-state.json` and `.dev-flow/{issue_key}/spec/` |

## Runtime Notes

- This repo remains Codex-native for installation and runtime assumptions.
- Skills install into `~/.codex/skills/`.
- Command shims install into `~/.codex/commands/` and `~/.codex/workflows/`.
- The workflow no longer treats old `/jira-flow` and `/init-jira-flow` as active entrypoints.

## Config Notes

When migrating an initialized project, prefer generating new configuration through `/init-dev-flow`.

If you still need to read older settings:

- legacy Codex config: `<project-root>/.codex/jira-flow/project-config.md`
- newer dev-flow project config target: `<project-root>/.codex/project-config.md`

Do not copy secrets blindly between formats. Keep secret references or environment variable names only.
