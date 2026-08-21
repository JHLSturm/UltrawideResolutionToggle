param(
    [switch]$BindOnly,
    [switch]$Rebind,
    [switch]$Diagnose,
    [switch]$RestoreNative
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

$AppDir = Join-Path $env:LOCALAPPDATA 'ResolutionToggle'
$ConfigPath = Join-Path $AppDir 'config-v4_1.json'
$DiagPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'UltrawideResolutionToggle-v4_1-Diagnose.txt'
New-Item -ItemType Directory -Path $AppDir -Force | Out-Null

function Show-Info([string]$Text, [string]$Title = 'Ultrawide-Auflösung') {
    [System.Windows.Forms.MessageBox]::Show(
        $Text, $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-ErrorMessage([string]$Text) {
    [System.Windows.Forms.MessageBox]::Show(
        $Text, 'Ultrawide-Auflösung – Fehler',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

$code = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class DisplayConfigNative
{
    public const uint QDC_ONLY_ACTIVE_PATHS = 0x00000002;
    public const int ERROR_SUCCESS = 0;
    public const int ERROR_INSUFFICIENT_BUFFER = 122;

    public const uint SDC_USE_SUPPLIED_DISPLAY_CONFIG = 0x00000020;
    public const uint SDC_VALIDATE = 0x00000040;
    public const uint SDC_APPLY = 0x00000080;
    public const uint SDC_SAVE_TO_DATABASE = 0x00000200;
    public const uint SDC_ALLOW_CHANGES = 0x00000400;

    public const uint DISPLAYCONFIG_MODE_INFO_TYPE_SOURCE = 1;
    public const uint DISPLAYCONFIG_MODE_INFO_TYPE_TARGET = 2;

    public const uint DISPLAYCONFIG_SCALING_IDENTITY = 1;
    public const uint DISPLAYCONFIG_SCALING_CENTERED = 2;

    public const int ENUM_CURRENT_SETTINGS = -1;
    public const int DM_PELSWIDTH = 0x00080000;
    public const int DM_PELSHEIGHT = 0x00100000;
    public const int DM_DISPLAYFREQUENCY = 0x00400000;
    public const int DM_DISPLAYFIXEDOUTPUT = unchecked((int)0x20000000);
    public const int DMDFO_DEFAULT = 0;
    public const int DMDFO_STRETCH = 1;
    public const int DMDFO_CENTER = 2;
    public const int CDS_UPDATEREGISTRY = 0x00000001;
    public const int CDS_TEST = 0x00000002;
    public const int DISP_CHANGE_SUCCESSFUL = 0;

    [StructLayout(LayoutKind.Sequential)]
    public struct LUID {
        public uint LowPart;
        public int HighPart;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_RATIONAL {
        public uint Numerator;
        public uint Denominator;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_2DREGION {
        public uint cx;
        public uint cy;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct POINTL {
        public int x;
        public int y;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct RECTL {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_VIDEO_SIGNAL_INFO {
        public ulong pixelRate;
        public DISPLAYCONFIG_RATIONAL hSyncFreq;
        public DISPLAYCONFIG_RATIONAL vSyncFreq;
        public DISPLAYCONFIG_2DREGION activeSize;
        public DISPLAYCONFIG_2DREGION totalSize;
        public uint videoStandard;
        public uint scanLineOrdering;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_TARGET_MODE {
        public DISPLAYCONFIG_VIDEO_SIGNAL_INFO targetVideoSignalInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_SOURCE_MODE {
        public uint width;
        public uint height;
        public uint pixelFormat;
        public POINTL position;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_DESKTOP_IMAGE_INFO {
        public POINTL PathSourceSize;
        public RECTL DesktopImageRegion;
        public RECTL DesktopImageClip;
    }

    [StructLayout(LayoutKind.Explicit)]
    public struct DISPLAYCONFIG_MODE_INFO_UNION {
        [FieldOffset(0)]
        public DISPLAYCONFIG_TARGET_MODE targetMode;
        [FieldOffset(0)]
        public DISPLAYCONFIG_SOURCE_MODE sourceMode;
        [FieldOffset(0)]
        public DISPLAYCONFIG_DESKTOP_IMAGE_INFO desktopImageInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_MODE_INFO {
        public uint infoType;
        public uint id;
        public LUID adapterId;
        public DISPLAYCONFIG_MODE_INFO_UNION modeInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_PATH_SOURCE_INFO {
        public LUID adapterId;
        public uint id;
        public uint modeInfoIdx;
        public uint statusFlags;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_PATH_TARGET_INFO {
        public LUID adapterId;
        public uint id;
        public uint modeInfoIdx;
        public uint outputTechnology;
        public uint rotation;
        public uint scaling;
        public DISPLAYCONFIG_RATIONAL refreshRate;
        public uint scanLineOrdering;
        [MarshalAs(UnmanagedType.Bool)]
        public bool targetAvailable;
        public uint statusFlags;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_PATH_INFO {
        public DISPLAYCONFIG_PATH_SOURCE_INFO sourceInfo;
        public DISPLAYCONFIG_PATH_TARGET_INFO targetInfo;
        public uint flags;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct DISPLAYCONFIG_DEVICE_INFO_HEADER {
        public uint type;
        public uint size;
        public LUID adapterId;
        public uint id;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DISPLAYCONFIG_SOURCE_DEVICE_NAME {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string viewGdiDeviceName;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DISPLAYCONFIG_TARGET_DEVICE_NAME {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;
        public uint flags;
        public uint outputTechnology;
        public ushort edidManufactureId;
        public ushort edidProductCodeId;
        public uint connectorInstance;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 64)]
        public string monitorFriendlyDeviceName;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 128)]
        public string monitorDevicePath;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DEVMODE {
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmDeviceName;
        public short dmSpecVersion;
        public short dmDriverVersion;
        public short dmSize;
        public short dmDriverExtra;
        public int dmFields;
        public int dmPositionX;
        public int dmPositionY;
        public int dmDisplayOrientation;
        public int dmDisplayFixedOutput;
        public short dmColor;
        public short dmDuplex;
        public short dmYResolution;
        public short dmTTOption;
        public short dmCollate;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmFormName;

        public short dmLogPixels;
        public int dmBitsPerPel;
        public int dmPelsWidth;
        public int dmPelsHeight;
        public int dmDisplayFlags;
        public int dmDisplayFrequency;
        public int dmICMMethod;
        public int dmICMIntent;
        public int dmMediaType;
        public int dmDitherType;
        public int dmReserved1;
        public int dmReserved2;
        public int dmPanningWidth;
        public int dmPanningHeight;
    }

    public class ActiveMonitor {
        public string GdiName;
        public string FriendlyName;
        public string DevicePath;
        public uint EdidManufacturerId;
        public uint EdidProductCodeId;
        public uint ConnectorInstance;
        public int Width;
        public int Height;
        public int Frequency;
    }

    public class ModeInfo {
        public int Width;
        public int Height;
        public int Frequency;
    }

    [DllImport("user32.dll")]
    static extern int GetDisplayConfigBufferSizes(
        uint flags,
        out uint numPathArrayElements,
        out uint numModeInfoArrayElements);

    [DllImport("user32.dll")]
    static extern int QueryDisplayConfig(
        uint flags,
        ref uint numPathArrayElements,
        [Out] DISPLAYCONFIG_PATH_INFO[] pathArray,
        ref uint numModeInfoArrayElements,
        [Out] DISPLAYCONFIG_MODE_INFO[] modeInfoArray,
        IntPtr currentTopologyId);

    [DllImport("user32.dll")]
    static extern int SetDisplayConfig(
        uint numPathArrayElements,
        [In] DISPLAYCONFIG_PATH_INFO[] pathArray,
        uint numModeInfoArrayElements,
        [In] DISPLAYCONFIG_MODE_INFO[] modeInfoArray,
        uint flags);

    [DllImport("user32.dll", EntryPoint = "DisplayConfigGetDeviceInfo")]
    static extern int DisplayConfigGetSourceDeviceInfo(
        ref DISPLAYCONFIG_SOURCE_DEVICE_NAME requestPacket);

    [DllImport("user32.dll", EntryPoint = "DisplayConfigGetDeviceInfo")]
    static extern int DisplayConfigGetTargetDeviceInfo(
        ref DISPLAYCONFIG_TARGET_DEVICE_NAME requestPacket);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool EnumDisplaySettings(
        string deviceName,
        int modeNum,
        ref DEVMODE devMode);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern int ChangeDisplaySettingsEx(
        string lpszDeviceName,
        ref DEVMODE lpDevMode,
        IntPtr hwnd,
        int dwflags,
        IntPtr lParam);

    static DEVMODE NewDevMode() {
        DEVMODE dm = new DEVMODE();
        dm.dmDeviceName = new string('\0', 32);
        dm.dmFormName = new string('\0', 32);
        dm.dmSize = (short)Marshal.SizeOf(typeof(DEVMODE));
        return dm;
    }

    static string Clean(string s) {
        if (s == null) return "";
        return s.TrimEnd('\0').Trim();
    }

    public static string ValidateNativeLayouts() {
        int sourceSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_PATH_SOURCE_INFO));
        int targetSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_PATH_TARGET_INFO));
        int pathSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_PATH_INFO));
        int modeSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_MODE_INFO));

        // Sizes from the Windows SDK layout on x86/x64 for these pointer-free structs.
        if (sourceSize != 20)
            return "DISPLAYCONFIG_PATH_SOURCE_INFO=" + sourceSize + " (expected 20)";
        if (targetSize != 48)
            return "DISPLAYCONFIG_PATH_TARGET_INFO=" + targetSize + " (expected 48)";
        if (pathSize != 72)
            return "DISPLAYCONFIG_PATH_INFO=" + pathSize + " (expected 72)";
        if (modeSize != 64)
            return "DISPLAYCONFIG_MODE_INFO=" + modeSize + " (expected 64)";

        return "";
    }

    public static List<ActiveMonitor> GetActiveMonitors() {
        for (int attempt = 0; attempt < 4; attempt++) {
            uint pathCount;
            uint modeCount;
            int rc = GetDisplayConfigBufferSizes(QDC_ONLY_ACTIVE_PATHS, out pathCount, out modeCount);
            if (rc != ERROR_SUCCESS)
                throw new InvalidOperationException("GetDisplayConfigBufferSizes failed: " + rc);

            DISPLAYCONFIG_PATH_INFO[] paths = new DISPLAYCONFIG_PATH_INFO[pathCount];
            DISPLAYCONFIG_MODE_INFO[] modes = new DISPLAYCONFIG_MODE_INFO[modeCount];

            rc = QueryDisplayConfig(
                QDC_ONLY_ACTIVE_PATHS,
                ref pathCount,
                paths,
                ref modeCount,
                modes,
                IntPtr.Zero);

            if (rc == ERROR_INSUFFICIENT_BUFFER)
                continue;

            if (rc != ERROR_SUCCESS)
                throw new InvalidOperationException("QueryDisplayConfig failed: " + rc);

            var result = new List<ActiveMonitor>();

            for (int i = 0; i < pathCount; i++) {
                DISPLAYCONFIG_PATH_INFO p = paths[i];

                DISPLAYCONFIG_SOURCE_DEVICE_NAME src = new DISPLAYCONFIG_SOURCE_DEVICE_NAME();
                src.viewGdiDeviceName = new string('\0', 32);
                src.header.type = 1; // DISPLAYCONFIG_DEVICE_INFO_GET_SOURCE_NAME
                src.header.size = (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_SOURCE_DEVICE_NAME));
                src.header.adapterId = p.sourceInfo.adapterId;
                src.header.id = p.sourceInfo.id;

                int srcRc = DisplayConfigGetSourceDeviceInfo(ref src);
                if (srcRc != ERROR_SUCCESS)
                    continue;

                DISPLAYCONFIG_TARGET_DEVICE_NAME tgt = new DISPLAYCONFIG_TARGET_DEVICE_NAME();
                tgt.monitorFriendlyDeviceName = new string('\0', 64);
                tgt.monitorDevicePath = new string('\0', 128);
                tgt.header.type = 2; // DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
                tgt.header.size = (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_TARGET_DEVICE_NAME));
                tgt.header.adapterId = p.targetInfo.adapterId;
                tgt.header.id = p.targetInfo.id;

                int tgtRc = DisplayConfigGetTargetDeviceInfo(ref tgt);
                if (tgtRc != ERROR_SUCCESS)
                    continue;

                string gdi = Clean(src.viewGdiDeviceName);
                DEVMODE current = NewDevMode();
                if (!EnumDisplaySettings(gdi, ENUM_CURRENT_SETTINGS, ref current))
                    continue;

                result.Add(new ActiveMonitor {
                    GdiName = gdi,
                    FriendlyName = Clean(tgt.monitorFriendlyDeviceName),
                    DevicePath = Clean(tgt.monitorDevicePath),
                    EdidManufacturerId = tgt.edidManufactureId,
                    EdidProductCodeId = tgt.edidProductCodeId,
                    ConnectorInstance = tgt.connectorInstance,
                    Width = current.dmPelsWidth,
                    Height = current.dmPelsHeight,
                    Frequency = current.dmDisplayFrequency
                });
            }

            return result;
        }

        throw new InvalidOperationException("QueryDisplayConfig returned ERROR_INSUFFICIENT_BUFFER repeatedly.");
    }

    public static List<ModeInfo> GetModes(string gdiName) {
        var result = new List<ModeInfo>();
        for (int i = 0; ; i++) {
            DEVMODE dm = NewDevMode();
            if (!EnumDisplaySettings(gdiName, i, ref dm))
                break;

            result.Add(new ModeInfo {
                Width = dm.dmPelsWidth,
                Height = dm.dmPelsHeight,
                Frequency = dm.dmDisplayFrequency
            });
        }
        return result;
    }

    public static bool Supports(string gdiName, int width, int height) {
        foreach (ModeInfo m in GetModes(gdiName)) {
            if (m.Width == width && m.Height == height)
                return true;
        }
        return false;
    }

    public static int SetCcdResolution(
        string gdiName,
        int width,
        int height,
        bool center)
    {
        for (int attempt = 0; attempt < 4; attempt++) {
            uint pathCount;
            uint modeCount;

            int rc = GetDisplayConfigBufferSizes(
                QDC_ONLY_ACTIVE_PATHS,
                out pathCount,
                out modeCount);

            if (rc != ERROR_SUCCESS)
                return rc;

            DISPLAYCONFIG_PATH_INFO[] paths =
                new DISPLAYCONFIG_PATH_INFO[pathCount];

            DISPLAYCONFIG_MODE_INFO[] modes =
                new DISPLAYCONFIG_MODE_INFO[modeCount];

            rc = QueryDisplayConfig(
                QDC_ONLY_ACTIVE_PATHS,
                ref pathCount,
                paths,
                ref modeCount,
                modes,
                IntPtr.Zero);

            if (rc == ERROR_INSUFFICIENT_BUFFER)
                continue;

            if (rc != ERROR_SUCCESS)
                return rc;

            int pathIndex = -1;

            for (int i = 0; i < pathCount; i++) {
                DISPLAYCONFIG_SOURCE_DEVICE_NAME src =
                    new DISPLAYCONFIG_SOURCE_DEVICE_NAME();

                src.viewGdiDeviceName = new string('\0', 32);
                src.header.type = 1;
                src.header.size =
                    (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_SOURCE_DEVICE_NAME));
                src.header.adapterId = paths[i].sourceInfo.adapterId;
                src.header.id = paths[i].sourceInfo.id;

                int srcRc = DisplayConfigGetSourceDeviceInfo(ref src);

                if (srcRc == ERROR_SUCCESS &&
                    String.Equals(
                        Clean(src.viewGdiDeviceName),
                        gdiName,
                        StringComparison.OrdinalIgnoreCase))
                {
                    pathIndex = i;
                    break;
                }
            }

            if (pathIndex < 0)
                return -200;

            DISPLAYCONFIG_PATH_INFO path = paths[pathIndex];

            uint sourceIndex = path.sourceInfo.modeInfoIdx;
            uint targetIndex = path.targetInfo.modeInfoIdx;

            if (sourceIndex >= modeCount || targetIndex >= modeCount)
                return -201;

            if (modes[sourceIndex].infoType != DISPLAYCONFIG_MODE_INFO_TYPE_SOURCE)
                return -202;

            if (modes[targetIndex].infoType != DISPLAYCONFIG_MODE_INFO_TYPE_TARGET)
                return -203;

            // Keep the physical target timing exactly as Windows currently has it
            // (normally the panel-native 5120x1440 signal). Only the desktop/source
            // canvas is changed to 2560x1440. That creates the source/target mismatch
            // required for CCD centered scaling.
            DISPLAYCONFIG_MODE_INFO srcMode = modes[sourceIndex];
            DISPLAYCONFIG_SOURCE_MODE source = srcMode.modeInfo.sourceMode;
            source.width = (uint)width;
            source.height = (uint)height;
            srcMode.modeInfo.sourceMode = source;
            modes[sourceIndex] = srcMode;

            path.targetInfo.scaling =
                center
                ? DISPLAYCONFIG_SCALING_CENTERED
                : DISPLAYCONFIG_SCALING_IDENTITY;

            paths[pathIndex] = path;

            uint validateFlags =
                SDC_USE_SUPPLIED_DISPLAY_CONFIG |
                SDC_VALIDATE |
                SDC_ALLOW_CHANGES;

            rc = SetDisplayConfig(
                pathCount,
                paths,
                modeCount,
                modes,
                validateFlags);

            if (rc != ERROR_SUCCESS)
                return rc;

            uint applyFlags =
                SDC_USE_SUPPLIED_DISPLAY_CONFIG |
                SDC_APPLY |
                SDC_SAVE_TO_DATABASE |
                SDC_ALLOW_CHANGES;

            return SetDisplayConfig(
                pathCount,
                paths,
                modeCount,
                modes,
                applyFlags);
        }

        return ERROR_INSUFFICIENT_BUFFER;
    }
}
'@

try {
    if (-not ('DisplayConfigNative' -as [type])) {
        Add-Type -TypeDefinition $code -Language CSharp
    }

    $layoutError = [DisplayConfigNative]::ValidateNativeLayouts()
    if (-not [string]::IsNullOrWhiteSpace($layoutError)) {
        throw "Interner DisplayConfig-Strukturfehler: $layoutError"
    }

    function Get-Candidates {
        $all = @([DisplayConfigNative]::GetActiveMonitors())
        return @($all | Where-Object {
            [DisplayConfigNative]::Supports($_.GdiName, 5120, 1440) -and
            [DisplayConfigNative]::Supports($_.GdiName, 2560, 1440)
        })
    }

    function Write-Diagnosis {
        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add('Ultrawide Resolution Toggle v4.1 - Diagnose')
        $lines.Add('==========================================')
        $lines.Add(('Zeit: ' + (Get-Date)))
        $lines.Add(('PowerShell: ' + $PSVersionTable.PSVersion))
        $lines.Add(('Native layout check: ' + [DisplayConfigNative]::ValidateNativeLayouts()))
        $lines.Add('')

        $monitors = @([DisplayConfigNative]::GetActiveMonitors())
        $lines.Add(('Aktive DisplayConfig-Monitore: ' + $monitors.Count))
        foreach ($m in $monitors) {
            $lines.Add('')
            $lines.Add(('Name: ' + $m.FriendlyName))
            $lines.Add(('GDI: ' + $m.GdiName))
            $lines.Add(('DevicePath: ' + $m.DevicePath))
            $lines.Add(('EDID Manufacturer: ' + $m.EdidManufacturerId))
            $lines.Add(('EDID Product: ' + $m.EdidProductCodeId))
            $lines.Add(('Connector: ' + $m.ConnectorInstance))
            $lines.Add(('Current: {0}x{1} @ {2} Hz' -f $m.Width, $m.Height, $m.Frequency))
            $lines.Add(('Supports 5120x1440: ' + [DisplayConfigNative]::Supports($m.GdiName, 5120, 1440)))
            $lines.Add(('Supports 2560x1440: ' + [DisplayConfigNative]::Supports($m.GdiName, 2560, 1440)))
        }

        if (Test-Path $ConfigPath) {
            $lines.Add('')
            $lines.Add('Gespeicherte Konfiguration:')
            $lines.Add((Get-Content $ConfigPath -Raw))
        }

        $lines | Set-Content -Path $DiagPath -Encoding UTF8
        Show-Info "Diagnose erstellt:`n`n$DiagPath`n`nEs wurden keine Anzeigeeinstellungen verändert."
        return
    }

    if ($Diagnose) {
        Write-Diagnosis
        exit 0
    }

    if ($Rebind -and (Test-Path $ConfigPath)) {
        Remove-Item $ConfigPath -Force
    }

    if (-not (Test-Path $ConfigPath)) {
        $candidates = @(Get-Candidates)

        if ($candidates.Count -eq 0) {
            Show-Info "Es wurde kein aktuell angeschlossener Monitor gefunden, der sowohl 5120 × 1440 als auch 2560 × 1440 unterstützt.`n`nEs wurde nichts verändert."
            exit 10
        }

        if ($candidates.Count -gt 1) {
            $desc = ($candidates | ForEach-Object {
                "$($_.FriendlyName)  [$($_.GdiName)]"
            }) -join "`n"

            Show-Info "Es wurden mehrere passende Monitore gefunden. Zur Sicherheit wird keiner automatisch gebunden:`n`n$desc`n`nEs wurde nichts verändert."
            exit 11
        }

        $c = $candidates[0]

        $config = [PSCustomObject]@{
            Version            = 2
            FriendlyName       = $c.FriendlyName
            DevicePath         = $c.DevicePath
            EdidManufacturerId = $c.EdidManufacturerId
            EdidProductCodeId  = $c.EdidProductCodeId
            ConnectorInstance  = $c.ConnectorInstance
            BoundAt            = (Get-Date).ToString('o')
        }

        $config | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding UTF8

        if ($BindOnly) {
            Show-Info "Monitor wurde gespeichert:`n`n$($c.FriendlyName)`n$($c.GdiName)`n`nAb jetzt wird ausschließlich genau dieser aktive Display-Pfad umgeschaltet."
            exit 0
        }
    }

    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $active = @([DisplayConfigNative]::GetActiveMonitors())

    # Exact target-path match. If the monitor is absent, there is deliberately NO fallback.
    $target = @($active | Where-Object {
        $_.DevicePath -eq $config.DevicePath
    })

    if ($target.Count -eq 0) {
        Show-Info "Der gespeicherte Ultrawide-Monitor ist aktuell nicht angeschlossen bzw. nicht aktiv.`n`nEs wurde KEIN anderer Monitor verändert."
        exit 20
    }

    if ($target.Count -gt 1) {
        Show-Info "Der gespeicherte Monitorpfad wurde unerwartet mehrfach gefunden.`n`nAus Sicherheitsgründen wurde nichts verändert."
        exit 21
    }

    $m = $target[0]

    if ($BindOnly) {
        Show-Info "Gespeicherter Monitor ist aktiv:`n`n$($m.FriendlyName)`n$($m.GdiName)`nAktuell: $($m.Width) × $($m.Height) @ $($m.Frequency) Hz"
        exit 0
    }

    if ($RestoreNative) {
        if ($m.Width -eq 5120 -and $m.Height -eq 1440) {
            exit 0
        }

        if ($m.Width -ne 2560 -or $m.Height -ne 1440) {
            Show-Info "Der gespeicherte Monitor läuft aktuell mit $($m.Width) × $($m.Height).`n`nDie automatische Wiederherstellung setzt nur von 2560 × 1440 auf 5120 × 1440 zurück. Es wurde nichts verändert."
            exit 22
        }

        $rc = [DisplayConfigNative]::SetCcdResolution(
            $m.GdiName,
            5120,
            1440,
            $false
        )

        if ($rc -ne 0) {
            Show-ErrorMessage "Windows DisplayConfig hat die Wiederherstellung auf 5120 × 1440 abgelehnt.`n`nFehlercode: $rc`n`nEs wurde kein anderer Monitor verändert."
            exit 30
        }

        exit 0
    }

    if ($m.Width -eq 5120 -and $m.Height -eq 1440) {
        $newWidth = 2560
        $newHeight = 1440
    }
    elseif ($m.Width -eq 2560 -and $m.Height -eq 1440) {
        $newWidth = 5120
        $newHeight = 1440
    }
    else {
        Show-Info "Der gespeicherte Monitor läuft aktuell mit $($m.Width) × $($m.Height).`n`nDas Skript schaltet ausschließlich zwischen 5120 × 1440 und 2560 × 1440. Es wurde nichts verändert."
        exit 22
    }

    $centerLowerResolution = ($newWidth -eq 2560 -and $newHeight -eq 1440)

    $rc = [DisplayConfigNative]::SetCcdResolution(
        $m.GdiName,
        $newWidth,
        $newHeight,
        $centerLowerResolution
    )

    if ($rc -ne 0) {
        Show-ErrorMessage "Windows DisplayConfig hat den Wechsel auf $newWidth × $newHeight abgelehnt.`n`nFehlercode: $rc`n`nEs wurde kein anderer Monitor verändert."
        exit 30
    }
}
catch {
    $msg = $_.Exception.Message
    try {
        $details = $_ | Out-String
        $details | Set-Content -Path $DiagPath -Encoding UTF8
    } catch {}

    Show-ErrorMessage "Das Skript ist unerwartet abgebrochen:`n`n$msg`n`nDetails wurden – soweit möglich – hier gespeichert:`n$DiagPath"
    exit 99
}
