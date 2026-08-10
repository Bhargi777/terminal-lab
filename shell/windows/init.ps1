# terminal-lab PowerShell integration, the Windows counterpart to
# shell/zsh/init.zsh. install-windows.ps1 appends one marked line to
# $PROFILE that dot-sources this file — nothing above that line is ever
# touched.
#
# Startup auto-launch is opt-in (BHARGI_STARTUP_ENABLED in the gitignored
# `config` file) and guarded by $env:BHARGI_ACTIVE against relaunching
# itself when "T -> Terminal" starts a fresh pwsh session.

if (-not $env:BHARGI_HOME) {
    $env:BHARGI_HOME = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

function bhargi {
    & "$env:BHARGI_HOME/cli/windows/bhargi.ps1" @args
}

function Get-BhargiStartupEnabled {
    $configPath = Join-Path $env:BHARGI_HOME "config"
    if (-not (Test-Path $configPath)) { return $false }
    $line = Select-String -Path $configPath -Pattern "^BHARGI_STARTUP_ENABLED=" | Select-Object -First 1
    if (-not $line) { return $false }
    return ($line.Line -match "=1\s*$")
}

if ((Get-BhargiStartupEnabled) -and (-not $env:BHARGI_ACTIVE)) {
    bhargi
}
