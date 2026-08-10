#!/usr/bin/env pwsh
# bhargi network (Windows) - diagnostics via native NetTCPIP/DnsClient
# cmdlets, no third-party dependency.

param([string]$Sub = "overview", [string[]]$Rest)

function Show-Overview {
    Write-Host "Local interfaces:"
    Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.InterfaceAlias -notmatch "Loopback" } |
        ForEach-Object { Write-Host "  $($_.InterfaceAlias): $($_.IPAddress)" }

    Write-Host ""
    Write-Host "Default route:"
    Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "  $($_.NextHop) via $($_.InterfaceAlias)" }
}

function Invoke-Ping {
    param([string]$Target = "1.1.1.1")
    Test-Connection -TargetName $Target -Count 4
}

function Resolve-Host {
    param([string]$Target = "example.com")
    Resolve-DnsName -Name $Target
}

function Show-Ports {
    Get-NetTCPConnection -State Listen |
        Select-Object LocalAddress, LocalPort, OwningProcess |
        Sort-Object LocalPort | Format-Table -AutoSize
}

function Invoke-Http {
    param([string]$Url)
    if (-not $Url) { Write-Error "Usage: bhargi network http <url>"; return }
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
    $sw.Stop()
    Write-Host "Status      : $($response.StatusCode) $($response.StatusDescription)"
    Write-Host "Time total  : $($sw.Elapsed.TotalSeconds)s"
    $response.Headers | Format-Table -AutoSize
}

function Show-PublicIp {
    Write-Host "Public IP (via ifconfig.me):"
    try {
        (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing -TimeoutSec 5).Content
    } catch {
        Write-Warning "Could not reach ifconfig.me"
    }
}

switch ($Sub) {
    "overview" { Show-Overview }
    "ping"     { Invoke-Ping -Target ($Rest[0]) }
    "dns"      { Resolve-Host -Target ($Rest[0]) }
    "ports"    { Show-Ports }
    "http"     { Invoke-Http -Url ($Rest[0]) }
    "ip"       { Show-PublicIp }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "bhargi network [subcommand]"
        Write-Host "  overview (default)   interfaces + default route"
        Write-Host "  ping [host]          ping a host"
        Write-Host "  dns [host]           resolve a hostname"
        Write-Host "  ports                listening TCP ports"
        Write-Host "  http <url>           inspect an HTTP response"
        Write-Host "  ip                   public IP"
    }
    default { Write-Error "Unknown network subcommand: $Sub" }
}
