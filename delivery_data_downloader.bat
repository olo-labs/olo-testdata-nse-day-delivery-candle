@echo off
setlocal EnableExtensions

REM %~dp0 is normally always set to this batch file's folder. Use the current
REM directory as a defensive fallback when invoked through another wrapper.
set "SCRIPT_DIR=%~dp0"
if not defined SCRIPT_DIR set "SCRIPT_DIR=%CD%\"

if not exist "%SCRIPT_DIR%download_delivery_data.ps1" (
    echo [ERROR] Missing required file: %SCRIPT_DIR%download_delivery_data.ps1
    exit /b 1
)

cd /d "%SCRIPT_DIR%" || exit /b 1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%download_delivery_data.ps1"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" echo [ERROR] Delivery download failed with exit code %EXIT_CODE%.
exit /b %EXIT_CODE%
