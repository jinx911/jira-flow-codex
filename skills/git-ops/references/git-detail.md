# Git Ops 流程细节（操作步骤 + 分支保护）

SKILL.md 放触发词/架构检测/全局规则，本文件放各操作的详细步骤。执行对应操作时 Read 本节。

## 分支保护规则

### 保护分支（禁止直接 commit）

| 分支 | 角色 | 规则 |
|------|------|------|
| `master` | 源头分支 | 禁止直接 commit；所有开发分支必须从 master 创建 |
| `test` | 测试分支 | 禁止直接 commit；禁止将 test 合并到其他分支 |
| `pre` | 预发分支 | 禁止直接 commit；合并前须先同步 master 到开发分支 |

### 合并方向白名单

| 方向 | 说明 | 是否需要确认 |
|------|------|-------------|
| `dev → test` | 开发合并到测试 | 正常确认 |
| `dev → pre` | 开发合并到预发 | 正常确认（须先同步 master） |
| `dev → master` | 开发合并到主分支 | 二次确认 |
| `master → dev` | 同步主分支到开发 | 正常确认 |
| `test → *` | **禁止** | **拦截并警告** |
| `pre → *` | **禁止** | **拦截并警告** |
| 其他方向 | 需二次确认 | 二次确认 |

### 检测逻辑

每次写操作前：
1. 当前分支是否保护分支 → 是则阻止并提示。
2. 合并方向是否在白名单 → 不在则警告并二次确认。
3. 涉及 `pre` 合并 → 自动先同步 master。

## Stash 兜底

所有写操作前，检测到未提交变更：
```
git status --short → 有变更 → git stash --include-untracked → 执行操作 → git stash pop
```
stash pop 冲突 → 停止，提示用户手动处理。
注意：stash 只作用于执行命令时所在的工作树；主仓与各 worktree 的未提交变更互不可见，各自独立兜底。

## Worktree 规则（占用检测 + 生命周期）

### 源头规则：公共分支永不建 worktree

- worktree 只允许挂开发分支（`feat/*`、`fix/*` 等）；`test` / `pre` / `master` / `deploy_branch` 永不创建。
- 查看公共分支代码一律只读，不 checkout：
  ```
  git -C <path> fetch origin
  git -C <path> log origin/test --oneline -20
  git -C <path> diff <dev>...origin/test
  ```
- 检测到公共分支已被 worktree 占用 → 标记「🔴 违规残留」，引导进「清理 worktree」流程。

### 占用检测（所有写操作前置）

每个仓库写操作前收集分支占用表：

```
git -C <path> worktree list --porcelain
```

porcelain 输出按 worktree 分块（`worktree <路径>` / `branch refs/heads/<分支>` / `detached`），解析成 `{分支 → worktree 路径}`，跳过主仓自身。条目还可能带 `locked`（锁定，prune 不清理）或 `prunable`（目录已不存在，可修剪）属性，解析时一并记录。

快速判断单个分支是否被占用：`git -C <path> branch --list <branch>`，输出前缀 `+` 即被其他 worktree 占用。

撞车处理（一律停车，报出「分支 X 在 worktree Y」，人工决策）：

| 操作 | 撞车场景 | 处理 |
|------|---------|------|
| 合并 | 目标公共分支被占用 | 违规残留：报位置，引导清理后再合并 |
| 创建/切换分支 | 目标分支被占用 | 停车：去该 worktree 里干，或先移走 worktree |
| 清理分支 | 要删的分支被占用 | 停车：先 `worktree remove` 再删分支 |

注意：merge 的**源分支**被占用不影响——merge 不需要 checkout 源分支，分支存在即可。

### 创建 worktree

1. 解析目标：仓库（multi-repo 先让用户选）+ 开发分支名。分支为公共分支（test/pre/master/deploy_branch）→ **拒绝**，给出只读替代命令（见源头规则）。
2. 分支不存在 → 先 `fetch origin`，从 `origin/{main_branch}` 建分支再挂；已存在 → 直接挂。
3. 路径统一：`<root_path>/.worktrees/<仓库名>-<分支名>`（分支名中 `/` 替换为 `-`）；single-repo 时 `<root_path>` 即仓库本身，改用仓库外路径 `<root_path>/../.worktrees/<仓库名>-<分支名>`，并把 `.worktrees/` 写入 `.git/info/exclude`，防止 `git add -A` 把它以 gitlink 提交。
4. 展示清单（仓库、分支、worktree 路径、是否写入 `.git/info/exclude`），用户确认后执行：
   ```
   git -C <repo> worktree add <worktree路径> <分支>
   ```
   `<worktree路径>` 必须用绝对路径（`git -C` 下相对路径按仓库目录解析）。
