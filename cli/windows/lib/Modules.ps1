# Platform detection + module registry/dispatch for the Windows termlab CLI.

function Get-TermlabPlatform {
    $isWslAvailable = $null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)
    [PSCustomObject]@{
        OS          = "windows"
        Edition     = [System.Environment]::OSVersion.VersionString
        Arch        = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
        PowerShell  = $PSVersionTable.PSVersion.ToString()
        WslPresent  = $isWslAvailable
        WindowsTerminal = [bool]$env:WT_SESSION
    }
}

$script:TermlabModules = @(
    "system", "network", "filesystem", "processes",
    "git", "python", "packages", "windows", "utilities"
)

function Get-TermlabModulePath {
    param([string]$Name, [string]$TermlabHome)
    Join-Path $TermlabHome "commands\$Name\$Name.ps1"
}

function Invoke-TermlabModule {
    param(
        [string]$Name,
        [string[]]$ModuleArgs,
        [string]$TermlabHome
    )

    $path = Get-TermlabModulePath -Name $Name -TermlabHome $TermlabHome
    if (-not (Test-Path $path)) {
        Write-Error "Unknown module: $Name"
        Show-TermlabHelp
        return
    }

    & $path @ModuleArgs
}

function Show-TermlabHelp {
    Write-Host "termlab - personal terminal command center (Windows)"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  termlab.ps1                launch the interactive menu"
    Write-Host "  termlab.ps1 <module> [...] run a module directly"
    Write-Host "  termlab.ps1 platform        show detected platform info"
    Write-Host "  termlab.ps1 T               drop into a normal PowerShell prompt"
    Write-Host "  termlab.ps1 --help          show this help"
    Write-Host ""
    Write-Host "Modules:"
    foreach ($m in $script:TermlabModules) { Write-Host "  $m" }
}
