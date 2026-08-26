---
name: git-ops
description: Use when user wants to perform git operations — creating branches, committing code, pushing, updating branches, merging, or cleaning up branches. Supports single-repo and multi-repo architectures via project-config.
---

# Git Ops：多仓库/单仓库 Git 操作

**输入**：`$ARGUMENTS`（可选：模块名、分支名等）

## 初始化

1. 读 `<root_path>/.codex/project-config.md`（唯一来源；不存在→提示先 `/init-dev-flow`）。
2. 提取：`root_path`、`git.main_branch`(默认 main)、`git.commit_format`、`git.branch_naming.format`、`git.branch_naming.type_map`、`deploy_branch`、`modules`（有=多仓库）、`backend.main_repo`、`frontend.repo_path`、`java.gateway_repo`、`go_services`。
3. 归一化仓库拓扑：
   - backend 主仓：`backend.main_repo`
   - frontend：`frontend.repo_path`（如有）
   - Java：`java.gateway_repo`（如有）
   - Go：`go_services[]`（如有）
   - modules：`modules[].path`（如有）
4. 去重并生成仓库清单：`[{name, path, type}]`。`name` 优先取 module 名，其次取目录名；同路径只保留一次。

## 架构检测

```
仓库清单长度 > 1 → multi-repo：分支/推/并/清操作展示交互选择；commit 自动扫变更仓库
无 modules → single-repo: [root_path]，所有操作直接执行
```

如果未配置 `modules` 但通过 `frontend` / `java` / `go_services` 识别出多个仓库，也按 multi-repo 处理。

## 触发词

| 触发 | 操作 |
|------|------|
| "创建分支"/"开始需求" | 创建分支 |
| "更新分支"/"rebase" | 更新分支 |
| "commit"/"提交" | 提交代码 |
| "push"/"推送" | 推送远程 |
| "完成需求"/"合并分支" | 合并到主分支 |
| "清理分支"/"删除分支" | 清理分支 |
| "创建 worktree" | 创建 worktree（仅开发分支，公共分支拒绝） |
| "worktree 状态" | 列出各仓库 worktree 分级状态 |
| "清理 worktree" | 清理 worktree（分级标记，必须用户核对） |

## 仓库选择（仅 multi-repo）

分支/推/并/清操作前列仓库供选（后端 `[1]主仓库 [2]模块…` / 前端 / Java），编号逗号分隔或 `all`。**commit 例外**：自动扫有变更仓库。

## 提交模式

`git-ops` 自己不决定业务阶段，但会遵守上游流程约束：

- **dev-flow / ship**：默认一个需求一个大 commit；同一仓库内把本需求相关改动一次提交
- **bugfix-flow**：默认一个 bug 一个 commit
- **普通独立调用**：按用户意图提交，但仍需先展示文件清单并确认

若当前仓库没有变更，直接跳过，不制造空 commit。

## 分支保护 + Stash + 各操作详细步骤

**见 `references/git-detail.md`**：
- §分支保护规则（master/test/pre 保护 + 合并方向白名单 + 检测逻辑）
- §Stash 兜底（写操作前自动 stash/unstash）
- §Worktree 规则（公共分支禁建 + 占用检测 + 生命周期操作 + 清理核对流程）
- §仓库归一化规则（主仓 / modules / frontend / java / go 的收集方式）
- §各操作流程（创建/更新/提交/推送/合并/清理的具体命令 + 展示清单）
- §全局规则（写操作必确认、冲突即停、不擅自 push、`git -C` 不依赖 cd 等）

## 全局规则（核心）

- 所有写操作**必须用户确认**，绝不擅自执行；每次前展示清单。
- 冲突**不自动解决**，立即停止。
- `master`/`test`/`pre` 禁止直接 commit；`test`/`pre` 禁止向外合并（详见 references）。
- 默认不 push；无变更仓库跳过；用 `git -C <path>` 执行。
- 任何跨仓操作都按仓库独立汇报结果：成功 / 跳过 / 阻塞，不因单仓失败隐藏其它仓状态。
- 若分支名需自动生成，优先按 `git.branch_naming.format` + `type_map` 推断；无 issue key 时必须让用户确认最终分支名。
- **worktree 只挂开发分支**：`test`/`pre`/`master`/`deploy_branch` 等公共分支永不建 worktree；查看公共分支用只读命令（`fetch` + `log`/`diff origin/<分支>`），不 checkout。
- 所有写操作前用 `git worktree list --porcelain` 做分支占用检测；撞车一律停车报出「分支 X 在 worktree Y」，人工决策。
- **清理 worktree/分支必须先与用户核对**：分级清单 → 勾选确认 → 才执行删除，绝不自动删。
