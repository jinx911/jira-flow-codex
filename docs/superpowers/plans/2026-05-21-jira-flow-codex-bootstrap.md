# Jira-Flow Codex Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a standalone Codex-native `jira-flow-codex` project with complete skill and role-reference skeleton.

**Architecture:** Keep the original project untouched. Copy reusable workflow material into a new Codex project and replace the runtime entrypoints with Codex `SKILL.md` files.

**Tech Stack:** Markdown skills, shell installer, Codex skills directory.

---

### Task 1: Bootstrap Project

**Files:**
- Create: `<repo>/README.md`
- Create: `<repo>/README.zh-CN.md`
- Create: `<repo>/install-codex.sh`
- Create: `<repo>/skills/jira-flow/SKILL.md`
- Create: `<repo>/skills/init-jira-flow/SKILL.md`
- Create: `<repo>/skills/git-ops/SKILL.md`
- Create: `<repo>/skills/team-orchestration/SKILL.md`

- [ ] **Step 1: Create directory skeleton**

Run: `mkdir -p <repo>/skills/jira-flow/references/{phases,roles}`
Expected: directory exists.

- [ ] **Step 2: Copy workflow references**

Run: `cp` source phase, gate, resume, team-rules, project-config template, and agent prompt files into the new project.
Expected: references are present under `skills/jira-flow/references/`.

- [ ] **Step 3: Add Codex skill entrypoints**

Write the Codex-native `SKILL.md` files listed above.
Expected: every skill directory has an uppercase `SKILL.md`.

- [ ] **Step 4: Add installer**

Write `install-codex.sh` to symlink `skills/*` into `${CODEX_HOME:-$HOME/.codex}/skills`.
Expected: installer does not touch legacy runtime directories.

- [ ] **Step 5: Verify structure**

Run: `find <repo> -maxdepth 4 -type f | sort`
Expected: README, installer, skill entrypoints, references, and role prompts are listed.
