#!/usr/bin/env pwsh
<#
.SYNOPSIS
    termlab — personal terminal command center (Windows / PowerShell port).

.DESCRIPTION
    Mirrors the macOS/Linux zsh CLI in cli/termlab as closely as PowerShell
    allows. zsh doesn't run natively on Windows, so this is a parallel,
    independently maintained implementation rather than a wrapper around
    the zsh version — same command vocabulary, same safety rules (no
    destructive action without typed confirmation), native PowerShell
    underneath.

.EXAMPLE
    ./termlab.ps1                launch the interactive menu
    ./termlab.ps1 system info    run a module command directly
    ./termlab.ps1 T              drop into a normal PowerShell prompt
#>

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$env:TERMLAB_ACTIVE = "1"
$TermlabHome = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

. "$PSScriptRoot/lib/Modules.ps1"
. "$PSScriptRoot/lib/Menu.ps1"

function Invoke-Termlab {
    param([string[]]$CmdArgs)

    if (-not $CmdArgs -or $CmdArgs.Count -eq 0) {
        Show-TermlabMenu -TermlabHome $TermlabHome
        return
    }

    switch ($CmdArgs[0]) {
        { $_ -in "-h", "--help", "help" } { Show-TermlabHelp; return }
        { $_ -in "T", "t", "terminal", "Terminal" } {
            Write-Host "Dropping to shell. Run './termlab.ps1' any time to reopen the menu."
            Remove-Item Env:TERMLAB_ACTIVE -ErrorAction SilentlyContinue
            & pwsh -NoLogo
            return
        }
        "platform" { Get-TermlabPlatform | Format-List; return }
        default {
            $rest = @()
            if ($CmdArgs.Count -gt 1) { $rest = $CmdArgs[1..($CmdArgs.Count - 1)] }
            Invoke-TermlabModule -Name $CmdArgs[0] -ModuleArgs $rest -TermlabHome $TermlabHome
        }
    }
}

Invoke-Termlab -CmdArgs $Args
