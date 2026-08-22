@echo off
chcp 65001 >nul
set "TEXT=%~dp0Write-LocalizedText.ps1"
title Ultrawide Resolution Toggle
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEXT%" -Key ProductName -BlankBefore -BlankAfter -Underline
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall.ps1"
set EC=%errorlevel%
echo.
if not "%EC%"=="0" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEXT%" -Key CmdError -TextArgs "%EC%"
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEXT%" -Key CmdWindowStaysOpen
  pause
  exit /b %EC%
)
pause
