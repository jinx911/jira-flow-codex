# Migration From Claude-Style Jira-Flow

This project is a Codex-native port. It intentionally does not install or modify legacy Claude directories.

## Directory Mapping

| Legacy location | Codex location |
| --- | --- |
| `~/.claude/skills/<skill>/skill.md` | `~/.codex/skills/<skill>/SKILL.md` |
| `~/.claude/agents/*.md` | `skills/jira-flow/references/roles/*.md` |
| `<project-root>/.claude/project-config.md` | `<project-root>/.codex/jira-flow/project-config.md` |
| `<project-root>/.jira-flow/*-state.json` | `<project-root>/.codex/jira-flow/state/{issue_key}.json` |

## Config Migration

When initializing an existing project, `init-jira-flow` may read a legacy `.claude/project-config.md` as a compatibility source. It should write the Codex config to `.codex/jira-flow/project-config.md`.

Do not copy secrets into the Codex config. Use environment variable names or secret-manager references.

## Runtime Differences

- Codex skills use uppercase `SKILL.md`.
- Role prompts are references. They are injected into optional Codex sub-agents only when the user explicitly requests team/sub-agent mode.
- Jira operations use Codex Atlassian Rovo tools.
- State is stored per issue under `.codex/jira-flow/state/`.
