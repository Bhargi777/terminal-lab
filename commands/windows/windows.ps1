#!/usr/bin/env pwsh
# termlab windows - Windows automation via built-in .NET/COM, no
# third-party modules required. Volume control is intentionally limited:
# Windows has no built-in cmdlet for absolute volume level (unlike
# macOS's osascript or Linux's pactl), so this uses SendKeys media-key
# emulation for mute/up/down only. Setting an exact percentage needs the
# optional AudioDeviceCmdlets module — documented, not silently faked.

param([string]$Sub, [string[]]$Rest)

function Invoke-Lock {
    rundll32.exe user32.dll,LockWorkStation
}

function Send-MediaKey {
    param([int]$KeyCode)
    $shell = New-Object -ComObject WScript.Shell
    $shell.SendKeys([char]$KeyCode)
}

function Invoke-Mute {
    # VK_VOLUME_MUTE = 0xAD, exposed to SendKeys as char 173
    Send-MediaKey -KeyCode 173
}

function Invoke-VolumeStep {
    param([string]$Direction)
    # VK_VOLUME_DOWN = 0xAE (174), VK_VOLUME_UP = 0xAF (175)
    $code = if ($Direction -eq "up") { 175 } else { 174 }
    Send-MediaKey -KeyCode $code
}

function Invoke-Open {
    param([string]$Target)
    if (-not $Target) { Write-Error "Usage: termlab windows open <app|url>"; return }
    Start-Process $Target
}

function Send-Notification {
    param([string]$Message, [string]$Title = "termlab")
    if (-not $Message) { Write-Error "Usage: termlab windows notify <message> [title]"; return }
    if (Get-Module -ListAvailable -Name BurntToast) {
        Import-Module BurntToast
        New-BurntToastNotification -Text $Title, $Message
    } elseif (Get-Command msg.exe -ErrorAction SilentlyContinue) {
        msg.exe $env:USERNAME "$Title`: $Message"
    } else {
        Write-Warning "No notification method available (install the BurntToast module for real toasts)."
    }
}

function Invoke-Say {
    param([string]$Text)
    if (-not $Text) { Write-Error "Usage: termlab windows say <text>"; return }
    Add-Type -AssemblyName System.Speech
    $synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $synth.Speak($Text)
}

function Open-Settings {
    Start-Process "ms-settings:"
}

switch ($Sub) {
    "lock"    { Invoke-Lock }
    "mute"    { Invoke-Mute }
    "volume"  { Invoke-VolumeStep -Direction ($Rest[0]) }
    "open"    { Invoke-Open -Target ($Rest[0]) }
    "notify"  { Send-Notification -Message ($Rest[0]) -Title ($Rest[1] ?? "termlab") }
    "say"     { Invoke-Say -Text ($Rest -join " ") }
    "settings" { Open-Settings }
    { $_ -in "-h", "--help", "help", $null, "" } {
        Write-Host "termlab windows <subcommand>"
        Write-Host "  lock                lock the workstation"
        Write-Host "  mute                toggle mute (media key emulation)"
        Write-Host "  volume up|down      step volume (media key emulation, no absolute level)"
        Write-Host "  open <app|url>      Start-Process wrapper"
        Write-Host "  notify <msg> [title] toast (BurntToast) or msg.exe fallback"
        Write-Host "  say <text>          text-to-speech (System.Speech)"
        Write-Host "  settings            open Windows Settings"
    }
    default { Write-Error "Unknown windows subcommand: $Sub" }
}
