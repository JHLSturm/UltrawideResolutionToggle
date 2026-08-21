Option Explicit

Dim shell, ps, scriptPath, cmd
Set shell = CreateObject("WScript.Shell")

ps = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
scriptPath = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\ResolutionToggle\ResolutionToggle.ps1"

cmd = """" & ps & """ -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & scriptPath & """"
shell.Run cmd, 0, False
