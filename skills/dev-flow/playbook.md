# Dev-Flow Playbook

> 全局通用经验缓冲层。由 `learn distill` 自动追加，人工只做审阅与删重，不在这里写项目私有约定。

## 必触发章节

- 涉及 migration / 新表 / 新字段时，设计里必须显式写数据模型与回滚影响。 > source: bootstrap @ 2026-08-11T00:00:00Z, signal: win
- 涉及外部接口或前后端联调时，设计里必须写清接口契约、错误语义和兼容策略。 > source: bootstrap @ 2026-08-11T00:00:00Z, signal: win

## 常见坑

- 只做 Gate 完整性校验、不确认关键设计决策，往往会把返工推迟到 Stage 2。 > source: bootstrap @ 2026-08-11T00:00:00Z, signal: gate_fail
- 仅口头汇报测试通过而不附命令、计数和失败列表，容易掩盖未跑全或既有失败未识别的问题。 > source: bootstrap @ 2026-08-11T00:00:00Z, signal: gate_fail

## 复用点

- 长任务优先拆成 ≤8 个单元一轮，轮间只持久化摘要与待办，避免 Leader 上下文失控。 > source: bootstrap @ 2026-08-11T00:00:00Z, signal: win

## 项目约定

- 只有结构化经验进入 playbook，项目私有经验沉淀到 `{root_path}/.dev-flow/knowledge.md`。 > source: bootstrap @ 2026-08-11T00:00:00Z, signal: win
