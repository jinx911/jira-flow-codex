# Gate 机制

每个 Stage 结束，Leader 执行一次 Gate 检查：

1. **收集** —— 汇总本阶段所有 agent 报告。
2. **质量检查** —— 按下方标准评估交付物。
3. **持久化** —— 写入 `{root_path}/.dev-flow/{issue_key}-state.json`：
   - `stage_results[current_stage]` = Gate 摘要文本
   - `current_stage` = 下一阶段号
   - `updated_at` = 当前 ISO 时间
4. **呈现** —— 展示结构化总结（见下方格式）。
5. **确认（semi-auto）** —— 用户确认 → 推进；用户要求修改 → 转交相关 agent，重跑 Gate；用户中止 → `/delete-team`，流程结束。
6. **自动放行（full-auto）** —— 质量检查 + 持久化后，记录总结并推进；如环境支持上下文压缩则可额外执行；质量不足时升级到用户。

## Gate 通过标准

| Gate | 必须满足 | 不满足时 |
|---|---|---|
| Gate 1 | proposal.md + design.md：核心章节齐 + 所有触发到的工程章节齐 + 无 TBD/TODO 占位符 + 每条验收标准有测试策略条目 +（复杂）架构决策非空 + **关键设计决策已用户确认（见下"Gate 1 关键决策对齐"）** | requirements-analyst/architect 修改后重过 |
| Gate 2 | 当前任务清单已清空 + `tdd`/`regression`/`smoke` 标签单元测试绿（**须带原始证据，见下"Gate 2 测试证据"**） + 每个 `spec-delta` 已确认（范围性）或已记录（澄清性） | 未完成任务继续；阻塞按异常处理 |
| Gate 3 | 无 CRITICAL 问题 + 无未解决 HIGH 问题 + 所有测试通过 + 无未修 bug | dev 修复；code-reviewer/tester 复评（最多 3 轮，再升级） |
| Gate 4 | 分支已推送 + deploy_branch 已合并（若配置）+ Jenkins 成功/跳过（若配置）+ Jira 已更新（jira 模式） | dev 补齐缺失步骤 |

## Gate 1 关键决策对齐（防 Stage 2 返工）

Gate 1 只查"文档完整性"不够。文档里写错方案也能过，等 Stage 2/3 才暴露，返工最贵。补救：Leader 在过 Gate 1 前，从 design.md **抽取 3-5 条关键设计决策**做一次 mini-Gate，让用户 explicit confirm。

**抽取原则**：

- 数据流 / 写入路径 / 同步时机
- 报错与边界策略
- 架构约束
- 跨模块 / 跨租户边界
- 表结构 / 接口契约的不可逆改动

**流程**（semi-auto 必做，full-auto 跳过但记入 `user_decisions`）：

1. Leader Read design.md，按上列原则挑 3-5 条决策
2. 向用户逐条确认
3. 用户确认 → 写入 `state.json.user_decisions`；否决 → spec-author 据此改 design.md 重过 Gate 1
4. 通过后才推进 Stage 2

## Gate 2 测试证据（防 agent 谎报测试）

Gate 2 不接受口头 pass。

**Completion Report 的 Test Result 字段强制三项**（缺一退回）：

1. **命令**：实际执行的单测命令（含过滤范围）
2. **计数**：`Tests: X passed, Y failed, Z skipped`（来自原始输出）
3. **失败列表**：失败测试的类名 + 用例名（无失败写 `None`）

**Leader 侧**：

- `Y > 0` → 不准过 Gate 2，让 agent 先修或证明失败与本需求无关
- 抽查：若计数异常大或可疑，Read agent 引用的日志文件复核
- 禁止仅 `pass` / `N/A` / "全绿" 这类无证据措辞

## Gate 摘要格式

```
Stage N: <阶段名>
Deliverables: <文件路径列表>
Key decisions: <1-3 条>
Risks: <如有——描述 + 影响 + 缓解>
Quality: Pass / Fail（列出未过项）
Next Stage: <名> | Effort: <轻/中/重> | User interaction: <无 / 仅 checkpoint / 频繁>
Next Stage will spawn: <新 agent 列表（如有）>
```

## 风险示例

- "design.md 涉及新表，需 DBA 评审 → 影响发布节奏，建议尽早沟通。"
- "方案 B 性能更好但改动面更大 → 影响回归测试范围，建议增加测试时间。"
- "需求里字段 X 含义未确认 → 可能返工，建议 Gate 前确认。"
