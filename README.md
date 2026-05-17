# Memory Skill for Claude Code

A Claude Code skill that gives AI agents persistent, structured memory across conversations.

Even if the agent's context is completely reset, reading the `memory/` folder restores full project awareness — no re-exploration, no repeated mistakes.

## What It Does

- **Auto-loads project context** — Every new conversation automatically detects and reads the memory system
- **Structured memory architecture** — Separates thinking (core/) from implementation (implementation/), with recursive task nesting up to 4 levels deep
- **File map tied to thinking history** — Every file entry records not just what it is, but why it was created and under which design decision
- **Automatic reminders** — Hooks remind the agent to update memory after file changes and before session ends
- **Five-question restart test** — Self-check ensures complete cognitive recovery after context reset

## Installation

Copy the `memory/` folder to your Claude Code skills directory:

```bash
# Linux / macOS
cp -r memory ~/.claude/skills/memory

# Windows (PowerShell)
Copy-Item -Recurse memory $env:USERPROFILE\.claude\skills\memory
```

## Usage

### Initialize memory system

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

### Key commands

| Command | Effect |
|---------|--------|
| `硬同步` / `hard sync` | Agent reviews all progress and writes to memory files |
| `复活` / `resurrect` | Read memory files and restore full project awareness |
| `/memory` | Invoke the skill directly |

### Automatic hooks

Once initialized, three hooks fire automatically (no manual action needed):

| Hook | When | What |
|------|------|------|
| UserPromptSubmit | Every message | Reminds agent to read OVERVIEW.md |
| PostToolUse | After Write/Edit | Reminds agent to update file_map.md |
| Stop | Session ending | Checks for unsaved progress |

## Memory Architecture

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
