@echo off
title Ultrawide Resolution Toggle - Diagnose
set "SCRIPT=%LOCALAPPDATA%\ResolutionToggle\ResolutionToggle.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0ResolutionToggle.ps1"
echo.
echo Die Diagnose veraendert KEINE Aufloesung.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Diagnose
echo.
pause
