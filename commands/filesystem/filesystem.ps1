#!/usr/bin/env pwsh
# bhargi filesystem (Windows) - inspection only, no deletion commands.

param([string]$Sub = "summary", [string[]]$Rest)

function Show-Summary {
    Write-Host "cwd  : $(Get-Location)"
    $items = Get-ChildItem -Force
    Write-Host "items: $($items.Count)"
    Write-Host ""
    $items | Format-Table Mode, LastWriteTime, Length, Name -AutoSize
}

function Show-Large {
    param([string]$Dir = ".", [int]$Count = 10)
    Write-Host "Top $Count largest files under $Dir:"
    Get-ChildItem -Path $Dir -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending | Select-Object -First $Count |
        Select-Object @{N = "SizeMB"; E = { [math]::Round($_.Length / 1MB, 2) } }, FullName |
        Format-Table -AutoSize
}

function Search-Files {
    param([string]$Pattern, [string]$Dir = ".")
    if (-not $Pattern) { Write-Error "Usage: bhargi filesystem search <pattern> [dir]"; return }
    Get-ChildItem -Path $Dir -Recurse -Filter "*$Pattern*" -ErrorAction SilentlyContinue |
        Select-Object FullName
}

function Show-Info {
    param([string]$Target)
    if (-not $Target) { Write-Error "Usage: bhargi filesystem info <path>"; return }
    if (-not (Test-Path $Target)) { Write-Error "No such file or directory: $Target"; return }
    Get-Item $Target -Force | Format-List Name, FullName, Length, Mode, LastWriteTime, LinkType, Target
}

switch ($Sub) {
    "summary" { Show-Summary }
    "large"   { Show-Large -Dir ($Rest[0]) -Count ([int]($Rest[1] ?? 10)) }
    "search"  { Search-Files -Pattern ($Rest[0]) -Dir ($Rest[1] ?? ".") }
    "info"    { Show-Info -Target ($Rest[0]) }
    { $_ -in "-h", "--help", "help" } {
        Write-Host "bhargi filesystem [subcommand]"
        Write-Host "  summary (default)      current directory listing"
        Write-Host "  large [dir] [n]        n largest files"
        Write-Host "  search <pattern> [dir] find files by name"
        Write-Host "  info <path>            item details incl. symlink target"
    }
    default { Write-Error "Unknown filesystem subcommand: $Sub" }
}
