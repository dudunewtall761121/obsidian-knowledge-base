<#
.SYNOPSIS
    Init an Obsidian second-brain knowledge base vault.
.DESCRIPTION
    Copies template files and Obsidian config to the target vault path.
.PARAMETER VaultPath
    Target vault path, e.g. "D:\Work Space\MyKB"
.EXAMPLE
    .\init-vault.ps1 -VaultPath "D:\Work Space\MyKB"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath
)

$ErrorActionPreference = "Stop"

$SkillRoot = Split-Path -Parent $PSScriptRoot
$TemplatesDir = Join-Path $SkillRoot "templates"
$ConfigDir = Join-Path $SkillRoot "obsidian-config"

function Write-Step { param([string]$Msg) Write-Host "[*] $Msg" -ForegroundColor Cyan }
function Write-Success { param([string]$Msg) Write-Host "[+] $Msg" -ForegroundColor Green }

if (-not (Test-Path $TemplatesDir)) {
    Write-Error "Templates dir not found: $TemplatesDir"
    exit 1
}

Write-Step "Target vault: $VaultPath"

# 1. Copy all template files (preserves full directory structure)
Write-Step "Copying template files..."
Get-ChildItem -Path $TemplatesDir -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Substring($TemplatesDir.Length).TrimStart('\')
    $destPath = Join-Path $VaultPath $relativePath
    $destDir = Split-Path -Parent $destPath
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -Path $_.FullName -Destination $destPath -Force
}
Write-Success "Template files copied"

# 2. Create .obsidian dir and copy config
Write-Step "Copying Obsidian config..."
$obsidianDir = Join-Path $VaultPath ".obsidian"
New-Item -ItemType Directory -Path $obsidianDir -Force | Out-Null
Get-ChildItem -Path $ConfigDir -File | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $obsidianDir $_.Name) -Force
}
Write-Success "Obsidian config copied"

Write-Host ""
Write-Success "Vault initialized!"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open Obsidian -> Manage vaults -> Open folder as vault"
Write-Host "  2. Select this folder: $VaultPath"
Write-Host "  3. Edit the entry file with your team info"
Write-Host "  4. For Git sync, run inside the vault folder:"
Write-Host "     git init"
Write-Host "     git add -A"
Write-Host "     git commit -m 'feat: init knowledge base'"
Write-Host ""
