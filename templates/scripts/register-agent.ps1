# register-agent.ps1
# Agent registration / heartbeat update
# Usage: powershell -File register-agent.ps1 -AgentId "agent-01" -Name "Writer" -Role "writer"

param(
    [Parameter(Mandatory=$true)]
    [string]$AgentId,

    [string]$Name = "",
    [string]$Role = "worker",
    [string]$Status = "online",
    [string]$CurrentTask = "null",
    [string[]]$Skills = @(),
    [string]$Activity = "",
    [string]$VaultPath = ""
)

# Auto-detect vault path if not provided
if (-not $VaultPath) {
    $VaultPath = Split-Path -Parent $PSScriptRoot
}

$ErrorActionPreference = "Stop"
$stateDir = Join-Path $VaultPath "05-Agent状态"
$heartbeatFile = Join-Path $stateDir ($AgentId + ".md")

if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

if (-not $Name) { $Name = $AgentId }

$device = $env:COMPUTERNAME
$timestamp = Get-Date -Format "o"

if ($Skills.Count -gt 0) {
    $skillsYaml = "[" + ($Skills -join ", ") + "]"
} else {
    $skillsYaml = "[]"
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("agent_id: " + $AgentId)
[void]$sb.AppendLine("name: " + $Name)
[void]$sb.AppendLine("device: " + $device)
[void]$sb.AppendLine("role: " + $Role)
[void]$sb.AppendLine("status: " + $Status)
[void]$sb.AppendLine("last_heartbeat: " + $timestamp)
[void]$sb.AppendLine("current_task: " + $CurrentTask)
[void]$sb.AppendLine("skills: " + $skillsYaml)
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 最近活动")
[void]$sb.AppendLine("")
[void]$sb.AppendLine($Activity)

[System.IO.File]::WriteAllText($heartbeatFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
Write-Output "Agent " + $AgentId + " registered: " + $Status