#!/usr/bin/env pwsh
# bhargi python (Windows) - the "py" launcher is preferred over a bare
# "python" on Windows since it reliably resolves to an installed version;
# falls back to "python" if "py" isn't on PATH.

param([string]$Sub = "info", [string[]]$Rest)

function Get-PyCommand {
    if (Get-Command py -ErrorAction SilentlyContinue) { return "py" }
    if (Get-Command python -ErrorAction SilentlyContinue) { return "python" }
    Write-Error "Python not found (tried 'py' and 'python')."
    return $null
}

switch ($Sub) {
    "info" {
        $py = Get-PyCommand
        if (-not $py) { exit 1 }
        Write-Host "Python  : $(& $py --version 2>&1)"
        Write-Host "Command : $py"
        Write-Host "Pip     : $(& $py -m pip --version 2>&1)"
        if ($env:VIRTUAL_ENV) {
            Write-Host "Venv    : $($env:VIRTUAL_ENV) (active)"
        } elseif (Test-Path ".venv") {
            Write-Host "Venv    : .venv (present, not active)"
        } else {
            Write-Host "Venv    : none"
        }
    }
    "venv" {
        $py = Get-PyCommand
        if (-not $py) { exit 1 }
        if (Test-Path ".venv") {
            Write-Host ".venv already exists"
        } else {
            & $py -m venv .venv
            Write-Host "Created .venv. Run: .venv\Scripts\Activate.ps1"
        }
    }
    "packages" {
        $py = Get-PyCommand
        if (-not $py) { exit 1 }
        & $py -m pip list
    }
    "project" {
        $name = $Rest[0]
        if (-not $name) { Write-Error "Usage: bhargi python project <name>"; exit 1 }
        if (Test-Path $name) { Write-Error "$name already exists"; exit 1 }
        $py = Get-PyCommand
        if (-not $py) { exit 1 }
        New-Item -ItemType Directory -Path $name | Out-Null
        Push-Location $name
        & $py -m venv .venv
        Set-Content -Path "main.py" -Value "def main():`n    print(""hello from bhargi python project"")`n`n`nif __name__ == ""__main__"":`n    main()`n"
        New-Item -ItemType File -Path "requirements.txt" | Out-Null
        Pop-Location
        Write-Host "Created project '$name' with .venv, main.py, requirements.txt"
    }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "bhargi python [subcommand]"
        Write-Host "  info (default)   interpreter, pip, venv status"
        Write-Host "  venv             create .venv"
        Write-Host "  packages         list installed packages"
        Write-Host "  project <name>   scaffold a new project directory"
    }
    default { Write-Error "Unknown python subcommand: $Sub" }
}
