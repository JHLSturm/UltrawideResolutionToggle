@echo off
title Ultrawide Resolution Toggle v4.1 - Monitor neu binden
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\ResolutionToggle\ResolutionToggle-v4_1.ps1" -Rebind -BindOnly
echo.
pause
