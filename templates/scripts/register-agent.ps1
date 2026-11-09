# register-agent.ps1
# Agent registration / heartbeat update (supports partial update)
# Usage: powershell -File register-agent.ps1 -AgentId "agent-01" -Status "busy"

param(
    [Parameter(Mandatory=$true)]
    [string]$AgentId,

    [string]$Name = "",
    [string]$Role = "",
    [string]$Status = "",
    [string]$CurrentTask = "",
    [string[]]$Skills = @(),
    [string]$Activity = "",
    [string]$VaultPath = ""
)

# Auto-detect vault path
if (-not $VaultPath) {
    $VaultPath = Split-Path -Parent $PSScriptRoot
}

$ErrorActionPreference = "Stop"
$stateDir = Join-Path $VaultPath "05-Agent状态"
$heartbeatFile = Join-Path $stateDir ($AgentId + ".md")

if (-not (Test-Path $stateDir)) {
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
}

# Default values
$existingName = $AgentId
$existingRole = "worker"
$existingStatus = "online"
$existingTask = "null"
$existingSkills = @()
$existingActivity = ""

# Read existing values for partial update
if (Test-Path $heartbeatFile) {
    $existing = Get-Content $heartbeatFile -Raw
    if ($existing -match "name: (.+)") { $existingName = $matches[1].Trim() }
    if ($existing -match "role: (.+)") { $existingRole = $matches[1].Trim() }
    if ($existing -match "status: (.+)") { $existingStatus = $matches[1].Trim() }
    if ($existing -match "current_task: (.+)") { $existingTask = $matches[1].Trim() }
    if ($existing -match "skills: \[(.+)\]") { $existingSkills = $matches[1].Trim() -split ", " }
    if ($existing -match "(?s)## 最近活动\s*\n\s*(.+)") { $existingActivity = $matches[1].Trim() }
}

# Use provided value or existing
$finalName = if ($Name) { $Name } else { $existingName }
$finalRole = if ($Role) { $Role } else { $existingRole }
$finalStatus = if ($Status) { $Status } else { $existingStatus }
$finalTask = if ($CurrentTask) { $CurrentTask } else { $existingTask }
$finalSkills = if ($Skills.Count -gt 0) { $Skills } else { $existingSkills }
$finalActivity = if ($Activity) { $Activity } else { $existingActivity }

$device = $env:COMPUTERNAME
$timestamp = Get-Date -Format "o"

if ($finalSkills.Count -gt 0) {
    $skillsYaml = "[" + ($finalSkills -join ", ") + "]"
} else {
    $skillsYaml = "[]"
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("agent_id: " + $AgentId)
[void]$sb.AppendLine("name: " + $finalName)
[void]$sb.AppendLine("device: " + $device)
[void]$sb.AppendLine("role: " + $finalRole)
[void]$sb.AppendLine("status: " + $finalStatus)
[void]$sb.AppendLine("last_heartbeat: " + $timestamp)
[void]$sb.AppendLine("current_task: " + $finalTask)
[void]$sb.AppendLine("skills: " + $skillsYaml)
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 最近活动")
[void]$sb.AppendLine("")
[void]$sb.AppendLine($finalActivity)

[System.IO.File]::WriteAllText($heartbeatFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding $false))
Write-Output ("Agent " + $AgentId + " updated: " + $finalStatus)