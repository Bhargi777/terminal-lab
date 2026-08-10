#!/usr/bin/env pwsh
# termlab packages (Windows) - detects winget or Chocolatey. "upgrade" is
# the only mutating subcommand and always requires typed confirmation.

param([string]$Sub = "info", [string[]]$Rest)

function Get-Pm {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return "winget" }
    if (Get-Command choco -ErrorAction SilentlyContinue) { return "choco" }
    return $null
}

$pm = Get-Pm

switch ($Sub) {
    "info" {
        if (-not $pm) { Write-Error "Neither winget nor choco found."; exit 1 }
        Write-Host "Package manager : $pm"
        if ($pm -eq "winget") { winget --version } else { choco --version }
    }
    "list" {
        if (-not $pm) { Write-Error "Neither winget nor choco found."; exit 1 }
        if ($pm -eq "winget") { winget list } else { choco list --local-only }
    }
    "outdated" {
        if (-not $pm) { Write-Error "Neither winget nor choco found."; exit 1 }
        if ($pm -eq "winget") { winget upgrade } else { choco outdated }
    }
    "upgrade" {
        if (-not $pm) { Write-Error "Neither winget nor choco found."; exit 1 }
        Write-Host "Outdated packages:"
        if ($pm -eq "winget") { winget upgrade } else { choco outdated }
        $confirm = Read-Host "Upgrade all of the above using $pm? Type 'yes' to confirm"
        if ($confirm -ne "yes") { Write-Host "Aborted."; exit 1 }
        if ($pm -eq "winget") { winget upgrade --all } else { choco upgrade all -y }
    }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "termlab packages [subcommand]  (detected: $($pm ?? 'none'))"
        Write-Host "  info (default)   detected package manager + version"
        Write-Host "  list             installed packages"
        Write-Host "  outdated         packages with available updates"
        Write-Host "  upgrade          upgrade outdated packages, requires typed confirmation"
    }
    default { Write-Error "Unknown packages subcommand: $Sub" }
}
