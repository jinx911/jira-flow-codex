# Contributing

## Development

1. Create a branch for each logical change.
2. Keep legacy runtime behavior out of Codex runtime files.
3. Keep examples generic. Do not include personal paths, private Jira keys, tokens, credentials, or customer data.
4. Run verification before submitting changes.

## Verification

Run these checks before committing:

```bash
bash -n install.sh uninstall.sh sync-local.sh
rg -n "SendMessage|TaskCreate|TaskUpdate|Agent\\(|team-orchestration|skills/jira-flow|~/.claude" skills commands README*.md docs --glob '!docs/migration-from-legacy.md' --glob '!skills/dev-flow/resume.md'
```

The `rg` command should return no matches.

## Commit Style

Use concise conventional commits:

```text
feat: add command shim
fix: remove hardcoded install path
docs: document migration from legacy config
```

## Security

Never commit secrets. Project configuration examples must use environment variable names or secret-manager references, not literal credentials or empty credential fields inviting users to fill them in.
