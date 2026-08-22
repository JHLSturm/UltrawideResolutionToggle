@echo off
chcp 65001 >nul
title Ultrawide Resolution Toggle
set "BASE=%LOCALAPPDATA%\ResolutionToggle"
set "SCRIPT=%BASE%\ResolutionToggle.ps1"
if not exist "%SCRIPT%" set "BASE=%~dp0"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0ResolutionToggle.ps1"
set "TEXT=%BASE%\Write-LocalizedText.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEXT%" -Key RegisterCmdHint -BlankBefore -BlankAfter
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Register
echo.
pause
