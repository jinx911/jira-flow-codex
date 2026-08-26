# Step 3：部署

> 目标：一个 bug 一个 commit + push，合并 deploy 分支，可选部署，更新 Jira。

## 前置

- Gate 2 已过，修复确认，测试通过
- 所有改动未提交在工作树

## 1. 单 commit + push（每仓库）

委托 backend-developer：调 `/git-ops` 提交并推送。

**一个 bug 一个 commit**（每仓库一个 commit，含本次修复全部改动）。commit message（中文）：

```text
fix(<scope>): <一句话修复概述>

<1-3 行说明>

Refs {issue_key 或 bug_id}
```

`/git-ops` 处理：扫变更、展示清单确认、`git add <具体文件>`（不用 `-A`）、commit、push `origin/{branch}`、分支保护、stash 安全。Leader 收集每仓库 commit SHA。

## 2. 合并到 deploy 分支

仅配置了 `deploy_branch` 才做，否则跳过。

委托 backend-developer：`/git-ops` 合并 `{branch} → {deploy_branch}`。`/git-ops` 处理分支保护/方向校验、stash、`checkout deploy → pull → merge → push → checkout 回`。冲突 → 停，用户手解。

## 3. 部署（可选）

仅配置了部署工具且当前会话真实可用时才做，否则静默跳过。

- 任务单一：直接用默认任务
- 任务多个：先让用户确认目标
- 参数可推断：预填 branch / env；敏感参数不自动填
- 成功：记录 build 编号 / 链接
- 失败：抓日志摘要，用户选重试(≤2)/跳过/中止

## 4. Jira 更新（仅 jira 模式）

仅 `issue_key` 非空执行；free 模式跳过。

- 加修复评论：根因 / 修复 / 改动文件 / 测试结果 / 部署信息 / 分支
- 子任务可流转到完成；普通 issue 默认仅评论，除非项目规则另有约定

## Gate 3

Semi-auto：向用户展示最终摘要（bug / 根因 / 各仓库 commit SHA / 部署 / Jira）+ "分支 {branch} 可建 MR（MR 手动创建）"。确认 → 删 state 文件。  
Full-auto：记录自动完成。  
更新 state：`current_step=3`，`step_results.3={commits, deploy_results, jira_updated}`。  
Gate 3 通过 → 删 `{root_path}/.bugfix-flow/{bug_id}-state.json`。
