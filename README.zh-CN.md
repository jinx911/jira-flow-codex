# Jira-Flow Codex

**中文** | [English](README.md)

Jira-Flow Codex 是独立的 Codex 原生工作流项目。

目标：从 Jira Issue 出发，在 Codex 中完成需求分析、方案设计、任务规划、TDD 开发、代码评审、测试验证、提交收尾和 Jira 更新。

## Codex 版设计

| 能力 | Codex 版 |
| --- | --- |
| Skill 入口 | `~/.codex/skills/*/SKILL.md` |
| 角色定义 | `skills/jira-flow/references/roles/*.md` |
| 团队编排 | Codex 主会话 + 可选 sub-agent |
| Jira 工具 | Codex Atlassian Rovo 工具 |
| 权限模型 | Codex sandbox + escalation approval |

## 项目结构

```text
jira-flow-codex/
├── install-codex.sh
├── commands/
│   ├── init-jira-flow.md
│   ├── jira-flow.md
│   └── jira-flow-team.md
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
cd jira-flow-codex
./install-codex.sh
```

安装脚本会把 `skills/*` 链接到 `~/.codex/skills/`，并安装 slash command shim。

## 使用

初始化当前项目：

```text
/init-jira-flow
```

处理 Jira issue：

在 Codex 中触发：

```text
/jira-flow PROJ-123
/jira-flow-team PROJ-123
```

如果当前 Codex 环境没有加载自定义 slash command，则使用等价触发语：

```text
使用 init-jira-flow 初始化当前项目
使用 jira-flow 处理 PROJ-123
使用 jira-flow 处理 PROJ-123，并启用 Codex sub-agents team 模式
```

默认使用单会话阶段化执行。使用 `/jira-flow-team` 时，Codex 版会显式启用 sub-agent 团队模式：主会话作为 Leader 负责 Gate、状态文件、冲突协调和最终 Jira 更新，适合拆分的探索、实现、评审和验证任务可委派给 `explorer` 或 `worker` sub-agent。

## 当前状态

- 已迁移并适配 phase/gate/resume/team-rules。
- 已迁移 agents 为 Codex role references。
- 已新增 Codex 原生 skill 入口、`/init-jira-flow`、`/jira-flow`、`/jira-flow-team` command shim 和安装脚本。
- 可安装到 `~/.codex/skills/` 后在 Codex 中使用。

## 迁移说明

旧版配置迁移说明见 [docs/migration-from-legacy.md](docs/migration-from-legacy.md)。

## 许可证

MIT。详见 [LICENSE](LICENSE)。
