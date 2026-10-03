@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-StarfieldAI.ps1" %*
set "SCRIPT_EXIT_CODE=%ERRORLEVEL%"

if %SCRIPT_EXIT_CODE% neq 0 (
    echo.
    echo [ERROR] Launcher stopped with exit code %SCRIPT_EXIT_CODE%.
    pause
    exit /b %SCRIPT_EXIT_CODE%
)

endlocal
exit /b 0
