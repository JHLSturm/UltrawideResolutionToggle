$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'Localization.ps1')

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
    $TaskbarShortcutPath = Join-Path $TaskbarDir (Get-AppText 'ToggleShortcutName')

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
        'Localization.ps1',
        'Write-LocalizedText.ps1',
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
            throw (Get-AppText 'RequiredFileMissing' $name)
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

    $ToggleShortcutPath = Join-Path $Programs (Get-AppText 'ToggleShortcutName')
    $RegisterShortcutPath = Join-Path $Programs (Get-AppText 'RegisterShortcutName')
    $ManageShortcutPath = Join-Path $Programs (Get-AppText 'ManageShortcutName')
    $DiagnoseShortcutPath = Join-Path $Programs (Get-AppText 'DiagnoseShortcutName')
    $UninstallShortcutPath = Join-Path $Programs (Get-AppText 'UninstallShortcutName')

    New-Shortcut $Shell $ToggleShortcutPath $WScript "`"$(Join-Path $InstallDir 'LaunchHidden.vbs')`"" $InstallDir (Get-AppText 'ToggleDescription') "$env:SystemRoot\System32\DisplaySwitch.exe,0"
    New-Shortcut $Shell $RegisterShortcutPath $PowerShell "-NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $InstallDir 'ResolutionToggle.ps1')`" -Register" $InstallDir (Get-AppText 'RegisterDescription') "$env:SystemRoot\System32\DisplaySwitch.exe,0"
    New-Shortcut $Shell $ManageShortcutPath (Join-Path $InstallDir 'Manage-Monitors.cmd') '' $InstallDir (Get-AppText 'ManageDescription') "$env:SystemRoot\System32\shell32.dll,70"
    New-Shortcut $Shell $DiagnoseShortcutPath (Join-Path $InstallDir 'Diagnose.cmd') '' $InstallDir (Get-AppText 'DiagnoseDescription') "$env:SystemRoot\System32\shell32.dll,23"
    New-Shortcut $Shell $UninstallShortcutPath $PowerShell "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$(Join-Path $InstallDir 'Uninstall.ps1')`"" $env:TEMP (Get-AppText 'UninstallDescription') "$env:SystemRoot\System32\shell32.dll,31"

    Add-TaskbarShortcut $ToggleShortcutPath

    [System.Windows.Forms.MessageBox]::Show(
        (Get-AppText 'InstallSuccess'),
        (Get-AppText 'AppTitle'),
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}
catch {
    [System.Windows.Forms.MessageBox]::Show(
        (Get-AppText 'InstallFailed' $_.Exception.Message),
        (Get-AppText 'InstallFailedTitle'),
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    throw
}
