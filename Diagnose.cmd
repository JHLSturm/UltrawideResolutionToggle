@echo off
chcp 65001 >nul
title Ultrawide Resolution Toggle
set "BASE=%LOCALAPPDATA%\ResolutionToggle"
set "SCRIPT=%BASE%\ResolutionToggle.ps1"
if not exist "%SCRIPT%" set "BASE=%~dp0"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0ResolutionToggle.ps1"
set "LOC=%BASE%\Localization.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". ""%LOC%""; [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Write-Host; Write-Host (Get-AppText -Key 'DiagnoseCmdHint'); Write-Host"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Diagnose
echo.
pause
