# Platform detection + module registry/dispatch for the Windows bhargi CLI.

function Get-BhargiPlatform {
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

$script:BhargiModules = @(
    "system", "network", "filesystem", "processes",
    "git", "python", "packages", "windows", "utilities"
)

function Get-BhargiModulePath {
    param([string]$Name, [string]$BhargiHome)
    Join-Path $BhargiHome "commands\$Name\$Name.ps1"
}

function Invoke-BhargiModule {
    param(
        [string]$Name,
        [string[]]$ModuleArgs,
        [string]$BhargiHome
    )

    $path = Get-BhargiModulePath -Name $Name -BhargiHome $BhargiHome
    if (-not (Test-Path $path)) {
        Write-Error "Unknown module: $Name"
        Show-BhargiHelp
        return
    }

    & $path @ModuleArgs
}

function Show-BhargiHelp {
    Write-Host "bhargi - personal terminal command center (Windows)"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  bhargi.ps1                launch the interactive menu"
    Write-Host "  bhargi.ps1 <module> [...] run a module directly"
    Write-Host "  bhargi.ps1 platform        show detected platform info"
    Write-Host "  bhargi.ps1 T               drop into a normal PowerShell prompt"
    Write-Host "  bhargi.ps1 --help          show this help"
    Write-Host ""
    Write-Host "Modules:"
    foreach ($m in $script:BhargiModules) { Write-Host "  $m" }
}
