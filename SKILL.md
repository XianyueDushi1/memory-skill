---
name: memory
description: Use when working on complex multi-step research projects that need persistent memory. Triggers when user mentions "记忆", "memory", "硬同步", "复活", "初始化记忆", starts a long research task, or when memory/OVERVIEW.md exists in the project.
user-invocable: true
allowed-tools: "Read Write Edit Bash Glob Grep"
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 检测到项目记忆系统。请立即读取 memory/OVERVIEW.md，根据索引按需读取相关记忆文件，重建项目认知。然后执行「五问重启测试」自检。'; fi"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 你刚创建/修改了文件。请检查：(1) 是否需要更新对应层级的 file_map.md；(2) 是否已达到 3 次对话的记忆更新节点。'; fi"
  Stop:
    - hooks:
        - type: command
          command: "if [ -f memory/OVERVIEW.md ]; then SCRIPT=$(find ~/.claude/skills/memory/scripts -name check-memory.sh 2>/dev/null | head -1); if [ -n \"$SCRIPT\" ]; then bash \"$SCRIPT\"; else echo '[memory] 请确认本次会话是否有未记录的重要进展。'; fi; fi"
---

# 大型研究项目 Agent 记忆管理协议 (V4.0) - 多文件递归架构版

本协议将 Agent 的记忆从单文件升级为多文件、多层文件夹的递归架构。
核心目标：即使系统记忆全部消失，新模型读取 memory/ 文件夹后也能对项目了如指掌，不需要重新踩坑迭代走弯路。

## 第一步：检查或初始化

**每次对话开始时**，检查记忆系统是否存在：

1. 如果 `memory/OVERVIEW.md` 存在 → 立即读取，根据索引按需读取相关记忆文件，重建项目认知。读取后执行「五问重启测试」自检。
2. 如果不存在 → 询问用户是否需要初始化记忆系统：

```bash
# Linux/macOS
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-session.sh"
```

```powershell
# Windows PowerShell
& "$env:CLAUDE_PLUGIN_ROOT\scripts\init-session.ps1"
```

初始化后，引导用户填写 core/background.md 和 core/current_thinking.md。

---

## 第一部分：核心系统提示词 (System Prompt)

请将以下内容作为 Agent 的核心行为准则：

【指令启动：全维度项目记忆守护者】
你现在是该研究项目的首席知识官。为了确保项目连续性，你必须遵循以下记忆捕获规则：

1. 全量信息捕获 (Omni-Capture):
   - 直接信息：记录用户给出的所有显式指令、背景资料和偏好。
   - 间接/隐含信息：记录在任务执行过程中自动获取的信息。包括但不限于：
     * 代码执行结果（如：某个库的版本号、数据集的维度/缺失值情况）。
     * 调试过程中的发现（如：报错原因的深度分析、环境兼容性问题）。
     * 逻辑推导的中间产物（如：发现某个算法在当前场景下效率极低）。
   - 全量是指全部信息：解决了什么任务、解决办法和流程是什么、踩了哪些坑、生成了什么文件和脚本、最终踩坑迭代后确定的方法管道是什么。

2. 路径与决策全景图 (Research Path & Decisions Panorama):
   - 当前项目的整体思路概况：记录项目的总体研究方向、核心方法论和阶段性目标，确保 Agent 始终对"大图景"有清晰认知。
   - 记录"尝试过但失败"的路径：报错信息、弃用原因、踩过的坑（防止重复犯错）。
   - 记录"决策逻辑"：记录为什么选择当前方案，而非其他备选方案。

3. 项目架构全景图 (Project Architecture):
   - 维护文件地图（file_map.md）：由大到小，每个文件夹和文件都要有介绍摘要。
   - 文件地图每条记录必须包含：（1）文件/文件夹自身的内容和功能；（2）是在实现什么思路下产生的，紧密联系思路历史。
   - 每生成一个新文件，立即在对应层级的 file_map.md 追加一条说明。
   - 记录文件间的依赖与调用流向，确保即使上下文重置也能迅速理清全局。

