# 初始化 memory/ 文件夹结构 + 自动注入 hooks 到 .claude/settings.json
# 使用模板创建所有基础记忆文件

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = Join-Path (Split-Path -Parent $ScriptDir) "templates"
$MemoryDir = "memory"
$ClaudeDir = ".claude"
$SettingsFile = Join-Path $ClaudeDir "settings.json"

if (Test-Path (Join-Path $MemoryDir "OVERVIEW.md")) {
    Write-Output "[memory] 记忆系统已存在。读取 memory/OVERVIEW.md 以恢复项目认知。"
    exit 0
}

Write-Output "[memory] 正在初始化记忆系统..."

# 1. 创建 memory/ 文件夹结构
New-Item -ItemType Directory -Path (Join-Path $MemoryDir "core") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $MemoryDir "implementation") -Force | Out-Null

Copy-Item (Join-Path $TemplateDir "OVERVIEW.md") (Join-Path $MemoryDir "OVERVIEW.md")
Copy-Item (Join-Path $TemplateDir "background.md") (Join-Path $MemoryDir "core" "background.md")
Copy-Item (Join-Path $TemplateDir "current_thinking.md") (Join-Path $MemoryDir "core" "current_thinking.md")
Copy-Item (Join-Path $TemplateDir "thinking_history.md") (Join-Path $MemoryDir "core" "thinking_history.md")
Copy-Item (Join-Path $TemplateDir "file_map.md") (Join-Path $MemoryDir "implementation" "file_map.md")

# 2. 注入 hooks 到 .claude/settings.json
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null

$HooksConfig = @{
    UserPromptSubmit = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 检测到项目记忆系统。请立即读取 memory/OVERVIEW.md，根据索引按需读取相关记忆文件，重建项目认知。然后执行「五问重启测试」自检。'; fi"
                }
            )
        }
    )
    PostToolUse = @(
        @{
            matcher = "Write|Edit"
            hooks = @(
                @{
                    type = "command"
                    command = "if [ -f memory/OVERVIEW.md ]; then echo '[memory] 你刚创建/修改了文件。请检查：(1) 是否需要更新对应层级的 file_map.md；(2) 是否已达到 3 次对话的记忆更新节点。'; fi"
                }
            )
        }
    )
    Stop = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "if [ -f memory/OVERVIEW.md ]; then SCRIPT=`$(find ~/.claude/skills/memory/scripts -name check-memory.sh 2>/dev/null | head -1); if [ -n `"`$SCRIPT`" ]; then bash `"`$SCRIPT`"; else echo '[memory] 请确认本次会话是否有未记录的重要进展。'; fi; fi"
                }
            )
        }
    )
}

if (Test-Path $SettingsFile) {
    $existing = Get-Content $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($null -ne $existing.hooks -and $null -ne $existing.hooks.UserPromptSubmit) {
        Write-Output "[memory] .claude/settings.json 中已存在 hooks，跳过注入。"
    } else {
        $existing | Add-Member -NotePropertyName "hooks" -NotePropertyValue $HooksConfig -Force
        $existing | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
        Write-Output "[memory] 已将 hooks 合并到现有 .claude/settings.json。"
    }
} else {
    @{ hooks = $HooksConfig } | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
    Write-Output "[memory] 已创建 .claude/settings.json 并注入 hooks。"
}

Write-Output ""
Write-Output "[memory] 记忆系统初始化完成。"
Write-Output "已创建："
Write-Output "  memory/OVERVIEW.md"
Write-Output "  memory/core/background.md"
Write-Output "  memory/core/current_thinking.md"
Write-Output "  memory/core/thinking_history.md"
Write-Output "  memory/implementation/file_map.md"
Write-Output "  .claude/settings.json (hooks)"
Write-Output ""
Write-Output "请引导用户填写 core/background.md 和 core/current_thinking.md。"
