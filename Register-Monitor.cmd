@echo off
title Ultrawide Resolution Toggle - Monitor registrieren
set "SCRIPT=%LOCALAPPDATA%\ResolutionToggle\ResolutionToggle.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0ResolutionToggle.ps1"
echo.
echo Bewege den Mauszeiger auf den Ultrawide-Monitor, der registriert werden soll.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Register
echo.
pause
