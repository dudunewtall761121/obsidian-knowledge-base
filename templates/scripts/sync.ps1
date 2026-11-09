# sync.ps1
# Knowledge base auto sync: pull -> commit -> push
# Run via Windows Task Scheduler every 5 minutes
# Usage: powershell -ExecutionPolicy Bypass -File sync.ps1

# Auto-detect vault path (script is in scripts/, parent is vault)
# Avoid passing Chinese path via CLI args to prevent encoding issues in Task Scheduler
$VaultPath = Split-Path -Parent $PSScriptRoot

$ErrorActionPreference = "Continue"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[{0}] {1}" -f $ts, $Message
    Write-Output $line
    $logPath = Join-Path $VaultPath "scripts\sync.log"
    Add-Content -Path $logPath -Value $line -Encoding UTF8
}

if (-not (Test-Path (Join-Path $VaultPath ".git"))) {
    Write-Log "ERROR: Not a git repo: $VaultPath"
    exit 1
}

try {
    $status = git -C $VaultPath status --porcelain
    if ($status) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        git -C $VaultPath add -A
        $commitOut = git -C $VaultPath commit -m "sync: $timestamp" 2>&1
        Write-Log ("commit: " + $commitOut)
        Write-Log "Local changes committed"
    } else {
        Write-Log "No local changes"
    }

    $pullOut = git -C $VaultPath pull --rebase 2>&1
    Write-Log ("pull: " + $pullOut)

    $pushOut = git -C $VaultPath push 2>&1
    Write-Log ("push: " + $pushOut)

    Write-Log "Sync done"
    exit 0
} catch {
    Write-Log ("Sync failed: " + $_)
    exit 1
}