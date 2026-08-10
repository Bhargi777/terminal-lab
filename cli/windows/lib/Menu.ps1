# Interactive menu for the Windows bhargi CLI. Text-only (no box-drawing
# reliance on a specific font) so it renders correctly in both Windows
# Terminal and the legacy conhost console.

function Show-BhargiMenu {
    param([string]$BhargiHome)

    while ($true) {
        Clear-Host
        $plat = Get-BhargiPlatform
        Write-Host "================================================"
        Write-Host "               BHARGI TERMINAL"
        Write-Host "           Personal Command Center"
        Write-Host "   Platform: Windows ($($plat.Arch)) | WT: $($plat.WindowsTerminal)"
        Write-Host "================================================"
        Write-Host ""
        Write-Host " SYSTEM"
        Write-Host "   1  System Information"
        Write-Host "   2  Battery"
        Write-Host "   3  Filesystem"
        Write-Host "   4  Processes"
        Write-Host ""
        Write-Host " DEVELOPMENT"
        Write-Host "   5  Git"
        Write-Host "   6  Python"
        Write-Host "   7  Packages (winget/choco)"
        Write-Host ""
        Write-Host " NETWORK"
        Write-Host "   8  Network Diagnostics"
        Write-Host ""
        Write-Host "   9  Windows Automation"
        Write-Host ""
        Write-Host " T  Terminal      Q  Quit"
        Write-Host "================================================"
        $choice = Read-Host "Select"

        switch ($choice) {
            "1" { Invoke-BhargiModule -Name "system" -ModuleArgs @() -BhargiHome $BhargiHome }
            "2" { Invoke-BhargiModule -Name "system" -ModuleArgs @("battery") -BhargiHome $BhargiHome }
            "3" { Invoke-BhargiModule -Name "filesystem" -ModuleArgs @() -BhargiHome $BhargiHome }
            "4" { Invoke-BhargiModule -Name "processes" -ModuleArgs @() -BhargiHome $BhargiHome }
            "5" { Invoke-BhargiModule -Name "git" -ModuleArgs @() -BhargiHome $BhargiHome }
            "6" { Invoke-BhargiModule -Name "python" -ModuleArgs @() -BhargiHome $BhargiHome }
            "7" { Invoke-BhargiModule -Name "packages" -ModuleArgs @() -BhargiHome $BhargiHome }
            "8" { Invoke-BhargiModule -Name "network" -ModuleArgs @() -BhargiHome $BhargiHome }
            "9" { Invoke-BhargiModule -Name "windows" -ModuleArgs @() -BhargiHome $BhargiHome }
            { $_ -in "T", "t" } {
                Write-Host "Dropping to shell. Run './bhargi.ps1' any time to reopen the menu."
                Remove-Item Env:BHARGI_ACTIVE -ErrorAction SilentlyContinue
                & pwsh -NoLogo
                return
            }
            { $_ -in "Q", "q" } { Write-Host "Bye."; return }
            default { Write-Host "Unknown choice: $choice" }
        }

        Write-Host ""
        Read-Host "Press enter to return to the menu" | Out-Null
    }
}
