@echo off
title Ultrawide Resolution Toggle - Monitore verwalten
set "SCRIPT=%LOCALAPPDATA%\ResolutionToggle\ResolutionToggle.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0ResolutionToggle.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Manage
echo.
pause
