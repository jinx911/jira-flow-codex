---
name: dev-flow
description: 当用户提供 Jira issue key/URL（jira 模式）或自然语言需求描述（free-flow 模式），需要完整开发生命周期（需求 spec → 开发 dev → 审查测试 review-test → 收尾 ship）时使用。编排多 agent 团队，Leader 只委托执行以保持上下文干净。每个阶段都是可独立调用的子 skill。
---

# Dev-Flow：全链路 Agent Team 开发工作流

**输入：** `$ARGUMENTS`
- **jira 模式**：匹配 `^[A-Z]+-\d+$` 或包含 `/browse/`
- **free-flow 模式**：其余全部；整段文本作为 `requirement_text`
  - issue key 自动生成为 `ff-{slug}-{HHmm}`（`{slug}` = 文本 kebab-case 前 40 字符）
- **恢复模式**：`$ARGUMENTS` 为空（`/dev-flow` 无参）→ 列出 `.dev-flow/*-state.json` 未完成 flow 供选择恢复（见 `resume.md`）。
- **学习命令**：`/dev-flow learn <note>` 手动记一条 manual_note；`/dev-flow learn --upgrade` 触发 distill 提炼升级。

## 四个阶段（Stage）

每个阶段是一个可复用子 skill。Leader 每阶段触发一个、跑 Gate、再推进。

| 阶段 | 子 skill | 产出 | Gate |
|---|---|---|---|
| 1 需求 | `spec-author` | proposal.md + design.md（自适应工程章节） | Gate 1：完整性 checklist |
| 2 开发 | `dev-loop` | tasks.md + 分支 + 实现代码 | Gate 2：任务完成 + 测试绿 |
| 3 审查测试 | `review-test` | 审查 + 验证报告 | Gate 3：无 CRITICAL/HIGH + 测试通过 |
| 4 收尾 | `ship` | 推送 + 部署 + Jira 收尾 | Gate 4：最终总结 |

进入每阶段前，Read 该子 skill 的 `SKILL.md`。每个 Gate 前，Read `gate.md`。

## 学习闭环（learn）

`learn` 子 skill 在两点自动触发：

- **Stage 0**：调 `learn apply` → 读 `{root_path}/.dev-flow/knowledge.md` → 挑相关条目 → 注入**当前阶段**子 skill 的 prompt 文件
- **Stage 4**：调 `learn capture` → 把本次 run 信号写入 `{root_path}/.dev-flow/{issue_key}/lessons-{HHmm}.jsonl`，`lessons_captured++`
- **distill 提醒**：`lessons_captured` 每 ≥5 时，编排器在 Stage 4 收尾后提醒执行 `/dev-flow learn --upgrade`

手动：`/dev-flow learn <note>` → capture 一条 manual_note；`/dev-flow learn --upgrade` → distill（见 `learn/SKILL.md`）。首次 run（无 knowledge）→ apply 返回空，零开销。

## 进度看板

每个 Gate 通过后展示：
```
Stage: [✅1][✅2][🔄3][·4]  {issue_key} | Branch: {branch} | Complexity: {complexity}
```
符号：`✅` 完成、`🔄` 当前、`·` 待办。

## Leader 约束

主会话即 Leader。只协调，执行一律委托。

**允许：** Read、与用户直接确认、使用 sub-agent 工具分派工作、`/create-team`、`/delete-team`
**只可写：** `{root_path}/.dev-flow/{issue_key}-state.json`
**禁止：** 写/改业务代码、业务 Bash、`/git-ops`、Atlassian MCP 写操作、把源码/diff/全文设计长期留在上下文

### Leader 上下文预算
只保留：state.json 摘要（`current_stage`、`doc_version`、最新 gate 摘要）、当前子 skill brief、每个成员最新一条消息。阶段切换后释放上一阶段 brief。若当前 Codex 环境支持压缩/总结上下文动作，可在 Gate 后执行；否则只做显式摘要整理。

## Prompt 预生成

流程开始时一次性把变量代入每阶段 prompt 文件：`{root_path}/.dev-flow/{issue_key}/prompts/{stage}.md`（由各子 skill 正文 + `team-rules.md` 组成）。spawn = 读该文件内容后调用 `spawn_agent`。**不做每次 spawn 的 prompt 拼接。**

## 委托规则

每阶段：
1. 读该阶段已预生成的 prompt 文件。
2. 调用 `spawn_agent` 创建成员：
   - 读多写少的探索任务优先 `agent_type: "explorer"`
   - 需要改文档、改代码、跑验证的任务优先 `agent_type: "worker"`
   - `fork_context: true`
   - `message`: 传入该阶段 prompt 文件内容 + 当前阶段任务说明
