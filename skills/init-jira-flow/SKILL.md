---
name: init-jira-flow
description: Use when setting up Jira-Flow Codex for a project. Detects project structure and creates Codex-specific project config.
version: 0.1.0
tags: [jira-flow, codex, setup]
---

# Init Jira-Flow Codex

## Goal

Initialize a project for the Codex version of Jira-Flow.

Input examples:

- `/init-jira-flow`
- `/init-jira-flow /path/to/project`
- `init-jira-flow 当前项目`

## Outputs

Create:

```text
<project-root>/.codex/jira-flow/project-config.md
<project-root>/.codex/jira-flow/state/
```

Do not create or overwrite legacy runtime files.

## Detection

Inspect the project root for:

- `composer.json`
- `package.json`
- `pom.xml`
- `build.gradle`
- `go.mod`
- `Cargo.toml`
- `.git`
- Docker files
- existing legacy project config for migration compatibility

## Atlassian

Use Codex Atlassian Rovo tools to confirm access and discover `cloudId`.

## Config Rules

If `.codex/jira-flow/project-config.md` already exists, read it and ask before overwriting. If a legacy project config exists, offer to import compatible fields into the Codex config.

Generated project config should include or document this Jira workflow block:

```markdown
## Jira Workflow

jira_workflow:
  testing_status: "测试中"              # Main issue -> this status triggers sub-issue creation
  auto_creates_sub: true                # Does transitioning auto-create sub-issues?
  sub_completion_status: "已完成"       # Sub-issues -> this status after filling testing notes
  testing_note_template: |
    Change overview: <summary>
    Affected modules: <modules>
    Testing highlights: <key results>
    Prerequisites: <setup needed>
    Verification steps: <how to verify>
```

If the user's Jira uses different status names, ask them to customize `testing_status` and `sub_completion_status`. If omitted, Phase 6 auto-detects statuses containing `Test`/`测试` and `Done`/`完成`.
