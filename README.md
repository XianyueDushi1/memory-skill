# Memory Skill for Claude Code

​　　我们在使用agent进行大型项目工作时，往往会因为上下文窗口有限，导致信息丢失。（比如做毕设，之前完善好格式的论文生成pipeline，由于未记忆，agent已经不明白之前的脚本的功能与含义，而需要重新探索；比如模型思路某方向已经踩坑确定不再尝试，却因为agent失去记忆而重复提出）  
​　　对于此问题，此项目的解决思路是：模仿人类记忆方式，将上下文精炼，结构化存储于memory/下的md文件。  

功能亮点：  
　　（1） 嵌套记忆结构：以项目核心思路为中心（其包含1当前思路2思路变化历史3文件地图），具体实现的任务为其延展（每个任务如同一个项目，其下含结构与前相同），以此嵌套重复，无限把握细节。  
　　（2） 项目全景地图：此即对应前文文件地图，该层级的每个文件/文件夹都会生成摘要，摘要不仅记录总结其内容和功能，还记录其创建原因以及所依据的设计决策，紧密联系核心思路。  
　　（3） 每次对话会调用overview.md：使得agent始终具有全景视角，不会偏离核心思路。  

　　//已有的前人的解决办法：（1）上下文全部记忆进硬盘。优点是记忆全面，缺点在于缺乏清晰结构，调用时会大量消耗token。  

　　使用前请阅读SKILL.md，了解功能与内容。




## 安装

Copy the `memory/` folder to your Claude Code skills directory:

```bash
# Linux / macOS
cp -r memory ~/.claude/skills/memory

# Windows (PowerShell)
Copy-Item -Recurse memory $env:USERPROFILE\.claude\skills\memory
```

## 使用

### 初始化

In your project directory, run:

```
/memory
```

Or say "初始化记忆" in conversation. This creates:

```
your-project/
├── .claude/settings.json    ← hooks (auto-injected)
└── memory/
    ├── OVERVIEW.md           ← auto-loaded every conversation
    ├── core/
    │   ├── background.md
    │   ├── current_thinking.md
    │   └── thinking_history.md
    └── implementation/
        └── file_map.md
```

### 核心命令

| Command | Effect |
|---------|--------|
| `硬同步` / `hard sync` | agent会检查所有进度并写入memory/文件 |
| `复活` / `resurrect` | 读取memory并恢复完整的项目感知，当开启新对话或上下文重置时可使用 |
| `/memory` | 直接调用该skill |

### 自动钩子

Once initialized, three hooks fire automatically (no manual action needed):

| Hook | When | What |
|------|------|------|
| UserPromptSubmit | Every message | Reminds agent to read OVERVIEW.md |
| PostToolUse | After Write/Edit | Reminds agent to update file_map.md |
| Stop | Session ending | Checks for unsaved progress |

## 记忆结构

```
memory/
├── OVERVIEW.md                    ← Project panorama + index (auto-loaded)
├── core/                          ← Thinking layer
│   ├── background.md              ← Project background, terms, constraints
│   ├── current_thinking.md        ← Current approach (overwrite-updated)
│   └── thinking_history.md        ← Evolution history + Why Not list (append-only)
└── implementation/                ← Implementation layer
    ├── file_map.md                ← File map with thinking associations
    └── [task-name]/               ← Recursive task (max 4 levels)
        ├── core/
        └── implementation/
```

## Requirements

- Claude Code CLI or IDE extension

## License

MIT
