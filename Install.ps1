$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

function Invoke-ShortcutVerb([string]$ShortcutPath, [string[]]$VerbPatterns) {
    if (-not (Test-Path $ShortcutPath)) {
        return $false
    }

    $ShellApplication = New-Object -ComObject Shell.Application
    $Folder = $ShellApplication.Namespace((Split-Path $ShortcutPath -Parent))
    if (-not $Folder) {
        return $false
    }

    $Item = $Folder.ParseName((Split-Path $ShortcutPath -Leaf))
    if (-not $Item) {
        return $false
    }

    foreach ($Verb in $Item.Verbs()) {
        $VerbName = ($Verb.Name -replace '&', '').Trim()
        foreach ($Pattern in $VerbPatterns) {
            if ($VerbName -match $Pattern) {
                $Verb.DoIt()
                return $true
            }
        }
    }

    return $false
}

function Add-TaskbarShortcut([string]$SourceShortcutPath) {
    $TaskbarDir = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
    $TaskbarShortcutPath = Join-Path $TaskbarDir 'Ultrawide-Auflösung umschalten.lnk'

    New-Item -ItemType Directory -Path $TaskbarDir -Force | Out-Null
    Copy-Item $SourceShortcutPath $TaskbarShortcutPath -Force

    Invoke-ShortcutVerb $SourceShortcutPath @(
        'Taskleiste.*anheften',
        'An.*Taskleiste',
        'Pin.*taskbar'
    ) | Out-Null
}

function New-Shortcut($Shell, [string]$Path, [string]$TargetPath, [string]$Arguments, [string]$WorkingDirectory, [string]$Description, [string]$IconLocation) {
    $Shortcut = $Shell.CreateShortcut($Path)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.WorkingDirectory = $WorkingDirectory
    $Shortcut.Description = $Description
    $Shortcut.IconLocation = $IconLocation
    $Shortcut.Save()
}

try {
    $required = @(
        'ResolutionToggle.ps1',
        'LaunchHidden.vbs',
        'Register-Monitor.cmd',
        'Manage-Monitors.cmd',
        'Diagnose.cmd',
        'Uninstall.ps1',
        'README.md'
    )

    foreach ($name in $required) {
        $path = Join-Path $PSScriptRoot $name
        if (-not (Test-Path $path)) {
            throw "$name wurde nicht gefunden."
        }
    }

    $InstallDir = Join-Path $env:LOCALAPPDATA 'ResolutionToggle'
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    foreach ($name in $required) {
        Copy-Item (Join-Path $PSScriptRoot $name) (Join-Path $InstallDir $name) -Force
    }

    $Programs = [Environment]::GetFolderPath('Programs')
    $Shell = New-Object -ComObject WScript.Shell
    $PowerShell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $WScript = "$env:SystemRoot\System32\wscript.exe"

    $ToggleShortcutPath = Join-Path $Programs 'Ultrawide-Auflösung umschalten.lnk'
    $RegisterShortcutPath = Join-Path $Programs 'Ultrawide-Monitor registrieren.lnk'
    $ManageShortcutPath = Join-Path $Programs 'Ultrawide-Monitore verwalten.lnk'
    $DiagnoseShortcutPath = Join-Path $Programs 'Ultrawide-Auflösung Diagnose.lnk'
    $UninstallShortcutPath = Join-Path $Programs 'Ultrawide-Auflösung deinstallieren.lnk'

    New-Shortcut $Shell $ToggleShortcutPath $WScript "`"$(Join-Path $InstallDir 'LaunchHidden.vbs')`"" $InstallDir 'Registrierten Ultrawide-Monitor umschalten' "$env:SystemRoot\System32\DisplaySwitch.exe,0"
    New-Shortcut $Shell $RegisterShortcutPath $PowerShell "-NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $InstallDir 'ResolutionToggle.ps1')`" -Register" $InstallDir 'Ultrawide-Monitor unter dem Mauszeiger registrieren' "$env:SystemRoot\System32\DisplaySwitch.exe,0"
    New-Shortcut $Shell $ManageShortcutPath (Join-Path $InstallDir 'Manage-Monitors.cmd') '' $InstallDir 'Registrierte Ultrawide-Monitore verwalten' "$env:SystemRoot\System32\shell32.dll,70"
    New-Shortcut $Shell $DiagnoseShortcutPath (Join-Path $InstallDir 'Diagnose.cmd') '' $InstallDir 'Diagnose ohne Anzeigeaenderung erstellen' "$env:SystemRoot\System32\shell32.dll,23"
    New-Shortcut $Shell $UninstallShortcutPath $PowerShell "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$(Join-Path $InstallDir 'Uninstall.ps1')`"" $env:TEMP 'Ultrawide Resolution Toggle deinstallieren' "$env:SystemRoot\System32\shell32.dll,31"

    Add-TaskbarShortcut $ToggleShortcutPath

    [System.Windows.Forms.MessageBox]::Show(
        "Ultrawide Resolution Toggle wurde installiert.`n`nZum ersten Registrieren den Mauszeiger auf den gewuenschten Ultrawide bewegen und Ultrawide-Aufloesung umschalten starten. Der erste Klick registriert nur, der naechste schaltet um.`n`nWeitere Monitore koennen ueber Ultrawide-Monitor registrieren hinzugefuegt werden.`n`nStartmenue-Eintraege:`n- Ultrawide-Aufloesung umschalten`n- Ultrawide-Monitor registrieren`n- Ultrawide-Monitore verwalten`n- Ultrawide-Aufloesung Diagnose`n- Ultrawide-Aufloesung deinstallieren",
        "Ultrawide-Aufloesung",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}
catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Installation fehlgeschlagen:`n`n$($_.Exception.Message)",
        "Installation fehlgeschlagen",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    throw
}
