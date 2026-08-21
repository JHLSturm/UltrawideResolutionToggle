@echo off
title Ultrawide Resolution Toggle v4.1 - Deinstallation
echo.
echo Ultrawide Resolution Toggle v4.1
echo ================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall-v4_1.ps1"
set EC=%errorlevel%
echo.
if not "%EC%"=="0" (
  echo FEHLER. Exit-Code: %EC%
  echo Das Fenster bleibt offen.
  pause
  exit /b %EC%
)
echo Deinstallation abgeschlossen.
pause
