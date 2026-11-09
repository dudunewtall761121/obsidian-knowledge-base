# claim-task.ps1
# Task claiming script: claim a pending task and move to in-progress
# Usage: powershell -File claim-task.ps1 -TaskId "TASK-001" -AgentId "agent-01"

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [string]$AgentId,

    [string]$VaultPath = ""
)

# Auto-detect vault path
if (-not $VaultPath) {
    $VaultPath = Split-Path -Parent $PSScriptRoot
}

$ErrorActionPreference = "Stop"
$queueDir = Join-Path $VaultPath "04-任务队列"
$pendingDir = Join-Path $queueDir "00-待认领"
$doingDir = Join-Path $queueDir "01-进行中"

# Find task file
$taskFile = Get-ChildItem $pendingDir -Filter ($TaskId + "*.md") | Select-Object -First 1
if (-not $taskFile) {
    Write-Error "Task not found: $TaskId"
    exit 1
}

# Check lock
$lockFile = $taskFile.FullName + ".lock"
if (Test-Path $lockFile) {
    $lockContent = Get-Content $lockFile -Raw
    Write-Error "Task is locked: $lockContent"
    exit 1
}

# Create lock
$lockContent = (Get-Date -Format "o") + "`n" + $AgentId
Set-Content -Path $lockFile -Value $lockContent -NoNewline

try {
    # Read task file
    $content = Get-Content $taskFile.FullName -Raw

    # Update frontmatter
    $timestamp = Get-Date -Format "o"
    $content = $content -replace "(?m)^status: pending$", "status: claimed"
    $content = $content -replace "(?m)^owner: null$", ("owner: " + $AgentId)
    $content = $content -replace "(?m)^claimed_at: null$", ("claimed_at: " + $timestamp)

    # Append claim log
    $claimLog = "`n## 认领记录`n- " + $timestamp + " : " + $AgentId + " 认领任务`n"
    $content += $claimLog

    Set-Content -Path $taskFile.FullName -Value $content -Encoding UTF8

    # Move to in-progress
    $destPath = Join-Path $doingDir $taskFile.Name
    Move-Item $taskFile.FullName $destPath -Force

    Write-Output "Task $TaskId claimed by $AgentId"
} finally {
    # Release lock
    if (Test-Path $lockFile) {
        Remove-Item $lockFile -Force
    }
}