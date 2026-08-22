$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'Localization.ps1')

$InstallDir = Join-Path $env:LOCALAPPDATA 'ResolutionToggle'
$InstalledToggleScript = Join-Path $InstallDir 'ResolutionToggle.ps1'
$BundledToggleScript = Join-Path $PSScriptRoot 'ResolutionToggle.ps1'
$Programs = [Environment]::GetFolderPath('Programs')
$AppTitle = Get-AppText 'AppTitle'
$ShortcutNames = @(
    (Get-AppText 'ToggleShortcutName'),
    (Get-AppText 'RegisterShortcutName'),
    (Get-AppText 'ManageShortcutName'),
    (Get-AppText 'DiagnoseShortcutName'),
    (Get-AppText 'UninstallShortcutName'),
    'Ultrawide-Auflösung umschalten.lnk',
    'Ultrawide-Monitor registrieren.lnk',
    'Ultrawide-Monitore verwalten.lnk',
    'Ultrawide-Auflösung Diagnose.lnk',
    'Ultrawide-Auflösung deinstallieren.lnk'
) | Select-Object -Unique
$TaskbarShortcuts = @(
    (Join-Path $env:APPDATA ('Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\' + (Get-AppText 'ToggleShortcutName'))),
    (Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Ultrawide-Auflösung umschalten.lnk')
) | Select-Object -Unique

function Show-Message(
    [string]$Text,
    [string]$Title = $AppTitle,
    [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::Information
) {
    [System.Windows.Forms.MessageBox]::Show(
        $Text,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        $Icon
    ) | Out-Null
}

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

function Remove-TaskbarShortcut {
    $startMenuToggleShortcuts = @(
        (Join-Path $Programs (Get-AppText 'ToggleShortcutName')),
        (Join-Path $Programs 'Ultrawide-Auflösung umschalten.lnk')
    ) | Select-Object -Unique

    foreach ($ShortcutPath in @($TaskbarShortcuts + $startMenuToggleShortcuts)) {
        Invoke-ShortcutVerb $ShortcutPath @(
            'Taskleiste.*lösen',
            'Von.*Taskleiste',
            'Unpin.*taskbar'
        ) | Out-Null
    }

    foreach ($ShortcutPath in $TaskbarShortcuts) {
        Remove-Item -Path $ShortcutPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-RestoreNativeScript {
    foreach ($candidate in @($BundledToggleScript, $InstalledToggleScript)) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Start-DeferredInstallDirRemoval([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $cleanupScript = Join-Path $env:TEMP ('ResolutionToggle-Uninstall-' + [guid]::NewGuid().ToString('N') + '.ps1')
    $cleanupCode = @'
param(
    [string]$InstallDir,
    [int]$ParentProcessId,
    [string]$CleanupScript
)

$ErrorActionPreference = 'SilentlyContinue'

$parent = Get-Process -Id $ParentProcessId -ErrorAction SilentlyContinue
if ($parent) {
    Wait-Process -Id $ParentProcessId -Timeout 15 -ErrorAction SilentlyContinue
}

for ($i = 0; $i -lt 20; $i++) {
    if (-not (Test-Path -LiteralPath $InstallDir)) {
        break
    }

    Remove-Item -LiteralPath $InstallDir -Recurse -Force -ErrorAction SilentlyContinue

    if (-not (Test-Path -LiteralPath $InstallDir)) {
        break
    }

    Start-Sleep -Milliseconds 500
}

Remove-Item -LiteralPath $CleanupScript -Force -ErrorAction SilentlyContinue
'@

    $encoding = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($cleanupScript, $cleanupCode, $encoding)

    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        "`"$cleanupScript`"",
        '-InstallDir',
        "`"$Path`"",
        '-ParentProcessId',
        $PID,
        '-CleanupScript',
        "`"$cleanupScript`""
    ) -join ' '

    Start-Process `
        -FilePath "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -ArgumentList $arguments `
        -WindowStyle Hidden

    return $true
}

try {
    if ((Test-Path $BundledToggleScript) -or (Test-Path $InstalledToggleScript)) {
        $restore = [System.Windows.Forms.MessageBox]::Show(
            (Get-AppText 'RestoreBeforeUninstall'),
            (Get-AppText 'UninstallTitle'),
            [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($restore -eq [System.Windows.Forms.DialogResult]::Cancel) {
            exit 0
        }

        if ($restore -eq [System.Windows.Forms.DialogResult]::Yes) {
            $restoreScript = Get-RestoreNativeScript
            if ($null -ne $restoreScript) {
                & "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
                    -NoProfile -ExecutionPolicy Bypass -File "$restoreScript" -RestoreNative

                if ($LASTEXITCODE -ne 0) {
                    $continue = [System.Windows.Forms.MessageBox]::Show(
                        (Get-AppText 'RestoreFailedContinue' $LASTEXITCODE),
                        (Get-AppText 'UninstallTitle'),
                        [System.Windows.Forms.MessageBoxButtons]::YesNo,
                        [System.Windows.Forms.MessageBoxIcon]::Warning
                    )

                    if ($continue -ne [System.Windows.Forms.DialogResult]::Yes) {
                        exit $LASTEXITCODE
                    }
                }
            }
        }
    }

    Remove-TaskbarShortcut

    foreach ($name in $ShortcutNames) {
        Remove-Item -Path (Join-Path $Programs $name) -Force -ErrorAction SilentlyContinue
    }

    $cleanupScheduled = $false
    if (Test-Path $InstallDir) {
        Set-Location $env:TEMP
        $cleanupScheduled = Start-DeferredInstallDirRemoval $InstallDir
    }

    if ($cleanupScheduled) {
        Show-Message (Get-AppText 'UninstallSuccessScheduled')
    }
    else {
        Show-Message (Get-AppText 'UninstallSuccess')
    }
}
catch {
    Show-Message (Get-AppText 'UninstallFailed' $_.Exception.Message) (Get-AppText 'UninstallFailedTitle') ([System.Windows.Forms.MessageBoxIcon]::Error)
    throw
}
