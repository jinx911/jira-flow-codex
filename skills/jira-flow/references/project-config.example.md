---
partOf: jira-flow
version: 1.0.0
description: Project configuration example template. Users reference this file to manually create <project-root>/.codex/jira-flow/project-config.md.
---

# Project Config Example

> This file is an example template for project configuration.
> In practice, the Codex `init-jira-flow` skill auto-generates it at `<project-root>/.codex/jira-flow/project-config.md`.
> Alternatively, manually copy this file and fill in actual values.

---

## OpenSpec

openspec:
  changes_path: "openspec/changes"      # jira-flow work output directory (relative to root_path)
  baseline_path: "openspec/specs"       # System baseline docs (optional, leave empty to skip baseline correlation checks)

## Basic Info

root_path: "/path/to/your/project"
tech_stack: { backend: "laravel", frontend: "react", database: "mysql" }

## Runtime

# If using Docker:
docker: { container: "your-php-container", workdir: "/workspace/your-project/" }
artisan: 'docker exec your-php-container bash -c "cd /workspace/your-project && {cmd}"'

## Repository Architecture

# Single repo:
backend: { main_repo: "." }

# Multi-repo (uncomment and fill):
# backend: { main_repo: "backend/", modules_path: "backend/modules/" }
# frontend: { repo: "frontend/" }
# modules:
#   - { name: "module-a", desc: "Module A", path: "backend/modules/module-a/" }

## Git Config

git:
  main_branch: "master"  # or "main"
  branch_naming:
    format: "{issue_key}"
    types: [feature, fix, refactor]
  commit_format: "<type>(<scope>): <description>"

## Deploy Branch (optional)

# If your project auto-deploys from a specific branch (e.g., "test" → staging):
# deploy_branch: "test"
# If omitted, Phase 6 will skip the merge-to-deploy-branch step.

## Jira Workflow

# jira-flow uses the following defaults if this section is omitted:
#   testing_status: auto-detect (looks for 'Test'/'测试' in available transitions)
#   auto_creates_sub: true
#   sub_completion_status: auto-detect (looks for 'Done'/'完成' in available transitions)
#   testing_note_template: built-in 5-field template (Change overview, Affected modules, Testing highlights, Prerequisites, Verification steps)
#
# Override if your Jira uses non-standard status names:
# jira_workflow:
#   testing_status: "In Testing"
#   auto_creates_sub: true
#   sub_completion_status: "Done"
#   testing_note_template: |
#     Change overview: <summary>
#     Affected modules: <modules>
#     Testing highlights: <key results>
#     Prerequisites: <setup needed>
#     Verification steps: <how to verify>

## Database Tools

# Map available Codex database tools/connectors for verification.
databases:
  main: { tool: "mcp__mysql__mysql_query", desc: "Main database" }
  # tenant_a: { tool: "mcp__mysql__mysql_query", desc: "Tenant A" }

## Test Environments

# Do not store credentials here. Reference environment variables or a secret manager.
test_environments:
  default:
    url: "http://your-test-env.example.com"
    account_env: "JIRA_FLOW_TEST_ACCOUNT"
    password_env: "JIRA_FLOW_TEST_PASSWORD"
    desc: "Default test environment"

## E2E Testing

e2e_testing:
  approach: "codex-browser-plugin"
  login_template: |
    async (page) => {
      await page.goto('{url}/login');
      await page.fill('input[name="email"]', process.env.JIRA_FLOW_TEST_ACCOUNT);
      await page.fill('input[type="password"]', process.env.JIRA_FLOW_TEST_PASSWORD);
      await page.click('button:has-text("Login")');
      await page.waitForURL('**/dashboard', { timeout: 10000 });
      return { loggedIn: true };
    }

---

## Build Commands (agents reference these)

build_commands:
  frontend: "npm run build"  # Command when frontend files change
  backend: ""               # Usually not needed for PHP projects

## Migration (Phase 3 backend development reference)

migration:
  steps:
    - "php artisan migrate --force"
    - "php artisan tenancy:migrate --force"  # If multi-tenant
  note: "Run only when migration files are created/modified"

## Deployment Checklist

- [ ] Confirm git branch
- [ ] Frontend build (if frontend changed)
- [ ] Database migration (if migration changed)
- [ ] Route cache clear (if routes changed)
