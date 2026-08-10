#!/usr/bin/env pwsh
# termlab processes (Windows) - inspection + confirmation-guarded kill.

param([string]$Sub = "top", [string[]]$Rest)

function Show-Top {
    param([int]$Count = 10)
    Write-Host "Top $Count processes by CPU:"
    Get-Process | Sort-Object CPU -Descending | Select-Object -First $Count |
        Select-Object Id, ProcessName, CPU, @{N = "MemMB"; E = { [math]::Round($_.WorkingSet64 / 1MB, 1) } } |
        Format-Table -AutoSize
}

function Show-Mem {
    param([int]$Count = 10)
    Write-Host "Top $Count processes by memory:"
    Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First $Count |
        Select-Object Id, ProcessName, @{N = "MemMB"; E = { [math]::Round($_.WorkingSet64 / 1MB, 1) } } |
        Format-Table -AutoSize
}

function Show-Ports {
    Write-Host "Processes with open TCP connections:"
    Get-NetTCPConnection -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess |
        Select-Object -First 40 | Format-Table -AutoSize
}

function Stop-TermlabProcess {
    param([string]$ProcId, [string]$Signal = "Stop")
    if (-not $ProcId) { Write-Error "Usage: termlab processes kill <pid>"; return }

    $proc = Get-Process -Id $ProcId -ErrorAction SilentlyContinue
    if (-not $proc) { Write-Error "No process with PID $ProcId"; return }

    $proc | Select-Object Id, ProcessName, CPU | Format-Table -AutoSize
    $confirm = Read-Host "Terminate PID $ProcId ($($proc.ProcessName))? Type 'yes' to confirm"
    if ($confirm -ne "yes") { Write-Host "Aborted."; return }
    Stop-Process -Id $ProcId -Force
}

switch ($Sub) {
    "top"   { Show-Top -Count ([int]($Rest[0] ?? 10)) }
    "mem"   { Show-Mem -Count ([int]($Rest[0] ?? 10)) }
    "ports" { Show-Ports }
    "kill"  { Stop-TermlabProcess -ProcId ($Rest[0]) }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "termlab processes [subcommand]"
        Write-Host "  top [n] (default)   top n processes by CPU"
        Write-Host "  mem [n]             top n processes by memory"
        Write-Host "  ports               processes with open TCP connections"
        Write-Host "  kill <pid>          terminate a process, requires typed confirmation"
    }
    default { Write-Error "Unknown processes subcommand: $Sub" }
}