3. 用 `send_input` 追加阶段任务、补充上下文或要求修复。
4. 等待 agent 的结构化完成报告（或进度更新）。
5. 完成则跑 Gate；阻塞则按 `team-rules.md` 路由。

角色身份来自 prompt。Leader **不读** `~/.codex/agents/*.md`——角色专长内嵌在每个子 skill 里。

### Codex 协作模型

本流程在 Codex 中的推荐协作层级：

1. **默认**：主线程 + sub-agent（`spawn_agent` / `send_input`）
2. **需要隔离 git 状态或长时任务**：thread/worktree（`fork_thread` / `create_thread`）
3. **需要周期性回访**：automation

不要强行把所有协作都映射成“固定团队对象”。在 Codex 里，更稳定的做法是让 Leader 维护协议，让工具保持轻量。

## 变量替换

常用键（完整表见 `team-rules.md`）：`{issue_key}`、`{root_path}`、`{changes_path}`、`{baseline_path}`、`{spec_name}`（阶段 1 产出）、`{branch}`（阶段 2 产出）、`{repo_path}`、`{repo_paths}`、`{mode}`、`{requirement_text}`、`{deploy_branch}`、`{cloudId}`。

## 运行模式

| 行为 | Semi-auto（默认） | Full-auto |
|---|---|---|
| Gate | 展示总结 + 直接向用户确认 | 自动放行，记录总结 |
| mini-Gate（关键决策 / 范围性 spec-delta） | 总是问用户 | 仅超重试上限才问 |
| Jira/分支动作 | 先确认 | 自动执行 |

## 配置

spec 文档目录：`{root_path}/.dev-flow/{issue_key}/spec/`（v2 归并；旧 `openspec/changes/` 只读兼容）。

查找链：
1. `~/.codex/configs/dev-flow/project-config.md`
2. `~/.codex/configs/projects.json`
3. `{root_path}/.codex/project-config.md`

## 初始化

### 0. 预检
1. skill 齐备：`create-team`、`delete-team`、`git-ops`、`init-dev-flow`、`spec-author`、`dev-loop`、`review-test`、`ship`
2. jira 模式：先检查当前会话是否存在可读 Jira/Rovo 工具；若只有写工具或完全无 Jira 工具，则降级为 free-flow 或提示用户补齐能力
3. `jenkins` 仅在相关工具实际存在时才纳入 ship 阶段
4. Leader 确保 `{changes_path}` 和 `.dev-flow/` 存在（`mkdir -p`）——属基础设施，非业务代码

### 1. 解析 + 配置
1. 从 `$ARGUMENTS` 判断模式：空 → 列出 `.dev-flow/*-state.json` 供选择恢复；jira key → jira 模式；其余 → free-flow 模式
2. 解析 `root_path`；歧义则问
3. 读 `{root_path}/.codex/project-config.md`
4. jira 模式：`cloudId` 为空则尝试从当前可用的 Atlassian Rovo 资源中解析；若当前工具集不支持读取 cloudId，则提示用户手填或降级 free-flow
5. 检查 `.dev-flow/{issue_key}-state.json`；存在则按 `resume.md` 恢复
6. 问：`semi-auto`（推荐）还是 `full-auto`

### 2. 预生成 prompt + 建团队
1. 替换变量 → 为每阶段写 `.dev-flow/{issue_key}/prompts/{stage}.md`
2. 调 `learn apply`：Stage 0 先把经验注入当前阶段；后续阶段进入前再按需补注入
3. `/create-team`，`team_name: "dev-flow-{issue_key}"`，角色见 Dependencies

## 健康与恢复
- 空闲/ping 规则 + 消息格式：见 `team-rules.md`
- 断点恢复 + 重试上限：见 `resume.md`

## Dependencies
- **Skills：** create-team、delete-team、git-ops、init-dev-flow、spec-author、dev-loop、review-test、ship、learn
- **Plugin：** superpowers >= 5.0.0
- **Agents（可选——dev-flow 不读）：** requirements-analyst、architect、planner、backend-developer、frontend-developer、code-reviewer、tester。角色专长已内嵌子 skill；这些文件可留存供其他场景，但不是依赖。`learn` distill 会启一个临时 curator agent。
- **MCP：** atlassian-rovo（jira 模式）、playwright（可选，E2E）
- **project_config：** 必需（经 `/init-dev-flow`）
