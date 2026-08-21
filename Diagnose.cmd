@echo off
title Ultrawide Resolution Toggle v4.1 - Diagnose
echo.
echo Die Diagnose veraendert KEINE Aufloesung.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ResolutionToggle-v4_1.ps1" -Diagnose
echo.
pause
