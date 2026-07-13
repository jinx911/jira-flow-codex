---
name: delete-team
description: Use when user says "删除团队", "清理团队", "/delete-team" — gracefully shuts down Codex sub-agents that were created for a team workflow
---

# Delete Team

## Overview

优雅关闭团队：确认当前有哪些仍然活跃的成员 → 通知停止 → 关闭 agent。

## Codex Runtime Mapping

在 Codex 中，团队清理依赖：

- `send_input`：向仍在运行的 agent 发送停止说明
- `close_agent`：关闭不再需要的 agent

如果成员已经完成但仍占用并发配额，也应该主动关闭。

## Steps

### 1. 识别当前团队成员

根据当前会话记录、state 文件或最近创建的 agent 列表，确认有哪些 agent 仍属于当前团队。

### 2. 发送停止说明

对仍在运行的成员发送一条简短说明，告知当前团队任务结束：

```text
当前团队任务已结束，请停止当前工作并返回最后状态摘要。
```

### 3. 关闭成员

对不再需要的 agent 调用 `close_agent`。

### 4. 汇报

向用户报告：

- 已关闭的 agent
- 没有找到活跃成员时直接说明无需清理
- 若某些工作更适合保留为独立 thread，则不要关闭该 thread，只说明它已从当前团队上下文中剥离
