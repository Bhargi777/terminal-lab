# Interactive menu for the Windows termlab CLI. Text-only (no box-drawing
# reliance on a specific font) so it renders correctly in both Windows
# Terminal and the legacy conhost console.

function Show-TermlabMenu {
    param([string]$TermlabHome)

    while ($true) {
        Clear-Host
        $plat = Get-TermlabPlatform
        Write-Host "================================================"
        Write-Host "                  TERMLAB"
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
            "1" { Invoke-TermlabModule -Name "system" -ModuleArgs @() -TermlabHome $TermlabHome }
            "2" { Invoke-TermlabModule -Name "system" -ModuleArgs @("battery") -TermlabHome $TermlabHome }
            "3" { Invoke-TermlabModule -Name "filesystem" -ModuleArgs @() -TermlabHome $TermlabHome }
            "4" { Invoke-TermlabModule -Name "processes" -ModuleArgs @() -TermlabHome $TermlabHome }
            "5" { Invoke-TermlabModule -Name "git" -ModuleArgs @() -TermlabHome $TermlabHome }
            "6" { Invoke-TermlabModule -Name "python" -ModuleArgs @() -TermlabHome $TermlabHome }
            "7" { Invoke-TermlabModule -Name "packages" -ModuleArgs @() -TermlabHome $TermlabHome }
            "8" { Invoke-TermlabModule -Name "network" -ModuleArgs @() -TermlabHome $TermlabHome }
            "9" { Invoke-TermlabModule -Name "windows" -ModuleArgs @() -TermlabHome $TermlabHome }
            { $_ -in "T", "t" } {
                Write-Host "Dropping to shell. Run './termlab.ps1' any time to reopen the menu."
                Remove-Item Env:TERMLAB_ACTIVE -ErrorAction SilentlyContinue
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
