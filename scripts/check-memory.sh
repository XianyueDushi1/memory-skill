#!/usr/bin/env bash
# 会话结束时检查记忆状态
# 由 Stop hook 调用

MEMORY_DIR="memory"

if [ ! -f "$MEMORY_DIR/OVERVIEW.md" ]; then
    echo "[memory] 未检测到记忆系统，无需检查。"
    exit 0
fi

OVERVIEW_TIME=$(stat -c %Y "$MEMORY_DIR/OVERVIEW.md" 2>/dev/null || stat -f %m "$MEMORY_DIR/OVERVIEW.md" 2>/dev/null || echo 0)
CURRENT_TIME=$(date +%s)
DIFF=$(( CURRENT_TIME - OVERVIEW_TIME ))

if [ "$DIFF" -gt 3600 ]; then
    echo "[memory] 警告：OVERVIEW.md 超过 1 小时未更新。"
    echo "会话即将结束，请确认本次会话的重要进展是否已写入记忆文件。"
    echo "如未写入，建议执行「硬同步」后再结束。"
else
    echo "[memory] 记忆系统状态正常。最近更新于 ${DIFF} 秒前。"
    echo "请确认本次会话是否有未记录的重要进展。"
fi
exit 0
