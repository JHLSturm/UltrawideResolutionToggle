$Script:AppLanguage = $null
$Script:AppStrings = @{
    de = @{
        AppTitle = 'Ultrawide-Auflösung'
        ErrorTitle = 'Ultrawide-Auflösung - Fehler'
        ProductName = 'Ultrawide Resolution Toggle'
        ToggleShortcutName = 'Ultrawide-Auflösung umschalten.lnk'
        RegisterShortcutName = 'Ultrawide-Monitor registrieren.lnk'
        ManageShortcutName = 'Ultrawide-Monitore verwalten.lnk'
        DiagnoseShortcutName = 'Ultrawide-Auflösung Diagnose.lnk'
        UninstallShortcutName = 'Ultrawide-Auflösung deinstallieren.lnk'
        ToggleDescription = 'Registrierten Ultrawide-Monitor umschalten'
        RegisterDescription = 'Ultrawide-Monitor unter dem Mauszeiger registrieren'
        ManageDescription = 'Registrierte Ultrawide-Monitore verwalten'
        DiagnoseDescription = 'Diagnose ohne Anzeigeänderung erstellen'
        UninstallDescription = 'Ultrawide Resolution Toggle deinstallieren'
        RequiredFileMissing = '{0} wurde nicht gefunden.'
        InstallSuccess = "Ultrawide Resolution Toggle wurde installiert.`n`nZum ersten Registrieren den Mauszeiger auf den gewünschten Ultrawide bewegen und Ultrawide-Auflösung umschalten starten. Der erste Klick registriert nur, der nächste schaltet um.`n`nWeitere Monitore können über Ultrawide-Monitor registrieren hinzugefügt werden.`n`nStartmenü-Einträge:`n- Ultrawide-Auflösung umschalten`n- Ultrawide-Monitor registrieren`n- Ultrawide-Monitore verwalten`n- Ultrawide-Auflösung Diagnose`n- Ultrawide-Auflösung deinstallieren"
        InstallFailed = "Installation fehlgeschlagen:`n`n{0}"
        InstallFailedTitle = 'Installation fehlgeschlagen'
        RestoreBeforeUninstall = "Sollen aktive registrierte Monitore vor der Deinstallation auf ihre native Auflösung zurückgeschaltet werden?`n`nNicht registrierte Displays werden nicht verändert."
        UninstallTitle = 'Ultrawide-Auflösung deinstallieren'
        RestoreFailedContinue = "Die native Wiederherstellung wurde nicht erfolgreich bestätigt (Exit-Code {0}).`n`nTrotzdem deinstallieren?"
        UninstallSuccessScheduled = "Ultrawide Resolution Toggle wurde deinstalliert.`n`nStartmenü- und Taskleisten-Verknüpfungen wurden entfernt. Die installierten Dateien und die gespeicherte Konfiguration werden nach dem Schließen dieses Dialogs gelöscht."
        UninstallSuccess = 'Ultrawide Resolution Toggle wurde deinstalliert.'
        UninstallFailed = "Deinstallation fehlgeschlagen:`n`n{0}"
        UninstallFailedTitle = 'Deinstallation fehlgeschlagen'
        LayoutError = 'Interner DisplayConfig-Strukturfehler: {0}'
        DuplicateActiveDevicePath = 'Ein registrierter DevicePath wurde mehrfach gefunden: {0}'
        UnsupportedSourceMode = '{0} [{1}] meldet {2} x {3} nicht als unterstützten Source-Modus.'
        ModeListed = 'Der Modus wird von EnumDisplaySettings gemeldet.'
        ModeNotListed = 'Der Modus wird von EnumDisplaySettings nicht gemeldet.'
        ValidationRejected = '{0} [{1}] hat die DisplayConfig-Validierung für {2} x {3} abgelehnt. Fehlercode: {4}. {5}'
        NoModesReported = 'Keine Modi gemeldet.'
        AdditionalModes = '... plus {0} weitere'
        ReducedModeClassicListed = 'Windows meldet diesen Modus zwar in der klassischen Modusliste, DisplayConfig akzeptiert ihn aber nicht exakt.'
        ReducedModeNotListed = 'Windows meldet diesen Modus für diesen Monitor nicht als auswählbaren Modus.'
        UnsupportedReducedMode = "Dieser Monitor bietet {0} x {1} nicht als exakt nutzbaren Modus an.`n`nMonitor: {2} [{3}]`n`n{4}`n`nDer Monitor bleibt nativ. Es wurde nichts verändert."
        CursorMonitorNotMapped = "Der Monitor unter dem Mauszeiger konnte nicht eindeutig einer aktiven DisplayConfig-Anzeige zugeordnet werden.`n`nEs wurde nichts registriert."
        NotMatchingUltrawide = "Der Bildschirm unter dem Mauszeiger ist kein passender 1440p-Ultrawide.`n`nErkannt: {0} [{1}]`nNative Auflösung: {2} x {3}`n`nEs wurde nichts registriert."
        DuplicateConfigDevicePath = 'Die Konfiguration enthält denselben DevicePath mehrfach. Bitte Manage-Monitors.cmd zum Bereinigen verwenden.'
        MonitorUpdated = "Monitor wurde aktualisiert:`n`n{0}`n{1}`n{2} x {3} <-> {4} x {5}"
        MonitorRegisteredToggle = "Monitor wurde registriert:`n`n{0}`n{1}`n{2} x {3} <-> {4} x {5}`n`nDie Auflösung wurde noch nicht verändert. Drücke den Toggle erneut, um diesen Monitor umzuschalten."
        MonitorRegistered = "Monitor wurde registriert:`n`n{0}`n{1}`n{2} x {3} <-> {4} x {5}`n`nEs werden weiterhin ausschließlich registrierte DevicePaths umgeschaltet."
        NoActiveRegistered = 'Kein registrierter Ultrawide-Monitor ist aktuell angeschlossen.'
        CurrentDisplayUnknown = "Der aktuelle Bildschirm konnte nicht ermittelt werden.`n`nEs wurde nichts verändert."
        CurrentDisplayNotRegistered = 'Der aktuelle Bildschirm ist nicht für die Auflösungsumschaltung registriert.'
        DisplayConfigChangeRejected = "Windows DisplayConfig hat den Wechsel auf {0} x {1} abgelehnt.`n`nFehlercode: {2}`n`nEs wurde kein anderer Monitor verändert."
        TargetMissingAfterChange = "Der Zielmonitor konnte nach dem Wechsel nicht mehr eindeutig gefunden werden.`n`nAngefordert war {0} x {1}. Bitte Diagnose.cmd ausführen."
        ResolutionMismatch = "Windows hat nicht die angeforderte Auflösung gesetzt.`n`nAngefordert: {0} x {1}`nTatsächlich: {2} x {3}`n`nBitte Diagnose.cmd ausführen. Es wurde kein weiterer Monitor verändert."
        UnexpectedCurrentResolution = "Der registrierte Monitor läuft aktuell mit {0} x {1}.`n`nDieses Profil schaltet nur zwischen {2} x {3} und {4} x {5}.`n`nEs wurde nichts verändert."
        ListTitle = 'Registrierte Ultrawide-Monitore'
        NoRegisteredMonitors = 'Keine registrierten Monitore.'
        ActiveState = 'aktiv'
        InactiveState = 'nicht aktiv'
        Actions = 'Aktionen:'
        RemoveAction = '  R = Monitor per Nummer entfernen'
        ResetAction = '  C = Konfiguration komplett zurücksetzen'
        QuitAction = '  Q = Beenden'
        ChoicePrompt = 'Auswahl'
        ConfirmReset = 'Wirklich alle Registrierungen entfernen? Tippe JA'
        ResetDone = 'Konfiguration wurde zurückgesetzt.'
        NumberPrompt = 'Nummer des zu entfernenden Monitors'
        InvalidNumber = 'Ungültige Nummer.'
        MonitorRemoved = 'Monitor wurde entfernt.'
        InvalidChoice = 'Ungültige Auswahl.'
        NoMatchingRegistered = 'Kein passender registrierter Monitor gefunden.'
        DiagnosisTitle = 'Ultrawide Resolution Toggle - Diagnose'
        TimeLabel = 'Zeit'
        PowerShellVersionLabel = 'PowerShell-Version'
        LayoutCheckLabel = 'Native-Struct-Layout-Prüfung'
        CursorMonitorLabel = 'Monitor unter dem Mauszeiger:'
        PositionLabel = 'Position'
        BoundsLabel = 'Bounds'
        MappingLabel = 'DisplayConfig-Zuordnung'
        RegisteredLabel = 'Registriert'
        Yes = 'ja'
        No = 'nein'
        MappingNotFound = '  DisplayConfig-Zuordnung: nicht gefunden'
        NotDetected = '  Nicht ermittelt'
        ActiveDisplaysLabel = 'Aktive Displays'
        CurrentSourceResolutionLabel = 'Aktuelle Source-Auflösung'
        CurrentTargetResolutionLabel = 'Aktuelle Target-Auflösung'
        AvailableModesLabel = 'Verfügbare Modi'
        DetectedNativeResolutionLabel = 'Erkannte native Auflösung'
        ReducedResolutionLabel = 'Reduzierte Auflösung'
        SavedConfigLabel = 'Gespeicherte Konfiguration:'
        NoConfig = 'Keine Konfiguration vorhanden.'
        DiagnosisCreated = "Diagnose erstellt:`n`n{0}`n`nEs wurden keine Anzeigeeinstellungen verändert."
        UnexpectedCrash = "Das Skript ist unerwartet abgebrochen:`n`n{0}`n`nDetails wurden - soweit möglich - hier gespeichert:`n{1}"
        RegisterCmdHint = 'Bewege den Mauszeiger auf den Ultrawide-Monitor, der registriert werden soll.'
        DiagnoseCmdHint = 'Die Diagnose verändert KEINE Auflösung.'
        CmdError = 'FEHLER. Exit-Code: {0}'
        CmdWindowStaysOpen = 'Das Fenster bleibt offen.'
        InstallComplete = 'Installation abgeschlossen.'
        UninstallComplete = 'Deinstallation abgeschlossen.'
    }
    en = @{
        AppTitle = 'Ultrawide Resolution'
        ErrorTitle = 'Ultrawide Resolution - Error'
        ProductName = 'Ultrawide Resolution Toggle'
        ToggleShortcutName = 'Toggle ultrawide resolution.lnk'
        RegisterShortcutName = 'Register ultrawide monitor.lnk'
        ManageShortcutName = 'Manage ultrawide monitors.lnk'
        DiagnoseShortcutName = 'Ultrawide resolution diagnostics.lnk'
        UninstallShortcutName = 'Uninstall Ultrawide Resolution Toggle.lnk'
        ToggleDescription = 'Toggle a registered ultrawide monitor'
        RegisterDescription = 'Register the ultrawide monitor under the mouse pointer'
        ManageDescription = 'Manage registered ultrawide monitors'
        DiagnoseDescription = 'Create diagnostics without changing display settings'
        UninstallDescription = 'Uninstall Ultrawide Resolution Toggle'
        RequiredFileMissing = '{0} was not found.'
        InstallSuccess = "Ultrawide Resolution Toggle has been installed.`n`nTo register the first monitor, move the mouse pointer onto the target ultrawide and start Toggle ultrawide resolution. The first click only registers it; the next click toggles it.`n`nAdditional monitors can be added with Register ultrawide monitor.`n`nStart menu entries:`n- Toggle ultrawide resolution`n- Register ultrawide monitor`n- Manage ultrawide monitors`n- Ultrawide resolution diagnostics`n- Uninstall Ultrawide Resolution Toggle"
        InstallFailed = "Installation failed:`n`n{0}"
        InstallFailedTitle = 'Installation failed'
        RestoreBeforeUninstall = "Switch active registered monitors back to their native resolution before uninstalling?`n`nUnregistered displays will not be changed."
        UninstallTitle = 'Uninstall Ultrawide Resolution Toggle'
        RestoreFailedContinue = "The native restore was not confirmed as successful (exit code {0}).`n`nUninstall anyway?"
        UninstallSuccessScheduled = "Ultrawide Resolution Toggle has been uninstalled.`n`nStart menu and taskbar shortcuts were removed. Installed files and the saved configuration will be deleted after you close this dialog."
        UninstallSuccess = 'Ultrawide Resolution Toggle has been uninstalled.'
        UninstallFailed = "Uninstallation failed:`n`n{0}"
        UninstallFailedTitle = 'Uninstallation failed'
        LayoutError = 'Internal DisplayConfig structure error: {0}'
        DuplicateActiveDevicePath = 'A registered DevicePath was found more than once: {0}'
        UnsupportedSourceMode = '{0} [{1}] does not report {2} x {3} as a supported source mode.'
        ModeListed = 'EnumDisplaySettings reports this mode.'
        ModeNotListed = 'EnumDisplaySettings does not report this mode.'
        ValidationRejected = '{0} [{1}] rejected DisplayConfig validation for {2} x {3}. Error code: {4}. {5}'
        NoModesReported = 'No modes reported.'
        AdditionalModes = '... plus {0} more'
        ReducedModeClassicListed = 'Windows reports this mode in the classic mode list, but DisplayConfig does not accept it exactly.'
        ReducedModeNotListed = 'Windows does not report this mode as selectable for this monitor.'
        UnsupportedReducedMode = "This monitor does not offer {0} x {1} as an exactly usable mode.`n`nMonitor: {2} [{3}]`n`n{4}`n`nThe monitor remains native. Nothing was changed."
        CursorMonitorNotMapped = "The monitor under the mouse pointer could not be matched unambiguously to an active DisplayConfig display.`n`nNothing was registered."
        NotMatchingUltrawide = "The display under the mouse pointer is not a matching 1440p ultrawide.`n`nDetected: {0} [{1}]`nNative resolution: {2} x {3}`n`nNothing was registered."
        DuplicateConfigDevicePath = 'The configuration contains the same DevicePath more than once. Please use Manage-Monitors.cmd to clean it up.'
        MonitorUpdated = "Monitor was updated:`n`n{0}`n{1}`n{2} x {3} <-> {4} x {5}"
        MonitorRegisteredToggle = "Monitor was registered:`n`n{0}`n{1}`n{2} x {3} <-> {4} x {5}`n`nThe resolution was not changed yet. Press the toggle again to switch this monitor."
        MonitorRegistered = "Monitor was registered:`n`n{0}`n{1}`n{2} x {3} <-> {4} x {5}`n`nOnly registered DevicePaths will be toggled."
        NoActiveRegistered = 'No registered ultrawide monitor is currently connected.'
        CurrentDisplayUnknown = "The current display could not be detected.`n`nNothing was changed."
        CurrentDisplayNotRegistered = 'The current display is not registered for resolution toggling.'
        DisplayConfigChangeRejected = "Windows DisplayConfig rejected the switch to {0} x {1}.`n`nError code: {2}`n`nNo other monitor was changed."
        TargetMissingAfterChange = "The target monitor could not be found unambiguously after the switch.`n`nRequested: {0} x {1}. Please run Diagnose.cmd."
        ResolutionMismatch = "Windows did not set the requested resolution.`n`nRequested: {0} x {1}`nActual: {2} x {3}`n`nPlease run Diagnose.cmd. No other monitor was changed."
        UnexpectedCurrentResolution = "The registered monitor is currently running at {0} x {1}.`n`nThis profile only toggles between {2} x {3} and {4} x {5}.`n`nNothing was changed."
        ListTitle = 'Registered ultrawide monitors'
        NoRegisteredMonitors = 'No registered monitors.'
        ActiveState = 'active'
        InactiveState = 'inactive'
        Actions = 'Actions:'
        RemoveAction = '  R = Remove monitor by number'
        ResetAction = '  C = Reset the full configuration'
        QuitAction = '  Q = Quit'
        ChoicePrompt = 'Choice'
        ConfirmReset = 'Really remove all registrations? Type YES'
        ResetDone = 'Configuration was reset.'
        NumberPrompt = 'Number of the monitor to remove'
        InvalidNumber = 'Invalid number.'
        MonitorRemoved = 'Monitor was removed.'
        InvalidChoice = 'Invalid choice.'
        NoMatchingRegistered = 'No matching registered monitor found.'
        DiagnosisTitle = 'Ultrawide Resolution Toggle - Diagnostics'
        TimeLabel = 'Time'
        PowerShellVersionLabel = 'PowerShell version'
        LayoutCheckLabel = 'Native struct layout check'
        CursorMonitorLabel = 'Monitor under the mouse pointer:'
        PositionLabel = 'Position'
        BoundsLabel = 'Bounds'
        MappingLabel = 'DisplayConfig mapping'
        RegisteredLabel = 'Registered'
        Yes = 'yes'
        No = 'no'
        MappingNotFound = '  DisplayConfig mapping: not found'
        NotDetected = '  Not detected'
        ActiveDisplaysLabel = 'Active displays'
        CurrentSourceResolutionLabel = 'Current source resolution'
        CurrentTargetResolutionLabel = 'Current target resolution'
        AvailableModesLabel = 'Available modes'
        DetectedNativeResolutionLabel = 'Detected native resolution'
        ReducedResolutionLabel = 'Reduced resolution'
        SavedConfigLabel = 'Saved configuration:'
        NoConfig = 'No configuration present.'
        DiagnosisCreated = "Diagnostics created:`n`n{0}`n`nNo display settings were changed."
        UnexpectedCrash = "The script stopped unexpectedly:`n`n{0}`n`nDetails were saved here when possible:`n{1}"
        RegisterCmdHint = 'Move the mouse pointer onto the ultrawide monitor that should be registered.'
        DiagnoseCmdHint = 'Diagnostics do NOT change any resolution.'
        CmdError = 'ERROR. Exit code: {0}'
        CmdWindowStaysOpen = 'This window will stay open.'
        InstallComplete = 'Installation complete.'
        UninstallComplete = 'Uninstallation complete.'
    }
}

function Get-AppLanguage {
    if ($Script:AppLanguage) {
        return $Script:AppLanguage
    }

    foreach ($cultureExpression in @(
        { [System.Globalization.CultureInfo]::CurrentUICulture },
        { [System.Globalization.CultureInfo]::CurrentCulture },
        { [System.Globalization.CultureInfo]::InstalledUICulture }
    )) {
        try {
            $culture = & $cultureExpression
            if ($null -eq $culture -or [string]::IsNullOrWhiteSpace($culture.Name)) {
                continue
            }

            $Script:AppLanguage = if ($culture.TwoLetterISOLanguageName -eq 'de') { 'de' } else { 'en' }
            return $Script:AppLanguage
        }
        catch {
        }
    }

    $Script:AppLanguage = 'en'
    return $Script:AppLanguage
}

function Get-AppText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [object[]]$Args = @()
    )

    $language = Get-AppLanguage
    $table = $Script:AppStrings[$language]
    if (-not $table.ContainsKey($Key)) {
        $table = $Script:AppStrings['en']
    }
    if (-not $table.ContainsKey($Key)) {
        return $Key
    }

    $text = $table[$Key]
    if ($Args.Count -gt 0) {
        return ($text -f $Args)
    }

    return $text
}
