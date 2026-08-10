#!/usr/bin/env pwsh
<#
.SYNOPSIS
    terminal-lab installer for Windows/PowerShell.

.DESCRIPTION
    Mirrors install.sh: backs up the existing PowerShell profile before
    touching it, appends one idempotent, clearly marked block, and never
    enables auto-launch-on-new-shell unless asked to.

.EXAMPLE
    ./install-windows.ps1
    ./install-windows.ps1 -EnableStartup
#>

param([switch]$EnableStartup)

$RepoDir = $PSScriptRoot
$MarkBegin = "# >>> terminal-lab >>>"
$MarkEnd = "# <<< terminal-lab <<<"

Write-Host "== terminal-lab installer (Windows) =="

if ($PSVersionTable.Platform -and $PSVersionTable.Platform -ne "Win32NT") {
    Write-Warning "This script targets Windows. Detected platform: $($PSVersionTable.Platform)"
}
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git not found on PATH."
    exit 1
}
Write-Host "git found: $((Get-Command git).Source)"

foreach ($dep in @("winget", "choco", "python", "py")) {
    if (Get-Command $dep -ErrorAction SilentlyContinue) {
        Write-Host "  [ok]      $dep"
    } else {
        Write-Host "  [missing] $dep (some commands will report a clear error instead of failing silently)"
    }
}

# Back up existing profile.
if (Test-Path $PROFILE) {
    $backup = "$PROFILE.bhargi-backup-$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item $PROFILE $backup
    Write-Host "Backed up $PROFILE -> $backup"
} else {
    Write-Host "No existing profile at $PROFILE — a new one will be created."
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Seed config from config.example if missing.
$configPath = Join-Path $RepoDir "config"
if (-not (Test-Path $configPath)) {
    Copy-Item (Join-Path $RepoDir "config.example") $configPath
    Write-Host "Created $configPath from config.example (edit it freely, it's gitignored)"
}

if ($EnableStartup) {
    (Get-Content $configPath) -replace '^BHARGI_STARTUP_ENABLED=.*', 'BHARGI_STARTUP_ENABLED=1' |
        Set-Content $configPath
    Write-Host "Startup integration: ENABLED"
} else {
    Write-Host "Startup integration: disabled (run with -EnableStartup to turn it on)"
}

$profileContent = if (Test-Path $PROFILE) { Get-Content $PROFILE -Raw } else { "" }
if ($profileContent -match [regex]::Escape($MarkBegin)) {
    Write-Host "$PROFILE already has a terminal-lab block — leaving it as is."
} else {
    $block = "`n$MarkBegin`n. `"$RepoDir\shell\windows\init.ps1`"`n$MarkEnd`n"
    Add-Content -Path $PROFILE -Value $block
    Write-Host "Added terminal-lab integration block to $PROFILE"
}

Write-Host ""
Write-Host "== Done =="
Write-Host "Try it now:  . `$PROFILE  ;  bhargi"
Write-Host "Undo:        ./uninstall-windows.ps1"
