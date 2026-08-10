#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Parse-checks every .ps1 file in the repo without executing it.

.DESCRIPTION
    Uses the PowerShell parser directly (System.Management.Automation.Language.Parser)
    so this never runs a script's actual logic — safe in CI. Counterpart to
    tests/syntax-check.sh, which covers the zsh/bash side.
#>

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$files = Get-ChildItem -Path $repoRoot -Recurse -Filter "*.ps1" -File
$failed = $false

Write-Host "== PowerShell syntax check =="
foreach ($file in $files) {
    $relative = $file.FullName.Substring($repoRoot.Length + 1)
    $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName, [ref]$null, [ref]$errors
    )
    if ($errors.Count -eq 0) {
        Write-Host "  ok    $relative"
    } else {
        Write-Host "  FAIL  $relative"
        foreach ($e in $errors) { Write-Host "        $($e.Message)" }
        $failed = $true
    }
}

if ($failed) { exit 1 } else { exit 0 }
