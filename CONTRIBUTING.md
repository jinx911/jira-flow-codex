# Contributing

## Development

1. Create a branch for each logical change.
2. Keep Claude-specific runtime behavior out of Codex runtime files.
3. Keep examples generic. Do not include personal paths, private Jira keys, tokens, credentials, or customer data.
4. Run verification before submitting changes.

## Verification

Run these checks before committing:

```bash
bash -n install-codex.sh
rg -n "SendMessage|TaskCreate|TaskUpdate|AskUserQuestion|mcp__atlassian-rovo|browser_run_code_unsafe" skills README*.md
```

The `rg` command should return no matches unless the match is in migration documentation and explicitly marked as legacy context.

## Commit Style

Use concise conventional commits:

```text
feat: add command shim
fix: remove hardcoded install path
docs: document migration from claude config
```

## Security

Never commit secrets. Project configuration examples must use environment variable names or secret-manager references, not literal credentials or empty credential fields inviting users to fill them in.
