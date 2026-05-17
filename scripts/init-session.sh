#!/usr/bin/env bash
# 初始化 memory/ 文件夹结构 + 自动注入 hooks 到 .claude/settings.json
# 使用模板创建所有基础记忆文件

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"
MEMORY_DIR="memory"
CLAUDE_DIR=".claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ -f "$MEMORY_DIR/OVERVIEW.md" ]; then
    echo "[memory] 记忆系统已存在。读取 memory/OVERVIEW.md 以恢复项目认知。"
    exit 0
fi

echo "[memory] 正在初始化记忆系统..."

# 1. 创建 memory/ 文件夹结构
mkdir -p "$MEMORY_DIR/core" "$MEMORY_DIR/implementation"

cp "$TEMPLATE_DIR/OVERVIEW.md" "$MEMORY_DIR/OVERVIEW.md"
cp "$TEMPLATE_DIR/background.md" "$MEMORY_DIR/core/background.md"
cp "$TEMPLATE_DIR/current_thinking.md" "$MEMORY_DIR/core/current_thinking.md"
cp "$TEMPLATE_DIR/thinking_history.md" "$MEMORY_DIR/core/thinking_history.md"
cp "$TEMPLATE_DIR/file_map.md" "$MEMORY_DIR/implementation/file_map.md"

# 2. 注入 hooks 到 .claude/settings.json
mkdir -p "$CLAUDE_DIR"

if [ -f "$SETTINGS_FILE" ] && grep -q "UserPromptSubmit" "$SETTINGS_FILE" 2>/dev/null; then
    echo "[memory] .claude/settings.json 中已存在 hooks，跳过注入。"
else
    if [ -f "$SETTINGS_FILE" ]; then
        # 已有 settings.json 但无 hooks，用 python 合并
        python3 -c "
import json, sys
with open('$SETTINGS_FILE', 'r', encoding='utf-8') as f:
    cfg = json.load(f)
hooks = $(cat <<'HOOKS_JSON'
{
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 检测到项目记忆系统。请立即读取 memory/OVERVIEW.md，根据索引按需读取相关记忆文件，重建项目认知。然后执行「五问重启测试」自检。'; fi"}]}],
    "PostToolUse": [{"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 你刚创建/修改了文件。请检查：(1) 是否需要更新对应层级的 file_map.md；(2) 是否已达到 3 次对话的记忆更新节点。'; fi"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "if [ -f memory/OVERVIEW.md ]; then SCRIPT=\$(find ~/.claude/skills/memory/scripts -name check-memory.sh 2>/dev/null | head -1); if [ -n \"\$SCRIPT\" ]; then bash \"\$SCRIPT\"; else echo '[memory] 请确认本次会话是否有未记录的重要进展。'; fi; fi"}]}]
}
HOOKS_JSON
)
cfg['hooks'] = hooks
with open('$SETTINGS_FILE', 'w', encoding='utf-8') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
" 2>/dev/null || python -c "
import json
with open('$SETTINGS_FILE', 'r', encoding='utf-8') as f:
    cfg = json.load(f)
cfg['hooks'] = json.loads('''$(cat <<'HOOKS_JSON2'
{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"if [ -f memory/OVERVIEW.md ]; then echo '[memory] 检测到项目记忆系统。请立即读取 memory/OVERVIEW.md，根据索引按需读取相关记忆文件，重建项目认知。然后执行「五问重启测试」自检。'; fi"}]}],"PostToolUse":[{"matcher":"Write|Edit","hooks":[{"type":"command","command":"if [ -f memory/OVERVIEW.md ]; then echo '[memory] 你刚创建/修改了文件。请检查：(1) 是否需要更新对应层级的 file_map.md；(2) 是否已达到 3 次对话的记忆更新节点。'; fi"}]}],"Stop":[{"hooks":[{"type":"command","command":"if [ -f memory/OVERVIEW.md ]; then echo '[memory] 请确认本次会话是否有未记录的重要进展。'; fi"}]}]}
HOOKS_JSON2
)''')
with open('$SETTINGS_FILE', 'w', encoding='utf-8') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
"
    echo "[memory] 已将 hooks 合并到现有 .claude/settings.json。"
else
    # 无 settings.json，直接创建
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 检测到项目记忆系统。请立即读取 memory/OVERVIEW.md，根据索引按需读取相关记忆文件，重建项目认知。然后执行「五问重启测试」自检。'; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 你刚创建/修改了文件。请检查：(1) 是否需要更新对应层级的 file_map.md；(2) 是否已达到 3 次对话的记忆更新节点。'; fi"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "if [ -f memory/OVERVIEW.md ]; then SCRIPT=$(find ~/.claude/skills/memory/scripts -name check-memory.sh 2>/dev/null | head -1); if [ -n \"$SCRIPT\" ]; then bash \"$SCRIPT\"; else echo '[memory] 请确认本次会话是否有未记录的重要进展。'; fi; fi"
          }
        ]
      }
    ]
  }
}
EOF
    echo "[memory] 已创建 .claude/settings.json 并注入 hooks。"
fi
fi

echo ""
echo "[memory] 记忆系统初始化完成。"
echo "已创建："
echo "  memory/OVERVIEW.md"
echo "  memory/core/background.md"
echo "  memory/core/current_thinking.md"
echo "  memory/core/thinking_history.md"
echo "  memory/implementation/file_map.md"
echo "  .claude/settings.json (hooks)"
echo ""
echo "请引导用户填写 core/background.md 和 core/current_thinking.md。"
