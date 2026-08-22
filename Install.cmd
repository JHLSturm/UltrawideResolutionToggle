@echo off
chcp 65001 >nul
set "LOC=%~dp0Localization.ps1"
title Ultrawide Resolution Toggle
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". ""%LOC%""; [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Write-Host; Write-Host (Get-AppText -Key 'ProductName'); Write-Host '==========================='; Write-Host"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1"
set EC=%errorlevel%
echo.
if not "%EC%"=="0" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". ""%LOC%""; [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Write-Host (Get-AppText -Key 'CmdError' -Args @(%EC%)); Write-Host (Get-AppText -Key 'CmdWindowStaysOpen')"
  pause
  exit /b %EC%
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ". ""%LOC%""; [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new(); Write-Host (Get-AppText -Key 'InstallComplete')"
pause
