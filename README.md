Ultrawide Resolution Toggle
===========================

Dieses Tool schaltet ausdruecklich registrierte Ultrawide-Monitore zwischen ihrer nativen Aufloesung und einer zentrierten 2560 x 1440-Darstellung um.

Der technische Ansatz aus Version 4.1 bleibt erhalten: Die Windows Display Configuration API setzt nur die Source-/Desktop-Aufloesung um. Das physische Target bleibt auf der nativen Monitoraufloesung, und fuer den reduzierten Modus wird DISPLAYCONFIG_SCALING_CENTERED verwendet.

Installation
------------

1. Install.cmd starten.
2. Den Mauszeiger auf den Ultrawide-Monitor bewegen, der registriert werden soll.
3. Die Registrierung waehrend der Installation bestaetigen.
4. Den Startmenue-Eintrag "Ultrawide-Aufloesung umschalten" bei Bedarf an die Taskleiste anheften.

Windows kann automatisches Anheften an die Taskleiste blockieren. Der Startmenue-Eintrag bleibt dann als normaler Fallback verfuegbar.

Bedienung
---------

Es gibt nur einen Umschaltbutton: "Ultrawide-Aufloesung umschalten".

Noch kein Monitor registriert:
  Der Toggle registriert den Monitor unter dem Mauszeiger, sofern er als passender 1440p-Ultrawide erkannt wird. Die Aufloesung wird bei diesem ersten Klick noch nicht veraendert.

Kein registrierter Ultrawide aktiv:
  Es wird nichts veraendert.

Genau ein registrierter Ultrawide aktiv:
  Genau dieser Monitor wird umgeschaltet, unabhaengig von der Mausposition.

Mehrere registrierte Ultrawides aktiv:
  Der Monitor unter dem Mauszeiger entscheidet. Befindet sich der Mauszeiger auf einem nicht registrierten Display, wird nichts veraendert.

Monitor registrieren
--------------------

Wenn noch kein Monitor registriert ist, reicht der normale Toggle-Klick: Mauszeiger auf den gewuenschten Ultrawide bewegen und "Ultrawide-Aufloesung umschalten" starten. Dieser erste Klick registriert nur.

Weitere Monitore koennen ueber Register-Monitor.cmd registriert werden, waehrend sich der Mauszeiger auf dem gewuenschten Ultrawide befindet.

Standardprofil fuer 1440p-Ultrawides:
  native Breite groesser als 2560
  native Hoehe 1440
  reduzierter Modus 2560 x 1440
  Scaling centered

Beispiele:
  5120 x 1440 <-> 2560 x 1440
  3440 x 1440 <-> 2560 x 1440

Bereits registrierte Monitore werden anhand ihres DisplayConfig DevicePath erkannt und aktualisiert, nicht doppelt angelegt.

Monitore verwalten
------------------

Manage-Monitors.cmd startet eine einfache Konsolenverwaltung.

Moeglich ist:
  registrierte Monitore auflisten
  einen Monitor entfernen
  Konfiguration vollstaendig zuruecksetzen

Diagnose
--------

Diagnose.cmd erstellt auf dem Desktop:

  UltrawideResolutionToggle-Diagnose.txt

Die Diagnose veraendert keine Anzeigeeinstellungen. Sie enthaelt PowerShell-Version, aktive Displays, Friendly Name, GDI Name, DevicePath, EDID-Daten, Connector, Source-/Target-Aufloesung, Scaling, Registrierungsstatus, Mausposition und die gespeicherte Konfiguration.

Monitoridentifikation
---------------------

Registriert wird nicht DISPLAY1, nicht der primaere Monitor und nicht irgendein 1440p-Display. Gespeichert wird der konkrete DisplayConfig DevicePath des Zielmonitors plus hilfreiche Metadaten wie Friendly Name, EDID Manufacturer/Product, Connector, OutputTechnology und die native sowie reduzierte Aufloesung.

Beim Umschalten wird zuerst die Liste aktiver DisplayConfig-Pfade abgefragt. Nur wenn ein gespeicherter DevicePath aktuell aktiv und eindeutig vorhanden ist, darf dieser Monitor veraendert werden.

Mehrmonitorfall
---------------

Sind mehrere registrierte Ultrawides gleichzeitig aktiv, fragt das Skript die aktuelle Mausposition per GetCursorPos ab. MonitorFromPoint und GetMonitorInfo liefern daraus den GDI-Namen, zum Beispiel \\.\DISPLAY2. Dieser GDI-Name wird gegen die aktiven DisplayConfig-Pfade aufgeloest. Nur wenn der dadurch gefundene DisplayConfig DevicePath registriert ist, wird genau dieser Monitor umgeschaltet.

Sicherheit
----------

Bei Mehrdeutigkeit, fehlendem Monitor, nicht registriertem Bildschirm oder unerwarteter aktueller Aufloesung wird nichts veraendert.

Vor dem Anwenden prueft das Skript:
  Zielmonitor ist aktiv
  DevicePath stimmt exakt mit der Registrierung ueberein
  Zielaufloesung wird von Windows als Source-Modus gemeldet
  DisplayConfig-Struktur-Layouts haben die erwarteten Groessen
  SetDisplayConfig akzeptiert die neue Konfiguration zuerst mit SDC_VALIDATE

Deinstallation
--------------

Uninstall.cmd oder der Startmenue-Eintrag "Ultrawide-Aufloesung deinstallieren" entfernt Startmenue-/Taskleistenverknuepfungen, installierte Dateien und gespeicherte Konfiguration.

Auf Wunsch werden vorher nur aktive registrierte Monitore auf ihre jeweilige native Aufloesung zurueckgeschaltet. Nicht registrierte Displays werden dabei nicht veraendert.