5. 同名 worktree 目录已存在 → 提示，不覆盖。

### worktree 状态

遍历仓库清单，每个仓库 `worktree list --porcelain`，逐条输出：

```
📋 Worktree 状态 — {仓库名}
  {路径}  分支: {branch}  未推送: {n}  最后活动: {date}  {标记}
```

- porcelain 条目带 `prunable`（目录已被手动删除）→ 标记「目录已不存在」，跳过进入该目录的命令，改从主仓取数：`git -C <repo> log -1 --format=%cs <分支>`，未推送同样记 `—`
- 未推送提交数：先 `git -C <worktree路径> rev-parse --abbrev-ref @{u} 2>/dev/null`，输出为空记 `—`；有上游再 `git -C <worktree路径> rev-list --count @{u}..HEAD`
- 最后活动：`git -C <worktree路径> log -1 --format=%cs`
- 合入判断：先 `git -C <repo> fetch origin`，再跑两条：`git -C <repo> branch --merged {main_branch} --list <分支>`、`git -C <repo> branch --merged origin/{deploy_branch} --list <分支>`；任一输出非空 → 已合入；均为空 → 未合入；未配置 `deploy_branch` 时第二条改用 `origin/test`
- 标记规则见「清理 worktree」分级表

### 清理 worktree（必须核对，绝不自动删）

**分级标记**：

| 标记 | 条件 | 含义 |
|------|------|------|
| ✅ | 分支已合入 {main_branch}/{deploy_branch} | 可删 |
| ⚠️ | 分支未合入 + 最后活动超 14 天 | 需确认 |
| 🚫 | 分支未合入 + 14 天内活跃 | 不建议 |
| 🔴 | 挂公共分支（违规残留） | 应删（还原主仓操作能力） |

**核对流程（硬性，任何删除不得先于核对）**：

1. 列出全部 worktree 分级清单（路径、分支、未推送、最后活动、标记）。
2. **等用户勾选**（逐项或批量）；未勾选前不执行任何删除。
3. 逐个执行 `git -C <repo> worktree remove <路径>`；worktree 内有未提交改动 → 默认不删，用户明确要求时 `--force` 须二次确认。目录已不存在的 prunable 条目，`worktree remove <路径>` 会自动修剪；也可经确认后 `git -C <repo> worktree prune` 批量清。
4. 删除后联动询问是否删对应分支：已合并 `branch -d`；未合并 `branch -D` 须二次确认；保护分支（`master`/`test`/`pre`/`deploy_branch`）不询问删分支，仅删 worktree；detached HEAD 无分支可删，仅删 worktree。
5. 按仓库汇报：已删 / 跳过 / 被拦（含原因）。

## 仓库归一化规则

从 project-config 收集仓库时，按下面顺序归一化：

1. `backend.main_repo`
2. `modules[].path`
3. `frontend.repo_path`
4. `java.gateway_repo`
5. `go_services[]`

规则：

- 路径统一转成相对 `root_path` 的 repo 路径
- 重复路径去重
- repo 名优先级：`modules[].name` > 明确配置键名（frontend/gateway/service）> 目录名
- 若最终只有 1 个有效仓库，退化为 single-repo
- 若某配置字段存在但路径不存在，标记为 warning，继续处理其它仓库
- commit 自动扫描时，仅纳入 `git rev-parse --is-inside-work-tree` 成功的路径

## 各操作流程

### 创建分支
1. 解析分支名：`$ARGUMENTS` 提供→用之；否则按 `git.branch_naming.format` 生成（交互确认）。
2. 若存在 issue key 且配置了 `type_map`，先推断 type（Bug→fix，Story/Task→feat，其它按用户输入或默认 `feat`）。
3. 生成后展示最终结果：`{branch}`，用户确认再执行。
4. multi-repo：列出仓库让用户选。
5. 每个选中仓库：`fetch origin` → 占用检测（见 §Worktree 规则，撞车停车）→ stash（如有）→ `checkout {main_branch}` → `pull` → `checkout -b {branch}` → stash pop。
6. 同名分支已存在 → 提示是否切换；若该分支被其他 worktree 占用 → 报出 worktree 路径停车，不 checkout。

