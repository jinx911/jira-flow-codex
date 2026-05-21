# Jira-Flow Codex Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a standalone Codex-native `jira-flow-codex` project with complete skill and role-reference skeleton.

**Architecture:** Keep the Claude project untouched. Copy reusable workflow material into a new Codex project and replace the runtime entrypoints with Codex `SKILL.md` files.

**Tech Stack:** Markdown skills, shell installer, Codex skills directory.

---

### Task 1: Bootstrap Project

**Files:**
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/README.md`
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/README.zh-CN.md`
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/install-codex.sh`
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/skills/jira-flow/SKILL.md`
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/skills/init-jira-flow/SKILL.md`
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/skills/git-ops/SKILL.md`
- Create: `/Users/eliojin/IdeaProjects/jira-flow-codex/skills/team-orchestration/SKILL.md`

- [ ] **Step 1: Create directory skeleton**

Run: `mkdir -p /Users/eliojin/IdeaProjects/jira-flow-codex/skills/jira-flow/references/{phases,roles}`
Expected: directory exists.

- [ ] **Step 2: Copy workflow references**

Run: `cp` source phase, gate, resume, team-rules, project-config template, and agent prompt files into the new project.
Expected: references are present under `skills/jira-flow/references/`.

- [ ] **Step 3: Add Codex skill entrypoints**

Write the Codex-native `SKILL.md` files listed above.
Expected: every skill directory has an uppercase `SKILL.md`.

- [ ] **Step 4: Add installer**

Write `install-codex.sh` to symlink `skills/*` into `${CODEX_HOME:-$HOME/.codex}/skills`.
Expected: installer does not touch `~/.claude`.

- [ ] **Step 5: Verify structure**

Run: `find /Users/eliojin/IdeaProjects/jira-flow-codex -maxdepth 4 -type f | sort`
Expected: README, installer, skill entrypoints, references, and role prompts are listed.
