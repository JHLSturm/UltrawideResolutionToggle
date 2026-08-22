Ultrawide Resolution Toggle
===========================

Ultrawide Resolution Toggle switches explicitly registered ultrawide monitors between their native resolution and a centered 2560 x 1440 mode.

The tool uses the Windows Display Configuration API to change only the source/desktop resolution. The physical target remains at the monitor's native resolution, and the reduced mode uses centered scaling.

Language
--------

The user interface automatically follows the Windows host language:

- German for German system languages such as de-DE, de-AT, or de-CH
- English for all other system languages

Dialogs, error messages, console prompts, shortcut names, shortcut descriptions, and diagnostic labels use the same detected language. English is used as the fallback if language detection is unavailable.

Installation
------------

Run Install.cmd.

The installer copies the project files to:

  %LOCALAPPDATA%\ResolutionToggle

It also creates Start menu shortcuts for toggling, registering monitors, managing registered monitors, diagnostics, and uninstalling. The toggle shortcut is copied to the taskbar pin directory and Windows is asked to pin it when the shell allows that action.

Usage
-----

The normal workflow uses a single toggle shortcut.

No monitor registered yet:
  Move the mouse pointer onto the desired ultrawide and start the toggle shortcut. The first run only registers the monitor. The resolution is not changed until the next toggle.

No registered ultrawide active:
  Nothing is changed.

Exactly one registered ultrawide active:
  That monitor is toggled, regardless of the mouse position.

Multiple registered ultrawides active:
  The monitor under the mouse pointer decides. If the mouse pointer is on an unregistered display, nothing is changed.

Registering Monitors
--------------------

Additional monitors can be registered with Register-Monitor.cmd while the mouse pointer is on the desired ultrawide.

Default profile for 1440p ultrawides:

- Native width greater than 2560
- Native height 1440
- Reduced mode 2560 x 1440
- Centered scaling

Examples:

- 5120 x 1440 <-> 2560 x 1440
- 3440 x 1440 <-> 2560 x 1440

Already registered monitors are recognized and updated by their DisplayConfig DevicePath instead of being added twice.

Managing Monitors
-----------------

Manage-Monitors.cmd opens a console management tool.

Available actions:

- List registered monitors
- Remove a monitor
- Reset the full configuration

Diagnostics
-----------

Diagnose.cmd creates this file on the desktop:

  UltrawideResolutionToggle-Diagnose.txt

Diagnostics do not change display settings. The report includes the PowerShell version, active displays, friendly name, GDI name, DevicePath, EDID data, connector, source and target resolution, scaling, registration status, mouse position, and the saved configuration.

Monitor Identification
----------------------

The tool stores the concrete DisplayConfig DevicePath of the target monitor plus helpful metadata such as friendly name, EDID manufacturer/product, connector, OutputTechnology, and the native and reduced resolutions.

When toggling, the script queries the active DisplayConfig paths. A monitor may only be changed if a saved DevicePath is currently active and uniquely present.

Multi-Monitor Behavior
----------------------

If multiple registered ultrawides are active at the same time, the script queries the current mouse position with GetCursorPos. MonitorFromPoint and GetMonitorInfo return the GDI name, for example \\.\DISPLAY2. This GDI name is resolved against the active DisplayConfig paths. Only if the resulting DisplayConfig DevicePath is registered will exactly that monitor be toggled.

Safety
------

If the situation is ambiguous, the monitor is missing, the display is not registered, or the current resolution is unexpected, nothing is changed.

Before applying a change, the script verifies that:

- The target monitor is active
- The DevicePath exactly matches the registration
- The target resolution is reported by Windows as a source mode
- DisplayConfig structure layouts have the expected sizes
- SetDisplayConfig accepts the new configuration first with SDC_VALIDATE

Uninstallation
--------------

Uninstall.cmd or the Start menu uninstall entry removes Start menu shortcuts, taskbar shortcuts, installed files, and the saved configuration.

If requested, only active registered monitors are switched back to their respective native resolution first. Unregistered displays are not changed.