### 更新分支
1. 检测活跃分支（multi-repo 各仓库 / single-repo 当前）。
2. 询问策略：merge（默认，安全）/ rebase（线性历史，已推送慎用）。
3. `git -C <path> fetch origin` → 按策略执行。
4. 冲突立即停止，列冲突文件让用户手动处理。
目标分支被 worktree 占用 → 不在主仓切换，去对应 worktree 内执行更新。

### 提交代码
1. 扫描变更：遍历各仓库**主仓与该仓所有 worktree** 的 `git -C <path> status --short` + `diff --stat`（指定模块只扫匹配仓库）；改动在哪个工作树就在哪 commit，各工作树独立成 commit。
2. 自动过滤无变更仓库；若全部无变更，直接返回"无可提交内容"。
3. 结合上游上下文决定提交口径：
   - ship：一个需求一个大 commit
   - bugfix-flow：一个 bug 一个 commit
   - 独立调用：按本次展示清单提交
4. 展示变更清单（**等用户确认**），每个文件附一句话描述（diff 分析得出）：
   ```
   📋 变更清单 — {仓库名}
   新增: + path/to/new.php — 新增XXX
   修改: ~ path/to/mod.php — 修改YYY
   删除: - path/to/old.php — 移除ZZZ
   Commit Message: feat(scope): description
   ```
5. 默认 `git add <具体文件>` + `git commit`。
6. 仅在 ship 明确要求"把本需求全部改动一次收口"时，可使用 `git add -A`，但必须先展示完整清单并获得确认。清单中不得含 `.worktrees/` 目录。

### 推送远程
1. 检测各仓库主仓与各 worktree 的当前分支 + 未推送提交数（无上游记 `—`，检测方法同「worktree 状态」）。
2. 展示推送清单（**等用户确认**）：
   ```
   📋 推送清单
   [1] oa-platform   branch: feature/OA-123   commits: 3 (↑待推送)
   ```
3. 无上游 → `git push -u origin {branch}`；有上游 → `git push`。

### 合并分支（按目标分流）
- **前置占用检测**：目标分支被 worktree 占用（公共分支被占属违规残留）→ 停车报位置，引导「清理 worktree」后再合并。源分支被占用不影响 merge。
- **→ test（常规）**：选仓库+开发分支 → 清单确认 → `checkout test → pull → merge {branch}` → 询问是否推 test。
- **→ pre（须先同步 master）**：开发分支先 `merge origin/master`（冲突停止）→ 清单确认（标"已同步 master"）→ `checkout pre → pull → merge {dev}` → 询问是否推 pre。
- **→ master（二次确认）**：清单 + 输入 "yes" 确认 → 执行。
- **→ deploy_branch（通用）**：若 project-config 配了 `deploy_branch` 且目标正是它，按 `test/pre` 同类逻辑执行，并在清单里显式标明"这是部署分支"。
- **禁止方向**：检测 `test→*` / `pre→*` → 拦截 + 警告（"test/pre 只读，改动请在开发分支重实现"）。

### 清理分支
1. 扫描本地分支（排除保护分支），标记已合并/未合并；被 worktree 占用的分支单独标记，须先走「清理 worktree」联动 remove 后再删。
2. 用户选要删的；未合并的删除需额外确认，可选同时删远程。

## 全局规则（重申）

- 所有写操作必须用户确认，绝不擅自执行。
- 每次操作前展示清单（commit 列文件、push 列仓库+提交数、merge 列源→目标）。
- 冲突不自动解决，立即停止。
- stash 兜底（见上）。
- 分支保护：master/test/pre 禁止直接 commit；test/pre 禁止向外合并。
- 默认不 push，只在用户要求时执行。
- 无变更仓库跳过；每仓库独立操作，单个失败不影响其他。
- 用 `git -C <path>` 执行，不依赖 cd。
- 输出结果必须按仓库列出：执行了什么、跳过了什么、哪里被保护规则拦截。
