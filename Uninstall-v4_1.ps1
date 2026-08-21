$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

$InstallDir = Join-Path $env:LOCALAPPDATA 'ResolutionToggle'
$InstalledToggleScript = Join-Path $InstallDir 'ResolutionToggle-v4_1.ps1'
$BundledToggleScript = Join-Path $PSScriptRoot 'ResolutionToggle-v4_1.ps1'
$Programs = [Environment]::GetFolderPath('Programs')
$AppTitle = 'Ultrawide-Auflösung'
$ToggleShortcut = Join-Path $Programs 'Ultrawide-Auflösung umschalten.lnk'
$UninstallShortcut = Join-Path $Programs 'Ultrawide-Auflösung deinstallieren.lnk'
$TaskbarShortcut = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Ultrawide-Auflösung umschalten.lnk'

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

function Get-RestoreNativeScript {
    $candidates = @($BundledToggleScript, $InstalledToggleScript) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Select-Object -Unique

    foreach ($candidate in $candidates) {
        if (-not (Test-Path $candidate)) {
            continue
        }

        $scriptText = Get-Content -Path $candidate -Raw
        if ($scriptText -match '\[switch\]\$RestoreNative') {
            return $candidate
        }
    }

    return $null
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
    foreach ($ShortcutPath in @($TaskbarShortcut, $ToggleShortcut)) {
        Invoke-ShortcutVerb $ShortcutPath @(
            'Taskleiste.*lösen',
            'Von.*Taskleiste',
            'Unpin.*taskbar'
        ) | Out-Null
    }

    Remove-Item -Path $TaskbarShortcut -Force -ErrorAction SilentlyContinue
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
            "Soll vor der Deinstallation auf 5120 × 1440 zurückgeschaltet werden?`n`nWähle Nein, wenn die aktuelle Auflösung unverändert bleiben soll.",
            ($AppTitle + ' deinstallieren'),
            [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($restore -eq [System.Windows.Forms.DialogResult]::Cancel) {
            exit 0
        }

        if ($restore -eq [System.Windows.Forms.DialogResult]::Yes) {
            $restoreScript = Get-RestoreNativeScript

            if ([string]::IsNullOrWhiteSpace($restoreScript)) {
                $continue = [System.Windows.Forms.MessageBox]::Show(
                    "Es wurde kein aktuelles Toggle-Skript mit gezielter 5120 × 1440-Wiederherstellung gefunden.`n`nDie Auflösung wird deshalb nicht verändert.`n`nTrotzdem deinstallieren?",
                    ($AppTitle + ' deinstallieren'),
                    [System.Windows.Forms.MessageBoxButtons]::YesNo,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
                )

                if ($continue -ne [System.Windows.Forms.DialogResult]::Yes) {
                    exit 1
                }
            }
            else {
                & "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
                    -NoProfile -ExecutionPolicy Bypass -File "$restoreScript" -RestoreNative

                if ($LASTEXITCODE -ne 0) {
                    $continue = [System.Windows.Forms.MessageBox]::Show(
                        "Die Wiederherstellung auf 5120 × 1440 wurde nicht erfolgreich bestätigt (Exit-Code $LASTEXITCODE).`n`nTrotzdem deinstallieren?",
                        ($AppTitle + ' deinstallieren'),
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
    Remove-Item -Path $ToggleShortcut -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $UninstallShortcut -Force -ErrorAction SilentlyContinue

    $cleanupScheduled = $false
    if (Test-Path $InstallDir) {
        Set-Location $env:TEMP
        $cleanupScheduled = Start-DeferredInstallDirRemoval $InstallDir
    }

    if ($cleanupScheduled) {
        Show-Message "Ultrawide Resolution Toggle wurde deinstalliert.`n`nStartmenü- und Taskleisten-Verknüpfungen wurden entfernt. Die installierten Skripte und die gespeicherte Monitorbindung werden nach dem Schließen dieses Dialogs gelöscht."
    }
    else {
        Show-Message "Ultrawide Resolution Toggle wurde deinstalliert.`n`nStartmenü- und Taskleisten-Verknüpfungen, installierte Skripte und gespeicherte Monitorbindung wurden entfernt."
    }
}
catch {
    Show-Message "Deinstallation fehlgeschlagen:`n`n$($_.Exception.Message)" 'Deinstallation fehlgeschlagen' ([System.Windows.Forms.MessageBoxIcon]::Error)
    throw
}
