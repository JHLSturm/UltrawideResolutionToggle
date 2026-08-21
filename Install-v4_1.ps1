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

try {
    $Source = Join-Path $PSScriptRoot 'ResolutionToggle-v4_1.ps1'
    $LauncherSource = Join-Path $PSScriptRoot 'LaunchHidden.vbs'
    $UninstallerSource = Join-Path $PSScriptRoot 'Uninstall-v4_1.ps1'

    if (-not (Test-Path $Source)) {
        throw "ResolutionToggle-v4_1.ps1 wurde nicht gefunden."
    }
    if (-not (Test-Path $LauncherSource)) {
        throw "LaunchHidden.vbs wurde nicht gefunden."
    }
    if (-not (Test-Path $UninstallerSource)) {
        throw "Uninstall-v4_1.ps1 wurde nicht gefunden."
    }

    $InstallDir = Join-Path $env:LOCALAPPDATA 'ResolutionToggle'
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

    $Target = Join-Path $InstallDir 'ResolutionToggle-v4_1.ps1'
    $LauncherTarget = Join-Path $InstallDir 'LaunchHidden.vbs'
    $UninstallerTarget = Join-Path $InstallDir 'Uninstall-v4_1.ps1'
    Copy-Item $Source $Target -Force
    Copy-Item $LauncherSource $LauncherTarget -Force
    Copy-Item $UninstallerSource $UninstallerTarget -Force

    $Programs = [Environment]::GetFolderPath('Programs')
    $ShortcutPath = Join-Path $Programs 'Ultrawide-Auflösung umschalten.lnk'
    $UninstallShortcutPath = Join-Path $Programs 'Ultrawide-Auflösung deinstallieren.lnk'

    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "$env:SystemRoot\System32\wscript.exe"
    $Shortcut.Arguments = "`"$LauncherTarget`""
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = '5120 x 1440 <-> zentrierte 2560 x 1440'
    $Shortcut.IconLocation = "$env:SystemRoot\System32\DisplaySwitch.exe,0"
    $Shortcut.Save()
    Add-TaskbarShortcut $ShortcutPath

    $UninstallShortcut = $Shell.CreateShortcut($UninstallShortcutPath)
    $UninstallShortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $UninstallShortcut.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$UninstallerTarget`""
    $UninstallShortcut.WorkingDirectory = $env:TEMP
    $UninstallShortcut.Description = 'Ultrawide Resolution Toggle deinstallieren'
    $UninstallShortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,31"
    $UninstallShortcut.Save()

    & "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -NoProfile -ExecutionPolicy Bypass -File "$Target" -Rebind -BindOnly

    if ($LASTEXITCODE -ne 0) {
        throw "Die Monitorbindung ist mit Fehlercode $LASTEXITCODE fehlgeschlagen."
    }

    [System.Windows.Forms.MessageBox]::Show(
        "Version 4.1 wurde installiert.`n`nStartmenü-Einträge:`n- Ultrawide-Auflösung umschalten`n- Ultrawide-Auflösung deinstallieren`n`nDie Taskleisten-Verknüpfung wurde vorbereitet. Falls Windows sie nicht sofort anzeigt, ist der Startmenü-Eintrag weiterhin verfügbar.",
        "Ultrawide-Auflösung",
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
