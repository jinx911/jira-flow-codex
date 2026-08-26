[中文](README.zh-CN.md) | **English**

# Dev-Flow Codex

Codex-native `dev-flow` workflow repository.

It upgrades `jira-flow-codex` to the newer `dev-flow` architecture and content model:

```text
Requirement (Jira key or text) -> 4 Stages + 4 Gates -> branch push + Jira wrap-up

Stage 1: Spec        (spec-author) -> proposal.md + design.md
Stage 2: Dev         (dev-loop)    -> tasks.md + branch + implementation
Stage 3: Review-Test (review-test) -> review + verification + fix loop
Stage 4: Ship        (ship)        -> push + optional deploy + Jira finalization
```

## Architecture

- `skills/dev-flow/` is the thin orchestrator.
- `spec-author`, `dev-loop`, `review-test`, and `ship` are independently invocable stage skills.
- `learn` adds a closed-loop knowledge system (`apply` / `capture` / `distill`).
- `bugfix-flow` provides a lighter path for focused defect repair.
- `init-dev-flow`, `create-team`, `delete-team`, and `git-ops` provide setup and support workflows.
- `agents/` stores optional role prompt files; the main workflow does not depend on them.

## Codex Differences

This repo follows the new `dev-flow` shape while keeping Codex-specific installation and runtime assumptions:

- Skills install into `~/.codex/skills/`
- Command shims install into `~/.codex/commands/` and `~/.codex/workflows/`
- Skills are also linked into `~/.agents/skills/` to improve native discovery
- Runtime configuration should live under `~/.codex/configs/dev-flow/`, not inside the symlinked skill directory
- Jira operations are expected to run through the Codex Atlassian Rovo toolchain
- A sync script is provided for local skill-copy workflows: `./sync-local.sh`

## Install

```bash
cd jira-flow-codex
chmod +x install.sh uninstall.sh
./install.sh
```

Optional local copy workflow for skill authors:

```bash
chmod +x sync-local.sh
./sync-local.sh --all
```

## Usage

Preferred commands:

```text
/init-dev-flow
/dev-flow PROJ-123
/bugfix-flow PROJ-456
```

Fallback if custom slash commands are unavailable:

```text
Use init-dev-flow for the current project
Use dev-flow for PROJ-123
```

## Layout

```text
skills/dev-flow/
skills/spec-author/
skills/dev-loop/
skills/review-test/
skills/ship/
skills/learn/
skills/bugfix-flow/
skills/init-dev-flow/
skills/create-team/
skills/delete-team/
skills/git-ops/
agents/
commands/dev-flow.md
commands/init-dev-flow.md
commands/bugfix-flow.md
```

## Migration

See [docs/migration-from-legacy.md](docs/migration-from-legacy.md) for legacy `jira-flow` to `dev-flow` migration notes, and [docs/dev-flow-training.md](docs/dev-flow-training.md) for team onboarding.

## License

MIT. See [LICENSE](LICENSE).
