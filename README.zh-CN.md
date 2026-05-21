# Jira-Flow Codex

Jira-Flow Codex 是从 Claude Code 版 `jira-flow` 独立拆出的 Codex 原生工作流项目。

目标：从 Jira Issue 出发，在 Codex 中完成需求分析、方案设计、任务规划、TDD 开发、代码评审、测试验证、提交收尾和 Jira 更新。

## 与 Claude 版的区别

| 能力 | Claude 版 | Codex 版 |
| --- | --- | --- |
| Skill 入口 | `~/.claude/skills/*/skill.md` | `~/.codex/skills/*/SKILL.md` |
| Agent 定义 | `~/.claude/agents/*.md` | `skills/jira-flow/references/roles/*.md` |
| 团队编排 | Claude slash command + message routing | Codex 主会话 + 可选 sub-agent |
| Jira 工具 | Claude MCP 工具名 | Codex Atlassian Rovo 工具 |
| 权限模型 | Claude settings allowlist | Codex sandbox + escalation approval |

## 项目结构

```text
jira-flow-codex/
├── install-codex.sh
├── commands/
│   ├── init-jira-flow.md
│   └── jira-flow.md
├── skills/
│   ├── jira-flow/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── gate.md
│   │       ├── resume.md
│   │       ├── team-rules.md
│   │       ├── project-config.example.md
│   │       ├── phases/
│   │       └── roles/
│   ├── init-jira-flow/
│   │   └── SKILL.md
│   ├── git-ops/
│   │   └── SKILL.md
│   └── team-orchestration/
│       └── SKILL.md
└── docs/
```

## 安装

```bash
cd /Users/eliojin/IdeaProjects/jira-flow-codex
./install-codex.sh
```

安装脚本会把 `skills/*` 链接到 `~/.codex/skills/`。不会修改 Claude Code 的 `~/.claude` 目录。

## 使用

初始化当前项目：

```text
/init-jira-flow
```

处理 Jira issue：

在 Codex 中触发：

```text
/jira-flow OA-3650
```

如果当前 Codex 环境没有加载自定义 slash command，则使用等价触发语：

```text
使用 init-jira-flow 初始化当前项目
使用 jira-flow 处理 OA-3650
```

默认使用单会话阶段化执行。只有当用户明确要求“用子代理团队/并行 agent”时，Codex 版才启用 sub-agent 团队模式。

## 当前状态

- 已迁移并适配 phase/gate/resume/team-rules。
- 已迁移 agents 为 Codex role references。
- 已新增 Codex 原生 skill 入口、`/init-jira-flow` 与 `/jira-flow` command shim 和安装脚本。
- 可安装到 `~/.codex/skills/` 后在 Codex 中使用。
