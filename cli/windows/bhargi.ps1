#!/usr/bin/env pwsh
<#
.SYNOPSIS
    bhargi — personal terminal command center (Windows / PowerShell port).

.DESCRIPTION
    Mirrors the macOS/Linux zsh CLI in cli/bhargi as closely as PowerShell
    allows. zsh doesn't run natively on Windows, so this is a parallel,
    independently maintained implementation rather than a wrapper around
    the zsh version — same command vocabulary, same safety rules (no
    destructive action without typed confirmation), native PowerShell
    underneath.

.EXAMPLE
    ./bhargi.ps1                launch the interactive menu
    ./bhargi.ps1 system info    run a module command directly
    ./bhargi.ps1 T              drop into a normal PowerShell prompt
#>

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$env:BHARGI_ACTIVE = "1"
$BhargiHome = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

. "$PSScriptRoot/lib/Modules.ps1"
. "$PSScriptRoot/lib/Menu.ps1"

function Invoke-Bhargi {
    param([string[]]$CmdArgs)

    if (-not $CmdArgs -or $CmdArgs.Count -eq 0) {
        Show-BhargiMenu -BhargiHome $BhargiHome
        return
    }

    switch ($CmdArgs[0]) {
        { $_ -in "-h", "--help", "help" } { Show-BhargiHelp; return }
        { $_ -in "T", "t", "terminal", "Terminal" } {
            Write-Host "Dropping to shell. Run './bhargi.ps1' any time to reopen the menu."
            Remove-Item Env:BHARGI_ACTIVE -ErrorAction SilentlyContinue
            & pwsh -NoLogo
            return
        }
        "platform" { Get-BhargiPlatform | Format-List; return }
        default {
            $rest = @()
            if ($CmdArgs.Count -gt 1) { $rest = $CmdArgs[1..($CmdArgs.Count - 1)] }
            Invoke-BhargiModule -Name $CmdArgs[0] -ModuleArgs $rest -BhargiHome $BhargiHome
        }
    }
}

Invoke-Bhargi -CmdArgs $Args
