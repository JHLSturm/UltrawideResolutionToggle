# Ultrawide Resolution Toggle v4.1

Kleines Windows-Tool zum Umschalten eines gebundenen Ultrawide-Monitors zwischen:

- `5120 x 1440`: voller Ultrawide-Modus
- `2560 x 1440`: zentrierter Desktop mit schwarzen Balken links und rechts

Die niedrigere Auflösung wird über die Windows Display Configuration API gesetzt: Der Desktop wird auf `2560 x 1440` geändert, das physische Ziel bleibt bei `5120 x 1440`, und Windows nutzt `DISPLAYCONFIG_SCALING_CENTERED`.

## Installation

1. Falls vorhanden: alte Taskleisten-Verknüpfung lösen.
2. `Install.cmd` starten.
3. Der Installer legt Startmenü-Einträge an und versucht, **Ultrawide-Auflösung umschalten** an die Taskleiste anzuheften.

Der Installer kopiert die Skripte nach `%LOCALAPPDATA%\ResolutionToggle`, bindet den aktuell passenden Monitor und legt zwei Startmenü-Einträge an:

- **Ultrawide-Auflösung umschalten**
- **Ultrawide-Auflösung deinstallieren**

Hinweis: Windows kann automatisches Anheften an die Taskleiste je nach Version oder Richtlinie blockieren. In dem Fall bleibt der Startmenü-Eintrag als Fallback verfügbar.

## Deinstallation

Über den Startmenü-Eintrag **Ultrawide-Auflösung deinstallieren** oder direkt über `Uninstall.cmd`.

Der Uninstaller fragt, ob vor dem Entfernen wieder auf `5120 x 1440` zurückgeschaltet werden soll. Danach entfernt er:

- die Startmenü-Verknüpfungen
- die Taskleisten-Verknüpfung, soweit Windows den Pin freigibt
- die installierten Skripte unter `%LOCALAPPDATA%\ResolutionToggle`
- die gespeicherte Monitorbindung

## Monitor Neu Binden

Wenn der Monitor gewechselt wurde oder Windows einen anderen Display-Pfad meldet:

```bat
Rebind-Monitor.cmd
```

## Diagnose

Die Diagnose verändert keine Anzeigeeinstellungen und schreibt eine Textdatei auf den Desktop:

```bat
Diagnose.cmd
```

## Sicherheit

Das Tool speichert den konkreten Display-Pfad des gebundenen Monitors. Ist dieser Monitor nicht angeschlossen oder nicht aktiv, wird kein anderer Monitor verändert.

v4.1 enthält außerdem eine Prüfung der nativen DisplayConfig-Strukturgrößen, damit Fehler durch ein falsches P/Invoke-Layout früh auffallen.
