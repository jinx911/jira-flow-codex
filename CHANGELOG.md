# Changelog

All notable feature-level changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `learn` skill with `capture` / `apply` / `distill` loop, project knowledge format, and global playbook
- `bugfix-flow` skill for lightweight bug analysis, repair, verification, and deployment
- `bugfix-flow` command shim for Codex slash-command environments
- `docs/dev-flow-training.md` for Codex onboarding and internal training
- `sync-local.sh` to copy repo-owned skills into local Codex skill directories without relying on symlinks
- `CHANGELOG.md` for feature-level change tracking

### Changed

- Upgraded Gate semantics to include Gate 1 key-decision mini-gate and Gate 2 mandatory test evidence
- Upgraded `dev-flow` to document learn-loop integration, stronger state semantics, and Codex-native collaboration guidance
- Upgraded README and migration docs to cover learn, bugfix-flow, training assets, and new sync workflow
- Expanded install/uninstall expectations to include the new skills and command shims automatically

### Removed

- Removed stale `commands/jira-flow-team.md` legacy entrypoint that still referenced `jira-flow`, `team-orchestration`, and obsolete paths
