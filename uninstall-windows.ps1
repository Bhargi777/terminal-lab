#!/usr/bin/env pwsh
# terminal-lab uninstaller for Windows/PowerShell. Removes only the
# marked block install-windows.ps1 added to $PROFILE; leaves everything
# else in the profile, and never deletes the repo or the gitignored
# `config` file.

$MarkBegin = "# >>> terminal-lab >>>"
$MarkEnd = "# <<< terminal-lab <<<"

if (-not (Test-Path $PROFILE)) {
    Write-Host "No profile found at $PROFILE — nothing to do."
    exit 0
}

$lines = Get-Content $PROFILE
if (-not ($lines -match [regex]::Escape($MarkBegin))) {
    Write-Host "No terminal-lab block found in $PROFILE — nothing to do."
    exit 0
}

$backup = "$PROFILE.bhargi-backup-$(Get-Date -Format yyyyMMddHHmmss)"
Copy-Item $PROFILE $backup
Write-Host "Backed up $PROFILE -> $backup"

$out = New-Object System.Collections.Generic.List[string]
$skip = $false
foreach ($line in $lines) {
    if ($line -eq $MarkBegin) { $skip = $true; continue }
    if ($line -eq $MarkEnd) { $skip = $false; continue }
    if (-not $skip) { $out.Add($line) }
}
Set-Content -Path $PROFILE -Value $out

Write-Host "Removed terminal-lab block from $PROFILE."
Write-Host "The repository itself and its gitignored config file were left in place."
Write-Host "Reload your profile: . `$PROFILE"