4. 术语、约束与"为什么不"清单:
   - 统一术语：记录项目中定义的特定名词。
   - 负向清单：记录被讨论过但被否决的提议（Why Not List），防止未来再次提出已排除的方案。

---

## 第二部分：记忆文件夹架构

Agent 必须在项目中维护 memory/ 文件夹，作为项目的"灵魂备份"。

顶层结构：

```
memory/
├── OVERVIEW.md                          ← 每次对话自动加载
│
├── core/                                ← 项目核心思路
│   ├── background.md                    ← 项目背景（专业领域、毕设/论文、术语、环境约束）
│   ├── current_thinking.md              ← 当下思路（只保留当前版本，不含历史）
│   └── thinking_history.md              ← 思路演变历史（关键转折、Why Not）
│
└── implementation/                      ← 实现层面
    ├── file_map.md                      ← 项目级文件地图
    ├── [任务A]/                          ← 具体任务（递归结构）
    ├── [任务B]/
    └── ...
```

递归任务结构（最深 4 层）：

每个任务是一个"小项目"，完整复制项目结构——拥有自己的 core/（背景、当下思路、思路历史）和 implementation/（文件地图、子任务）。

```
[任务名]/
├── core/
│   ├── background.md
│   ├── current_thinking.md
│   └── thinking_history.md
└── implementation/
    ├── file_map.md
    ├── [子任务A]/                        ← 递归下一层
    └── [子任务B]/
```

递归层级示例：

```
implementation/
└── 论文撰写/                            ← 第 1 层任务
    ├── core/ ...
    └── implementation/
        ├── file_map.md
        └── 实验设计/                     ← 第 2 层子任务
            ├── core/ ...
            └── implementation/
                ├── file_map.md
                └── 对比实验A/            ← 第 3 层子子任务
                    ├── core/ ...
                    └── implementation/
                        └── 消融实验/     ← 第 4 层（最深）
                            ├── core/ ...
                            └── implementation/
```

Agent 的自由度：
- Agent 可以在 core/ + implementation/ 框架内自由创建新的任务文件夹和记忆文件。
- 但必须先询问用户，说明要创建什么、用途是什么，用户确认后才能创建。
- 创建后立即更新对应层级的 file_map.md 和 OVERVIEW.md 索引。

---

## 第三部分：OVERVIEW.md 规范

OVERVIEW.md 是每次新对话自动加载到上下文的全景文件。新模型读完它就能获得项目全貌和索引导航。

内容结构：

```
# 项目全景 [项目名称]
## 最后更新: YYYY-MM-DD

## 项目核心思路及其演变历史
[项目最终目标]
[当前核心方法论和思路]
[思路演变过程：关键转折点、为什么放弃了哪些路线、如何走到现在]

## 记忆索引
| 文件/文件夹 | 摘要（站在核心思路角度写） |
|------------|------------------------|
| core/background.md | [...] |
| core/current_thinking.md | [...] |
| core/thinking_history.md | [...] |
| implementation/file_map.md | [...] |
| implementation/[任务A]/ | [...] |
| ... | ... |
```

关键要求：
- OVERVIEW 的"核心思路及演变历史"与 core/ 文件夹内容允许重叠。OVERVIEW 是自包含的全景快照，core/ 保存完整细节。
- 索引摘要站在核心思路角度写——这个文件是核心思路的哪个部分、为什么存在、在整体中扮演什么角色。
- 控制长度在合理 token 范围内。

---

## 第四部分：文件地图 (file_map.md) 规范

每一层都有自己的 file_map.md，记录该层级下所有文件和文件夹。

每条记录包含两部分：
1. 内容与功能：文件/文件夹自身是什么、做什么。
2. 思路关联：是在实现什么思路下产生的，紧密联系思路历史。用自然语言描述。

示例：

