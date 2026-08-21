$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

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
        "Version 4.1 wurde installiert.`n`nStartmenü-Einträge:`n- Ultrawide-Auflösung umschalten`n- Ultrawide-Auflösung deinstallieren`n`nDiese Version korrigiert zusätzlich die native DISPLAYCONFIG_PATH_TARGET_INFO-Struktur und verwendet die Windows Display Configuration API für den zentrierten Wechsel.",
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
