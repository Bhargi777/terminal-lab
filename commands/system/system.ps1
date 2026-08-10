#!/usr/bin/env pwsh
# termlab system (Windows) - system information via native cmdlets/CIM,
# no external tools required.

param([string]$Sub = "info", [string[]]$Rest)

function Show-Info {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $cs = Get-CimInstance Win32_ComputerSystem

    Write-Host "OS         : $($os.Caption) $($os.Version)"
    Write-Host "Arch       : $($os.OSArchitecture)"
    Write-Host "Model      : $($cs.Manufacturer) $($cs.Model)"
    Write-Host "CPU        : $($cpu.Name)"
    Write-Host "Cores      : $($cpu.NumberOfCores) physical / $($cpu.NumberOfLogicalProcessors) logical"
    Write-Host "Memory     : $([math]::Round($cs.TotalPhysicalMemory / 1GB, 1)) GB"
    Write-Host "Hostname   : $($env:COMPUTERNAME)"
    Write-Host "User       : $($env:USERNAME)"
    Write-Host "Shell      : PowerShell $($PSVersionTable.PSVersion)"
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "Uptime     : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
}

function Show-Battery {
    $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if (-not $battery) {
        Write-Warning "No battery found (desktop PC?)"
        return
    }
    Write-Host "Charge   : $($battery.EstimatedChargeRemaining)%"
    Write-Host "Status   : $($battery.BatteryStatus)"
}

function Show-Memory {
    $os = Get-CimInstance Win32_OperatingSystem
    $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    Write-Host "Total    : $totalGB GB"
    Write-Host "Free     : $freeGB GB"
    Write-Host "Used     : $([math]::Round($totalGB - $freeGB, 1)) GB"
}

function Show-Disk {
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } |
        Select-Object Name, @{N = "UsedGB"; E = { [math]::Round($_.Used / 1GB, 1) } },
                       @{N = "FreeGB"; E = { [math]::Round($_.Free / 1GB, 1) } } |
        Format-Table -AutoSize
}

function Show-Uptime {
    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host "$($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m since last boot"
}

switch ($Sub) {
    "info"    { Show-Info }
    "battery" { Show-Battery }
    "memory"  { Show-Memory }
    "disk"    { Show-Disk }
    "uptime"  { Show-Uptime }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "termlab system [subcommand]"
        Write-Host "  info (default)   OS, model, CPU, memory summary"
        Write-Host "  battery          battery charge and status"
        Write-Host "  memory           memory usage breakdown"
        Write-Host "  disk             per-drive usage"
        Write-Host "  uptime           time since last boot"
    }
    default { Write-Error "Unknown system subcommand: $Sub" }
}
