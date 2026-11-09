# link-skills.ps1
# 将 Vault 中的技能链接到 TRAE 全局 skills 目录
# 用法：powershell -ExecutionPolicy Bypass -File .\link-skills.ps1

$ErrorActionPreference = "Stop"

# Vault 路径（脚本在 .trae/skills/ 下，向上两级是 vault 根目录）
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vaultSkills = $scriptDir
$vaultDir = (Resolve-Path (Join-Path $scriptDir "..\..")).Path

# TRAE 全局 skills 目录
$traeSkills = Join-Path $env:USERPROFILE ".trae-cn\skills"

if (-not (Test-Path $traeSkills)) {
    Write-Error "TRAE skills 目录不存在: $traeSkills"
    exit 1
}

Write-Host "Vault skills: $vaultSkills"
Write-Host "TRAE skills:  $traeSkills"
Write-Host ""

# 备份目录
$backupDir = Join-Path $env:USERPROFILE ".trae-cn\skills_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$backupCreated = $false

$vaultSkillNames = Get-ChildItem $vaultSkills -Directory | Where-Object { $_.Name -ne "README.md" } | Select-Object -ExpandProperty Name

foreach ($name in $vaultSkillNames) {
    $vaultPath = Join-Path $vaultSkills $name
    $traePath = Join-Path $traeSkills $name

    if (Test-Path $traePath) {
        $item = Get-Item $traePath
        if ($item.LinkType -eq 'Junction' -and $item.Target -eq $vaultPath) {
            Write-Host "[SKIP] $name (already linked)"
            continue
        }
        if (-not $backupCreated) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
            $backupCreated = $true
        }
        Move-Item $traePath (Join-Path $backupDir $name) -Force
        Write-Host "[BACKUP] $name"
    }

    New-Item -ItemType Junction -Path $traePath -Target $vaultPath | Out-Null
    Write-Host "[LINK] $name"
}

Write-Host ""
Write-Host "Done. Linked $($vaultSkillNames.Count) skills."
if ($backupCreated) {
    Write-Host "Backup: $backupDir"
}
