#!/usr/bin/env pwsh
# termlab utilities (Windows) - identity banner from config, no hardcoded
# personal data (mirrors commands/utilities/utilities.zsh).

param([string]$Sub = "whoami", [string[]]$Rest)

function Get-TermlabConfigValue {
    param([string]$Name, [string]$Default)
    $termlabHome = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $configPath = Join-Path $termlabHome "config"
    if (Test-Path $configPath) {
        $line = Select-String -Path $configPath -Pattern "^$Name=" | Select-Object -First 1
        if ($line) { return ($line.Line -split "=", 2)[1].Trim('"') }
    }
    return $Default
}

switch ($Sub) {
    "whoami" {
        Write-Host "Name     : $(Get-TermlabConfigValue -Name 'TERMLAB_DISPLAY_NAME' -Default 'Anonymous')"
        Write-Host "Machine  : $($env:COMPUTERNAME)"
        Write-Host "User     : $($env:USERNAME)"
        Write-Host "Date     : $(Get-Date -Format 'dd MMMM yyyy')"
        Write-Host "Time     : $(Get-Date -Format 'hh:mm:ss tt')"
    }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "termlab utilities [subcommand]"
        Write-Host "  whoami (default)   identity banner from config"
    }
    default { Write-Error "Unknown utilities subcommand: $Sub" }
}
