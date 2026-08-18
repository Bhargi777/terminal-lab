@echo off
REM cmd.exe-safe wrapper for uninstall-windows.ps1. See install-windows.bat
REM for why this exists.
setlocal
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall-windows.ps1" %*
) else (
    echo pwsh not found on PATH. Install PowerShell 7+ from https://aka.ms/powershell
    echo then re-run this script, or run uninstall-windows.ps1 directly from pwsh.
    exit /b 1
)
endlocal
