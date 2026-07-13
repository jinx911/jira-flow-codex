---
name: ship
description: 定稿开发分支时使用：跑全量测试、清 debug 代码、提交推送，再可选地合并到 deploy_branch、触发 Jenkins、做 Jira 收尾（jira 模式）。可独立调用。
---

# Ship：收尾 + 部署 + Jira

## 1. 定稿 + 单 commit
backend-developer：
1. 跑**全量**测试、清 debug 代码（console.log/dd/dump/var_dump）
2. **一个需求一个大 commit**：`git add -A`（含代码 + 测试 + `.dev-flow/{issue_key}/spec/` 文档）→ 一次 commit → push 分支（MR 用户手动）
3. commit message（中文）：
   ```
   <type>(<scope>): <一句话概述>

   <2-4 行变更说明>

   Issue: {issue_key}
   ```
   （type/scope 从 spec_name/影响模块推断）

**崩溃兜底**：若 dev-loop 期间会话崩溃，未提交改动仍在工作树；resume 时 dev-loop 检查 `git status`，存在未提交改动则提示用户"上次有未提交改动，接续或丢弃"。

## 2. 部署合并（可选）
配置了 `deploy_branch` 才做：checkout deploy_branch → pull → merge {branch} → push → checkout {branch}。目的：触发自动部署到测试环境。未配置则跳过。

## 3. Jenkins（可选）
仅当 `jenkins` 配置 + 当前会话中确实存在 Jenkins 工具时才做。先向用户确认参数，再调用当前环境真实可用的 Jenkins 工具。若当前环境没有 Jenkins 工具，即使配置存在也直接跳过并在 Gate 4 里说明。

## 4. Jira 收尾（仅 jira 模式）
- 只有当当前会话存在可读、可流转、可评论的 Jira/Rovo 工具时才执行完整收尾。
- 先读取主单可用流转与子单信息，再决定是否能自动推进测试状态和补充说明。
- 对每个提测说明类子单：填说明（project-config `testing_note_template`：变更概述 / 影响模块 / 测试要点 / 前置条件 / 验证步骤）→ 流转到完成状态。
- 测试计划类子单跳过（由 QA 处理）。
- 如果当前会话只有 Jira 写工具或完全没有 Jira 读工具，则不要伪执行；明确记录“需人工完成 Jira 收尾”。
- free 模式：整步跳过。

requirements-analyst 无响应时，Leader 可直接做 Jira MCP 操作（不涉及业务代码）。

## 驱动的 agent
编排器 spawn：backend-developer（定稿 + 部署）；requirements-analyst 或 Leader（Jira 收尾）。角色专长内嵌本 skill，**不读** `~/.codex/agents/*.md`。

## Gate 4
- [ ] 分支已推送
- [ ] deploy_branch 已合并（若配置）
- [ ] Jenkins 成功或跳过（若配置；无工具时视为受限跳过）
- [ ] Jira 已更新，或已明确记录为人工收尾（jira 模式）

## Dependencies
- Skills：git-ops
- Agents（内嵌）：backend-developer、requirements-analyst
- MCP：jenkins（可选）、atlassian-rovo（jira 模式）
- Plugin：superpowers（finishing-a-development-branch）
