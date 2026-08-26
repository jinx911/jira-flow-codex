# Dev-Flow 培训指南（Codex）

> 全链路 Agent Team 开发工作流 —— 从需求（Jira Issue 或自然语言）到代码提交

## 1. 概述

### 什么是 Dev-Flow？

Dev-Flow 是一个 Codex Skill，自动化执行从需求到代码提交的完整开发流程。它用一个**薄编排器 + 4 个可复用子 skill**，通过 hub-and-spoke 模式协调多个 sub-agent，以 **4 个 Stage + 4 个 Gate** 完成：

```text
需求（Jira key 或文本）→ spec → dev → review-test → ship → 分支推送 + Jira 更新

Stage 1: spec-author   需求 → proposal.md + design.md（自适应工程章节）
Stage 2: dev-loop      tasks.md + 分支 + 实现（条件化 TDD + 文档优先变更）
Stage 3: review-test   审查 + 验证 + 修复环
Stage 4: ship          定稿 + 部署 + Jira 收尾
```

### 核心价值

- **全链路自动化**：从需求到提交，无需手动切换流程
- **文档驱动**：proposal/design 结构化，按触发条件展开工程章节
- **活文档**：开发中发现需求缺口，先改文档再改代码
- **条件化 TDD**：只在真正有可测逻辑的单元启用
- **人机协作**：semi-auto 模式下由用户确认 Gate
- **可恢复**：状态存 `.dev-flow/{issue_key}-state.json`
- **可演进**：`learn` 会沉淀知识库与 playbook

### 两种运行模式

| 特性 | 半自动（默认） | 全自动 |
|---|---|---|
| Gate | 展示 checklist 摘要 + 用户确认 | 自动放行，记录摘要 |
| 范围性 spec-delta | 总是问用户 | 仅超重试上限才问 |
| Jira/分支动作 | 先确认 | 自动执行 |
| 适用场景 | 复杂需求、首次使用 | 简单需求、熟悉流程后 |

## 2. 架构

### 薄编排器 + 4 子 skill

```text
User
  ↓ /dev-flow OA-3650
Leader
  ↓ 触发子 skill（每阶段一个）
spec-author / dev-loop / review-test / ship
  ↓
sub-agents（通过 spawn_agent / send_input）
```

关键原则：

- Leader **永不直接执行**业务操作，只协调/决策/路由
- 每个阶段都是**可独立调用**的子 skill
- 所有 agent 通信都经 Leader 路由
- **角色专长内嵌在子 skill**，主流程不依赖 `agents/*.md`
- **预生成 prompt**：`.dev-flow/{key}/prompts/{stage}.md`
- **当前任务清单是事实源**，不依赖心跳协议

### Codex 协作模型

推荐层级：

1. 默认：主线程 + sub-agent（`spawn_agent` / `send_input`）
2. 需要隔离 git 或长任务：thread/worktree
3. 需要周期性回访：automation

## 3. Stage 说明

### Stage 1：spec-author

- 读 Jira 或自然语言需求
- 写 `proposal.md` 与 `design.md`
- 按触发条件补数据模型 / API 契约 / 接口边界 / 状态流 / 错误契约 / 测试策略
- Gate 1 除完整性外，还会做**关键决策 mini-Gate**

### Stage 2：dev-loop

- 生成 `tasks.md`
- 建分支
- 按 `tdd / regression / smoke / none` 条件化实现
- 发现需求缺口时先走 spec-delta

### Stage 3：review-test

- 结构化代码审查
- 测试验证以**证据优先**
- CRITICAL/HIGH 与 bug 进入修复环

### Stage 4：ship

- 清 debug、跑全量测试
- 一个需求一个大 commit
- 可选合并 deploy 分支与触发部署
- jira 模式下做 Jira 收尾

## 4. 学习闭环

`learn` 在两处自动触发：

- Stage 0：`apply`，把相关经验注入当前阶段 prompt
- Stage 4：`capture`，把本次 run 信号写进 `lessons-*.jsonl`

当 `lessons_captured >= 5` 时，系统会提醒运行：

```text
/dev-flow learn --upgrade
```

它会提炼：

- 项目级：`{root_path}/.dev-flow/knowledge.md`
- 全局级：`skills/dev-flow/playbook.md`

## 5. 初始化与配置

三层配置：

```text
~/.codex/configs/projects.json
{root_path}/.codex/project-config.md
~/.codex/configs/dev-flow/project-config.md
```

推荐先运行：

```text
/init-dev-flow
```

## 6. 典型命令

```text
/init-dev-flow
/dev-flow OA-3650
/dev-flow 给用户管理增加 CSV 导出功能
/dev-flow learn 这次返工是因为接口错误语义未先确认
/dev-flow learn --upgrade
/bugfix-flow OA-4123
```

## 7. 使用建议

- 第一次在项目中启用时，优先用 semi-auto
- 对多仓项目，先补齐 project-config 中的 repo 拓扑
- 让 Gate 1 的关键决策确认尽早暴露错误方案
- 测试汇报必须附命令、原始计数、失败列表
