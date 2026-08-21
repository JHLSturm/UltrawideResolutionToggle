Ultrawide Resolution Toggle
===========================

This tool toggles explicitly registered ultrawide monitors between their native resolution and a centered 2560 x 1440 mode.

The technical approach from version 4.1 is preserved: the Windows Display Configuration API changes only the source/desktop resolution. The physical target remains at the monitor's native resolution, and the reduced mode uses DISPLAYCONFIG_SCALING_CENTERED.

Installation
------------

1. Run Install.cmd.
2. Move the mouse pointer onto the ultrawide monitor you want to register.
3. Confirm the registration during installation.
4. Pin the Start menu entry "Ultrawide-Aufloesung umschalten" to the taskbar if desired.

Windows may block automatic taskbar pinning. In that case, the Start menu entry remains available as the normal fallback.

Usage
-----

There is only one toggle button: "Ultrawide-Aufloesung umschalten".

No monitor registered yet:
  The toggle registers the monitor under the mouse pointer if it is detected as a matching 1440p ultrawide. The resolution is not changed on this first click.

No registered ultrawide active:
  Nothing is changed.

Exactly one registered ultrawide active:
  That monitor is toggled, regardless of the mouse position.

Multiple registered ultrawides active:
  The monitor under the mouse pointer decides. If the mouse pointer is on an unregistered display, nothing is changed.

Registering a Monitor
---------------------

If no monitor has been registered yet, the regular toggle click is enough: move the mouse pointer onto the desired ultrawide and start "Ultrawide-Aufloesung umschalten". This first click only registers the monitor.

Additional monitors can be registered with Register-Monitor.cmd while the mouse pointer is on the desired ultrawide.

Default profile for 1440p ultrawides:
  native width greater than 2560
  native height 1440
  reduced mode 2560 x 1440
  scaling centered

Examples:
  5120 x 1440 <-> 2560 x 1440
  3440 x 1440 <-> 2560 x 1440

Already registered monitors are recognized and updated by their DisplayConfig DevicePath instead of being added twice.

Managing Monitors
-----------------

Manage-Monitors.cmd starts a simple console management tool.

Available actions:
  list registered monitors
  remove a monitor
  reset the full configuration

Diagnostics
-----------

Diagnose.cmd creates the following file on the desktop:

  UltrawideResolutionToggle-Diagnose.txt

Diagnostics do not change any display settings. The report includes the PowerShell version, active displays, friendly name, GDI name, DevicePath, EDID data, connector, source/target resolution, scaling, registration status, mouse position, and the saved configuration.

Monitor Identification
----------------------

The tool does not register DISPLAY1, the primary monitor, or just any 1440p display. It stores the concrete DisplayConfig DevicePath of the target monitor plus helpful metadata such as friendly name, EDID manufacturer/product, connector, OutputTechnology, and the native and reduced resolutions.

When toggling, the script first queries the list of active DisplayConfig paths. A monitor may only be changed if a saved DevicePath is currently active and uniquely present.

Multi-Monitor Case
------------------

If multiple registered ultrawides are active at the same time, the script queries the current mouse position with GetCursorPos. MonitorFromPoint and GetMonitorInfo return the GDI name, for example \\.\DISPLAY2. This GDI name is resolved against the active DisplayConfig paths. Only if the resulting DisplayConfig DevicePath is registered will exactly that monitor be toggled.

Safety
------

If the situation is ambiguous, the monitor is missing, the display is not registered, or the current resolution is unexpected, nothing is changed.

Before applying a change, the script verifies that:
  the target monitor is active
  the DevicePath exactly matches the registration
  the target resolution is reported by Windows as a source mode
  DisplayConfig structure layouts have the expected sizes
  SetDisplayConfig accepts the new configuration first with SDC_VALIDATE

Uninstallation
--------------

Uninstall.cmd or the Start menu entry "Ultrawide-Aufloesung deinstallieren" removes Start menu/taskbar shortcuts, installed files, and the saved configuration.

If requested, only active registered monitors are switched back to their respective native resolution first. Unregistered displays are not changed.
