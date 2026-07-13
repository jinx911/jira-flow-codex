---
name: create-team
description: Use when user says "创建团队", "组建团队", "/create-team" — creates a Codex multi-agent team with a Hub-and-Spoke coordination pattern
---

# Create Team

## Overview

创建多 Agent 协作团队。**主会话即为 Leader**，不额外创建 leader agent。所有成员通信都通过主会话路由。

## Codex Runtime Mapping

本 skill 在 Codex 中不依赖独立的 team registry 工具，按下列方式工作：

- 用 `spawn_agent` 创建成员
- 用 `send_input` 向成员派单或广播上下文
- 用 `wait_agent` 等待关键结果
- 用 `close_agent` 在结束时清理不再需要的成员

在 Codex 中，“创建团队”的本质不是创建一个中心化团队对象，而是：

- 定义一组清晰角色
- 为每个角色创建受控的 sub-agent
- 由主会话维护唯一协调权

## 调用模式

### 模式 A：交互式

用户直接触发 `/create-team` 时：

1. 主会话用普通对话向用户确认团队名称
2. 再确认需要哪些角色
3. 如有自定义角色，再确认名称和职责
4. 用 `spawn_agent` 并行启动成员
5. 向用户汇报就位状态

### 模式 B：编程式

当其他 skill（如 `/dev-flow`）调用时，直接传入结构化团队配置并跳过交互步骤。

示例：

```text
/create-team {"team_name":"dev-flow-OA-3650","roles":[{"name":"requirements-analyst","agent":"requirements-analyst"},{"name":"architect","agent":"architect"},{"name":"planner","agent":"planner"},{"name":"backend-dev","agent":"backend-developer"},{"name":"frontend-dev","agent":"frontend-developer"},{"name":"code-reviewer","agent":"code-reviewer"}],"custom_prompt":"<自定义 prompt 内容>"}
```

## 角色配置

默认可选角色：

| 角色 | name | prompt 来源 |
|------|------|------------|
| 前端开发 | frontend-dev | `agents/frontend-developer.md` |
| 后端开发 | backend-dev | `agents/backend-developer.md` |
| 需求分析师 | requirements-analyst | `agents/requirements-analyst.md` |
| 架构师 | architect | `agents/architect.md` |
| 规划师 | planner | `agents/planner.md` |
| 代码审查 | code-reviewer | `agents/code-reviewer.md` |
| QA 测试 | qa-tester | `agents/tdd-guide.md` + `agents/e2e-runner.md` |
| 测试验证 | tester | `agents/tester.md` |

## 启动规则

对每个角色并行调用 `spawn_agent`：

- `agent_type`: `worker`
- `fork_context`: `true`
- prompt 中明确：
  - 角色职责
  - 这是一个 Hub-and-Spoke 团队
  - 不可直接与其他成员通信
  - 不可回滚别人的改动
  - 需要通过主会话汇报结果

推荐的职责分配方式：

- `requirements-analyst` / `architect`：读需求、产出设计，不写业务代码
- `planner`：拆任务、整理实现顺序
- `backend-developer` / `frontend-developer`：各自负责明确写入边界
- `code-reviewer` / `tester`：只做审查与验证，避免和开发写同一组文件

如果多个成员会修改同一文件集，不要并行创建；改为串行委派，或直接使用 worktree/thread 隔离。

## Leader 约束

Leader 负责：

- 接收用户任务
- 决定是否拆分
- 用 `send_input` 向成员派发工作
- 汇总成员结果
- 在成员闲置或任务结束后关闭成员

Leader 还应决定什么时候**不要**创建团队：

- 下一步立即依赖某个结果，且本线程自己做更快
- 任务太小，拆成团队只会增加协调成本
- 多成员会争抢同一写入范围
- 需要长期隔离上下文，此时更适合 thread/worktree

团队存在期间，Leader 默认不直接写业务代码，除非用户明确要求。

## Worker Prompt 模板

```text
你是 {team_name} 团队的 {角色名称}。

## 职责
{角色职责}

## 协作规则
- 你不是独自在代码库中工作
- 不要回滚其他人已经做出的修改
- 所有结果都回复给主会话 Leader
- 不要直接联系其他成员
- 遇到阻塞立即汇报

当前状态：已就位，等待 Leader 分配任务。
```