```
### /data/raw/
- 内容与功能：存放未经处理的原始实验数据，包括 CSV 和 JSON 格式。
- 思路关联：在"数据驱动建模"思路（第二版思路）下建立，之前"规则驱动"思路时不需要原始数据存储。

### /scripts/clean_data.py
- 内容与功能：数据清洗脚本，处理缺失值、异常值和格式统一。
- 思路关联：在"数据清洗"子任务中开发，清洗策略经过 3 次迭代，最终确定用中位数填充（详见 implementation/数据清洗/core/thinking_history.md）。
```

动态维护：每生成新文件立即追加，文件删除或重命名时同步更新。

---

## 第五部分：记忆更新机制

更新触发条件（任意一个命中即触发）：
- 每 3 次对话
- 重大进展（完成子任务、关键决策、重要踩坑）

更新流程：
① Agent 暂停当前任务
② 向用户详细汇报：最近有什么进展、准备记忆什么内容、准备写入哪些文件
③ 用户审阅，共同调整内容和目标文件
④ 确认后，Agent 直接写入对应的记忆文件
⑤ 同步更新 file_map.md 和 OVERVIEW.md 索引
⑥ 恢复当前任务

备注：当前"每次都需用户确认"是试验阶段做法，确认 Agent 记忆质量后，后续版本可逐步放权。

---

## 第六部分：关键操作工作流

1. 强制"硬同步"指令：
   当你感觉到对话过长或完成了一个重大任务时，请发送：
   "执行'硬同步'：请复盘本次对话及任务执行全过程。提取所有直接指令和间接发现（特别是报错经验和数据观察），向我汇报准备记忆的内容和目标文件，经我确认后写入对应记忆文件。确保信息描述是原子的，不依赖上下文代词。同步更新 file_map.md 和 OVERVIEW.md。"

2. "无损复活"指令：
   开启新 Session 或 Agent 表现出遗忘时，发送：
   "读取 memory/OVERVIEW.md，根据索引按需读取相关记忆文件，在当前上下文中重建项目认知。"

   复活后，Agent 必须通过「五问重启测试」自检，确保认知恢复完整：
   | 问题 | 答案来源 |
   |------|---------|
   | 我在哪里？（当前任务进度） | OVERVIEW.md |
   | 我要去哪里？（后续步骤） | 当前任务的 core/current_thinking.md |
   | 目标是什么？（项目整体思路） | OVERVIEW.md → 项目核心思路 |
   | 我学到了什么？（踩坑和决策经验） | core/thinking_history.md |
   | 我做了什么？（已完成的工作） | implementation/file_map.md |
   如果任何一问无法回答，说明记忆文件信息不完整，Agent 应主动提示用户补充。

3. 增量更新要求：
   严禁简单覆盖！旧的失败尝试和历史思路应保留在 thinking_history.md 中作为参考。只有 current_thinking.md 保留当前版本（覆盖更新）。

---

## 第七部分：自动加载机制（由 Hook 实现）

本 skill 通过三个 Hook 自动化记忆管理：

| Hook | 触发时机 | 效果 |
|------|---------|------|
| UserPromptSubmit | 用户每次发消息 | 检测 memory/OVERVIEW.md 是否存在，提醒 Agent 读取恢复认知 |
| PostToolUse (Write/Edit) | Agent 每次创建/编辑文件 | 提醒检查 file_map.md 是否需更新，检查是否到记忆更新节点 |
| Stop | 会话即将结束 | 检查记忆是否有未保存的进展，必要时提醒执行硬同步 |

## 模板

初始化时使用以下模板创建 memory/ 结构：

- [templates/OVERVIEW.md](templates/OVERVIEW.md) — 全景文件模板
- [templates/background.md](templates/background.md) — 项目背景模板
- [templates/current_thinking.md](templates/current_thinking.md) — 当下思路模板
- [templates/thinking_history.md](templates/thinking_history.md) — 思路演变历史模板
- [templates/file_map.md](templates/file_map.md) — 文件地图模板
