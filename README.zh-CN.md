**中文** | [English](README.md)

# Dev-Flow Codex

这是一个 Codex 原生的 `dev-flow` 工作流仓库。

它把原本的 `jira-flow-codex` 对齐到新的 `dev-flow` 架构：

```text
需求（Jira key 或自然语言） -> 4 个 Stage + 4 个 Gate -> 分支推送 + Jira 收尾

Stage 1: 需求     (spec-author) -> proposal.md + design.md
Stage 2: 开发     (dev-loop)    -> tasks.md + 分支 + 实现
Stage 3: 审查测试 (review-test) -> 审查 + 验证 + 修复环
Stage 4: 收尾     (ship)        -> 推送 + 可选部署 + Jira 收尾
```

## 架构

- `skills/dev-flow/` 是薄编排器。
- `spec-author`、`dev-loop`、`review-test`、`ship` 是可独立调用的阶段子 skill。
- `init-dev-flow`、`create-team`、`delete-team`、`git-ops` 提供初始化和支撑能力。
- `agents/` 存放可选角色提示文件；主流程不依赖这些 agent 文件。

## Codex 差异

本仓库遵循新的 `dev-flow` 结构，但保留 Codex 环境的安装与运行差异：

- skills 安装到 `~/.codex/skills/`
- command shim 安装到 `~/.codex/commands/` 和 `~/.codex/workflows/`
- 同时链接到 `~/.agents/skills/`，增强 native discovery
- 运行时配置放在 `~/.codex/configs/dev-flow/`，不要写进符号链接出去的 skill 目录
- Jira 操作预期通过 Codex 的 Atlassian Rovo 工具链执行

## 安装

```bash
cd jira-flow-codex
chmod +x install.sh uninstall.sh
./install.sh
```

## 使用

推荐命令：

```text
/init-dev-flow
/dev-flow PROJ-123
```

如果当前 Codex 环境没有加载自定义 slash command，可使用等价表达：

```text
使用 init-dev-flow 初始化当前项目
使用 dev-flow 处理 PROJ-123
```

## 目录结构

```text
skills/dev-flow/
skills/spec-author/
skills/dev-loop/
skills/review-test/
skills/ship/
skills/init-dev-flow/
skills/create-team/
skills/delete-team/
skills/git-ops/
agents/
commands/dev-flow.md
commands/init-dev-flow.md
```

## 迁移说明

旧版 `jira-flow` 到新 `dev-flow` 体系的迁移说明见 [docs/migration-from-legacy.md](docs/migration-from-legacy.md)。

## 许可证

MIT。详见 [LICENSE](LICENSE)。
