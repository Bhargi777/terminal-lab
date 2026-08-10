# terminal-lab PowerShell integration, the Windows counterpart to
# shell/zsh/init.zsh. install-windows.ps1 appends one marked line to
# $PROFILE that dot-sources this file — nothing above that line is ever
# touched.
#
# Startup auto-launch is opt-in (TERMLAB_STARTUP_ENABLED in the gitignored
# `config` file) and guarded by $env:TERMLAB_ACTIVE against relaunching
# itself when "T -> Terminal" starts a fresh pwsh session.

if (-not $env:TERMLAB_HOME) {
    $env:TERMLAB_HOME = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

function termlab {
    & "$env:TERMLAB_HOME/cli/windows/termlab.ps1" @args
}

function Get-TermlabStartupEnabled {
    $configPath = Join-Path $env:TERMLAB_HOME "config"
    if (-not (Test-Path $configPath)) { return $false }
    $line = Select-String -Path $configPath -Pattern "^TERMLAB_STARTUP_ENABLED=" | Select-Object -First 1
    if (-not $line) { return $false }
    return ($line.Line -match "=1\s*$")
}

if ((Get-TermlabStartupEnabled) -and (-not $env:TERMLAB_ACTIVE)) {
    termlab
}
