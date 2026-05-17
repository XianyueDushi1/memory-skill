# 会话结束时检查记忆状态
# 由 Stop hook 调用

$MemoryDir = "memory"
$OverviewPath = Join-Path $MemoryDir "OVERVIEW.md"

if (-not (Test-Path $OverviewPath)) {
    Write-Output "[memory] 未检测到记忆系统，无需检查。"
    exit 0
}

$OverviewTime = (Get-Item $OverviewPath).LastWriteTime
$Diff = (New-TimeSpan -Start $OverviewTime -End (Get-Date)).TotalSeconds

if ($Diff -gt 3600) {
    Write-Output "[memory] 警告：OVERVIEW.md 超过 1 小时未更新。"
    Write-Output "会话即将结束，请确认本次会话的重要进展是否已写入记忆文件。"
    Write-Output "如未写入，建议执行「硬同步」后再结束。"
} else {
    Write-Output "[memory] 记忆系统状态正常。最近更新于 $([math]::Round($Diff)) 秒前。"
    Write-Output "请确认本次会话是否有未记录的重要进展。"
}
exit 0
