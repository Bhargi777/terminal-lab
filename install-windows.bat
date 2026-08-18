@echo off
REM cmd.exe-safe wrapper for install-windows.ps1.
REM PowerShell-only syntax like ". $PROFILE" fails in cmd.exe with
REM "'.' is not recognized as an internal or external command" — this
REM wrapper exists so cmd.exe users can just run this .bat instead of
REM pasting PowerShell syntax into the wrong shell.
setlocal
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1" %*
) else (
    echo pwsh not found on PATH. Install PowerShell 7+ from https://aka.ms/powershell
    echo then re-run this script, or run install-windows.ps1 directly from pwsh.
    exit /b 1
)
endlocal
