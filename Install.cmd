@echo off
title Ultrawide Resolution Toggle - Installation
echo.
echo Ultrawide Resolution Toggle
echo ===========================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install.ps1"
set EC=%errorlevel%
echo.
if not "%EC%"=="0" (
  echo FEHLER. Exit-Code: %EC%
  echo Das Fenster bleibt offen.
  pause
  exit /b %EC%
)
echo Installation abgeschlossen.
pause
