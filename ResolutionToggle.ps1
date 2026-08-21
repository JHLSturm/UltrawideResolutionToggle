param(
    [switch]$Register,
    [switch]$Manage,
    [switch]$Diagnose,
    [switch]$RestoreNative,
    [switch]$List,
    [switch]$Reset,
    [string]$RemoveDevicePath
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

$AppDir = Join-Path $env:LOCALAPPDATA 'ResolutionToggle'
$ConfigPath = Join-Path $AppDir 'config.json'
$DiagPath = Join-Path ([Environment]::GetFolderPath('Desktop')) 'UltrawideResolutionToggle-Diagnose.txt'
$DefaultReducedWidth = 2560
$DefaultReducedHeight = 1440

New-Item -ItemType Directory -Path $AppDir -Force | Out-Null

function Show-Info([string]$Text, [string]$Title = 'Ultrawide-Aufloesung') {
    [System.Windows.Forms.MessageBox]::Show(
        $Text, $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-ErrorMessage([string]$Text) {
    [System.Windows.Forms.MessageBox]::Show(
        $Text, 'Ultrawide-Aufloesung - Fehler',
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
    public const uint MONITOR_DEFAULTTONULL = 0x00000000;

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

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int x;
        public int y;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct MONITORINFOEX {
        public int cbSize;
        public RECT rcMonitor;
        public RECT rcWork;
        public uint dwFlags;

        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string szDevice;
    }

    public class ActiveMonitor {
        public string GdiName;
        public string FriendlyName;
        public string DevicePath;
        public uint EdidManufacturerId;
        public uint EdidProductCodeId;
        public uint ConnectorInstance;
        public uint OutputTechnology;
        public int Width;
        public int Height;
        public int Frequency;
        public int SourceX;
        public int SourceY;
        public int DisplayConfigSourceWidth;
        public int DisplayConfigSourceHeight;
        public int TargetWidth;
        public int TargetHeight;
        public uint Scaling;
        public uint AdapterLowPart;
        public int AdapterHighPart;
        public uint SourceId;
        public uint TargetId;
    }

    public class ModeInfo {
        public int Width;
        public int Height;
        public int Frequency;
    }

    public class CursorMonitorInfo {
        public bool Found;
        public int X;
        public int Y;
        public string GdiName;
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
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

    [DllImport("user32.dll")]
    static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("user32.dll")]
    static extern IntPtr MonitorFromPoint(POINT pt, uint dwFlags);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool GetMonitorInfo(IntPtr hMonitor, ref MONITORINFOEX lpmi);

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

    static DISPLAYCONFIG_SOURCE_DEVICE_NAME NewSourceName(DISPLAYCONFIG_PATH_INFO path) {
        DISPLAYCONFIG_SOURCE_DEVICE_NAME src = new DISPLAYCONFIG_SOURCE_DEVICE_NAME();
        src.viewGdiDeviceName = new string('\0', 32);
        src.header.type = 1;
        src.header.size = (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_SOURCE_DEVICE_NAME));
        src.header.adapterId = path.sourceInfo.adapterId;
        src.header.id = path.sourceInfo.id;
        return src;
    }

    static DISPLAYCONFIG_TARGET_DEVICE_NAME NewTargetName(DISPLAYCONFIG_PATH_INFO path) {
        DISPLAYCONFIG_TARGET_DEVICE_NAME tgt = new DISPLAYCONFIG_TARGET_DEVICE_NAME();
        tgt.monitorFriendlyDeviceName = new string('\0', 64);
        tgt.monitorDevicePath = new string('\0', 128);
        tgt.header.type = 2;
        tgt.header.size = (uint)Marshal.SizeOf(typeof(DISPLAYCONFIG_TARGET_DEVICE_NAME));
        tgt.header.adapterId = path.targetInfo.adapterId;
        tgt.header.id = path.targetInfo.id;
        return tgt;
    }

    public static string ValidateNativeLayouts() {
        int sourceSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_PATH_SOURCE_INFO));
        int targetSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_PATH_TARGET_INFO));
        int pathSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_PATH_INFO));
        int modeSize = Marshal.SizeOf(typeof(DISPLAYCONFIG_MODE_INFO));

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

    public static CursorMonitorInfo GetCursorMonitor() {
        CursorMonitorInfo result = new CursorMonitorInfo();
        POINT pt;

        if (!GetCursorPos(out pt)) {
            result.Found = false;
            return result;
        }

        result.X = pt.x;
        result.Y = pt.y;

        IntPtr hMonitor = MonitorFromPoint(pt, MONITOR_DEFAULTTONULL);
        if (hMonitor == IntPtr.Zero) {
            result.Found = false;
            return result;
        }

        MONITORINFOEX info = new MONITORINFOEX();
        info.cbSize = Marshal.SizeOf(typeof(MONITORINFOEX));
        info.szDevice = new string('\0', 32);

        if (!GetMonitorInfo(hMonitor, ref info)) {
            result.Found = false;
            return result;
        }

        result.Found = true;
        result.GdiName = Clean(info.szDevice);
        result.Left = info.rcMonitor.left;
        result.Top = info.rcMonitor.top;
        result.Right = info.rcMonitor.right;
        result.Bottom = info.rcMonitor.bottom;
        return result;
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

            for (int i = 0; i < (int)pathCount; i++) {
                DISPLAYCONFIG_PATH_INFO p = paths[i];

                DISPLAYCONFIG_SOURCE_DEVICE_NAME src = NewSourceName(p);
                int srcRc = DisplayConfigGetSourceDeviceInfo(ref src);
                if (srcRc != ERROR_SUCCESS)
                    continue;

                DISPLAYCONFIG_TARGET_DEVICE_NAME tgt = NewTargetName(p);
                int tgtRc = DisplayConfigGetTargetDeviceInfo(ref tgt);
                if (tgtRc != ERROR_SUCCESS)
                    continue;

                string gdi = Clean(src.viewGdiDeviceName);
                DEVMODE current = NewDevMode();
                int width = 0;
                int height = 0;
                int frequency = 0;
                int sourceX = 0;
                int sourceY = 0;
                int displayConfigSourceWidth = 0;
                int displayConfigSourceHeight = 0;
                int targetWidth = 0;
                int targetHeight = 0;

                if (EnumDisplaySettings(gdi, ENUM_CURRENT_SETTINGS, ref current)) {
                    width = current.dmPelsWidth;
                    height = current.dmPelsHeight;
                    frequency = current.dmDisplayFrequency;
                    sourceX = current.dmPositionX;
                    sourceY = current.dmPositionY;
                }

                uint sourceIndex = p.sourceInfo.modeInfoIdx;
                if (sourceIndex < modeCount && modes[sourceIndex].infoType == DISPLAYCONFIG_MODE_INFO_TYPE_SOURCE) {
                    DISPLAYCONFIG_SOURCE_MODE sourceMode = modes[sourceIndex].modeInfo.sourceMode;
                    displayConfigSourceWidth = (int)sourceMode.width;
                    displayConfigSourceHeight = (int)sourceMode.height;
                    if (width <= 0 || height <= 0) {
                        width = displayConfigSourceWidth;
                        height = displayConfigSourceHeight;
                    }
                    sourceX = sourceMode.position.x;
                    sourceY = sourceMode.position.y;
                }

                uint targetIndex = p.targetInfo.modeInfoIdx;
                if (targetIndex < modeCount && modes[targetIndex].infoType == DISPLAYCONFIG_MODE_INFO_TYPE_TARGET) {
                    DISPLAYCONFIG_TARGET_MODE targetMode = modes[targetIndex].modeInfo.targetMode;
                    targetWidth = (int)targetMode.targetVideoSignalInfo.activeSize.cx;
                    targetHeight = (int)targetMode.targetVideoSignalInfo.activeSize.cy;
                }

                result.Add(new ActiveMonitor {
                    GdiName = gdi,
                    FriendlyName = Clean(tgt.monitorFriendlyDeviceName),
                    DevicePath = Clean(tgt.monitorDevicePath),
                    EdidManufacturerId = tgt.edidManufactureId,
                    EdidProductCodeId = tgt.edidProductCodeId,
                    ConnectorInstance = tgt.connectorInstance,
                    OutputTechnology = tgt.outputTechnology,
                    Width = width,
                    Height = height,
                    Frequency = frequency,
                    SourceX = sourceX,
                    SourceY = sourceY,
                    DisplayConfigSourceWidth = displayConfigSourceWidth,
                    DisplayConfigSourceHeight = displayConfigSourceHeight,
                    TargetWidth = targetWidth,
                    TargetHeight = targetHeight,
                    Scaling = p.targetInfo.scaling,
                    AdapterLowPart = p.targetInfo.adapterId.LowPart,
                    AdapterHighPart = p.targetInfo.adapterId.HighPart,
                    SourceId = p.sourceInfo.id,
                    TargetId = p.targetInfo.id
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

    public static int ValidateCcdResolution(
        string gdiName,
        string expectedDevicePath,
        int width,
        int height,
        bool center)
    {
        return ChangeCcdResolution(gdiName, expectedDevicePath, width, height, center, false);
    }

    public static int SetCcdResolution(
        string gdiName,
        string expectedDevicePath,
        int width,
        int height,
        bool center)
    {
        return ChangeCcdResolution(gdiName, expectedDevicePath, width, height, center, true);
    }

    static int ChangeCcdResolution(
        string gdiName,
        string expectedDevicePath,
        int width,
        int height,
        bool center,
        bool apply)
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

            for (int i = 0; i < (int)pathCount; i++) {
                DISPLAYCONFIG_SOURCE_DEVICE_NAME src = NewSourceName(paths[i]);
                int srcRc = DisplayConfigGetSourceDeviceInfo(ref src);
                if (srcRc != ERROR_SUCCESS)
                    continue;

                if (!String.Equals(Clean(src.viewGdiDeviceName), gdiName, StringComparison.OrdinalIgnoreCase))
                    continue;

                DISPLAYCONFIG_TARGET_DEVICE_NAME tgt = NewTargetName(paths[i]);
                int tgtRc = DisplayConfigGetTargetDeviceInfo(ref tgt);
                if (tgtRc != ERROR_SUCCESS)
                    continue;

                if (!String.Equals(Clean(tgt.monitorDevicePath), expectedDevicePath, StringComparison.OrdinalIgnoreCase))
                    return -204;

                pathIndex = i;
                break;
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
                SDC_VALIDATE;

            rc = SetDisplayConfig(
                pathCount,
                paths,
                modeCount,
                modes,
                validateFlags);

            if (rc != ERROR_SUCCESS)
                return rc;

            if (!apply)
                return ERROR_SUCCESS;

            uint applyFlags =
                SDC_USE_SUPPLIED_DISPLAY_CONFIG |
                SDC_APPLY |
                SDC_SAVE_TO_DATABASE;

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

function Initialize-NativeApi {
    if (-not ('DisplayConfigNative' -as [type])) {
        Add-Type -TypeDefinition $code -Language CSharp
    }

    $layoutError = [DisplayConfigNative]::ValidateNativeLayouts()
    if (-not [string]::IsNullOrWhiteSpace($layoutError)) {
        throw "Interner DisplayConfig-Strukturfehler: $layoutError"
    }
}

function New-DefaultConfig {
    [PSCustomObject]@{
        Version = 3
        UpdatedAt = (Get-Date).ToString('o')
        Monitors = @()
    }
}

function Read-Config {
    if (-not (Test-Path $ConfigPath)) {
        return (New-DefaultConfig)
    }

    $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    if ($null -eq $config.Monitors) {
        $config | Add-Member -MemberType NoteProperty -Name Monitors -Value @()
    }
    return $config
}

function Write-Config($Config) {
    $Config.UpdatedAt = (Get-Date).ToString('o')
    $Config | ConvertTo-Json -Depth 8 | Set-Content -Path $ConfigPath -Encoding UTF8
}

function Get-StableMonitorId([string]$DevicePath) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($DevicePath.ToLowerInvariant())
        $hashBytes = $sha.ComputeHash($bytes)
        return (($hashBytes | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 16)
    }
    finally {
        $sha.Dispose()
    }
}

function Get-ScalingName([uint32]$Scaling) {
    switch ($Scaling) {
        1 { 'identity' }
        2 { 'centered' }
        3 { 'stretched' }
        4 { 'aspect-ratio-centered-max' }
        5 { 'custom' }
        128 { 'preferred' }
        default { "unknown-$Scaling" }
    }
}

function Get-RegisteredMonitors($Config) {
    return @($Config.Monitors)
}

function Find-RegisteredConfigForActive($Config, $ActiveMonitor) {
    @($Config.Monitors | Where-Object {
        [string]::Equals($_.DevicePath, $ActiveMonitor.DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
    })
}

function Get-ActiveRegisteredMonitors($Config) {
    $active = @([DisplayConfigNative]::GetActiveMonitors())
    $result = @()

    foreach ($registered in @($Config.Monitors)) {
        $matches = @($active | Where-Object {
            [string]::Equals($_.DevicePath, $registered.DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
        })

        if ($matches.Count -eq 1) {
            $result += [PSCustomObject]@{
                Config = $registered
                Active = $matches[0]
            }
        }
        elseif ($matches.Count -gt 1) {
            throw "Ein registrierter DevicePath wurde mehrfach gefunden: $($registered.DevicePath)"
        }
    }

    return @($result)
}

function Get-CursorActiveMonitor {
    $cursor = [DisplayConfigNative]::GetCursorMonitor()
    if (-not $cursor.Found) {
        return [PSCustomObject]@{ Cursor = $cursor; Active = $null }
    }

    $active = @([DisplayConfigNative]::GetActiveMonitors())
    $match = @($active | Where-Object {
        [string]::Equals($_.GdiName, $cursor.GdiName, [System.StringComparison]::OrdinalIgnoreCase)
    })

    if ($match.Count -eq 1) {
        return [PSCustomObject]@{ Cursor = $cursor; Active = $match[0] }
    }

    return [PSCustomObject]@{ Cursor = $cursor; Active = $null }
}

function Get-NativeResolution($ActiveMonitor) {
    if ($ActiveMonitor.TargetWidth -gt 0 -and $ActiveMonitor.TargetHeight -gt 0) {
        return [PSCustomObject]@{ Width = $ActiveMonitor.TargetWidth; Height = $ActiveMonitor.TargetHeight; Source = 'DisplayConfig target active size' }
    }

    $modes = @([DisplayConfigNative]::GetModes($ActiveMonitor.GdiName))
    $best = $modes | Sort-Object @{ Expression = { $_.Width * $_.Height }; Descending = $true }, Width -Descending | Select-Object -First 1
    if ($null -ne $best) {
        return [PSCustomObject]@{ Width = $best.Width; Height = $best.Height; Source = 'largest enumerated mode' }
    }

    return [PSCustomObject]@{ Width = $ActiveMonitor.Width; Height = $ActiveMonitor.Height; Source = 'current source size' }
}

function Assert-ModeSupported($ActiveMonitor, [int]$Width, [int]$Height) {
    if (-not [DisplayConfigNative]::Supports($ActiveMonitor.GdiName, $Width, $Height)) {
        throw "$($ActiveMonitor.FriendlyName) [$($ActiveMonitor.GdiName)] meldet $Width x $Height nicht als unterstuetzten Source-Modus."
    }
}

function Assert-DisplayConfigResolutionValid($ActiveMonitor, [string]$DevicePath, [int]$Width, [int]$Height, [bool]$Center) {
    $rc = [DisplayConfigNative]::ValidateCcdResolution(
        $ActiveMonitor.GdiName,
        $DevicePath,
        $Width,
        $Height,
        $Center
    )

    if ($rc -ne 0) {
        $modeListHint = if ([DisplayConfigNative]::Supports($ActiveMonitor.GdiName, $Width, $Height)) {
            'Der Modus wird von EnumDisplaySettings gemeldet.'
        }
        else {
            'Der Modus wird von EnumDisplaySettings nicht gemeldet.'
        }

        throw "$($ActiveMonitor.FriendlyName) [$($ActiveMonitor.GdiName)] hat die DisplayConfig-Validierung fuer $Width x $Height abgelehnt. Fehlercode: $rc. $modeListHint"
    }
}

function Register-MonitorUnderCursor {
    param(
        [bool]$FromToggle = $false
    )

    Initialize-NativeApi

    $cursorInfo = Get-CursorActiveMonitor
    $cursor = $cursorInfo.Cursor
    $active = $cursorInfo.Active

    if (-not $cursor.Found -or $null -eq $active) {
        Show-Info "Der Monitor unter dem Mauszeiger konnte nicht eindeutig einer aktiven DisplayConfig-Anzeige zugeordnet werden.`n`nEs wurde nichts registriert."
        exit 40
    }

    $native = Get-NativeResolution $active
    $reducedWidth = $DefaultReducedWidth
    $reducedHeight = $DefaultReducedHeight

    if ($native.Width -le $reducedWidth -or $native.Height -ne $reducedHeight) {
        Show-Info "Der Bildschirm unter dem Mauszeiger ist kein passender 1440p-Ultrawide.`n`nErkannt: $($active.FriendlyName) [$($active.GdiName)]`nNative Aufloesung: $($native.Width) x $($native.Height)`n`nEs wurde nichts registriert."
        exit 41
    }

    Assert-DisplayConfigResolutionValid $active $active.DevicePath $native.Width $native.Height $false
    Assert-DisplayConfigResolutionValid $active $active.DevicePath $reducedWidth $reducedHeight $true

    $config = Read-Config
    $id = Get-StableMonitorId $active.DevicePath
    $entry = [PSCustomObject]@{
        Id = $id
        FriendlyName = $active.FriendlyName
        DevicePath = $active.DevicePath
        EdidManufacturerId = $active.EdidManufacturerId
        EdidProductCodeId = $active.EdidProductCodeId
        ConnectorInstance = $active.ConnectorInstance
        OutputTechnology = $active.OutputTechnology
        NativeWidth = $native.Width
        NativeHeight = $native.Height
        NativeDetectedFrom = $native.Source
        ReducedWidth = $reducedWidth
        ReducedHeight = $reducedHeight
        Scaling = 'centered'
        RegisteredAt = (Get-Date).ToString('o')
        LastSeenGdiName = $active.GdiName
    }

    $existing = @($config.Monitors | Where-Object {
        [string]::Equals($_.DevicePath, $active.DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
    })

    if ($existing.Count -gt 1) {
        throw "Die Konfiguration enthaelt denselben DevicePath mehrfach. Bitte Manage-Monitors.cmd zum Bereinigen verwenden."
    }

    if ($existing.Count -eq 1) {
        $remaining = @($config.Monitors | Where-Object {
            -not [string]::Equals($_.DevicePath, $active.DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
        })
        $config.Monitors = @($remaining + $entry)
        Write-Config $config
        Show-Info "Monitor wurde aktualisiert:`n`n$($entry.FriendlyName)`n$($entry.LastSeenGdiName)`n$($entry.NativeWidth) x $($entry.NativeHeight) <-> $($entry.ReducedWidth) x $($entry.ReducedHeight)"
        return
    }

    $config.Monitors = @(@($config.Monitors) + $entry)
    Write-Config $config

    if ($FromToggle) {
        Show-Info "Monitor wurde registriert:`n`n$($entry.FriendlyName)`n$($entry.LastSeenGdiName)`n$($entry.NativeWidth) x $($entry.NativeHeight) <-> $($entry.ReducedWidth) x $($entry.ReducedHeight)`n`nDie Aufloesung wurde noch nicht veraendert. Druecke den Toggle erneut, um diesen Monitor umzuschalten."
        return
    }

    Show-Info "Monitor wurde registriert:`n`n$($entry.FriendlyName)`n$($entry.LastSeenGdiName)`n$($entry.NativeWidth) x $($entry.NativeHeight) <-> $($entry.ReducedWidth) x $($entry.ReducedHeight)`n`nEs werden weiterhin ausschliesslich registrierte DevicePaths umgeschaltet."
}

function Select-ToggleTarget {
    param($Config)

    $activeRegistered = @(Get-ActiveRegisteredMonitors $Config)

    if ($activeRegistered.Count -eq 0) {
        Show-Info "Kein registrierter Ultrawide-Monitor ist aktuell angeschlossen."
        exit 20
    }

    if ($activeRegistered.Count -eq 1) {
        return $activeRegistered[0]
    }

    $cursor = [DisplayConfigNative]::GetCursorMonitor()
    if (-not $cursor.Found) {
        Show-Info "Der aktuelle Bildschirm konnte nicht ermittelt werden.`n`nEs wurde nichts veraendert."
        exit 21
    }

    $matches = @($activeRegistered | Where-Object {
        [string]::Equals($_.Active.GdiName, $cursor.GdiName, [System.StringComparison]::OrdinalIgnoreCase)
    })

    if ($matches.Count -eq 1) {
        return $matches[0]
    }

    Show-Info "Der aktuelle Bildschirm ist nicht fuer die Aufloesungsumschaltung registriert."
    exit 22
}

function Invoke-ResolutionChange($Pair, [int]$Width, [int]$Height, [bool]$Center) {
    $active = $Pair.Active
    $registered = $Pair.Config

    Assert-DisplayConfigResolutionValid $active $registered.DevicePath $Width $Height $Center

    $rc = [DisplayConfigNative]::SetCcdResolution(
        $active.GdiName,
        $registered.DevicePath,
        $Width,
        $Height,
        $Center
    )

    if ($rc -ne 0) {
        Show-ErrorMessage "Windows DisplayConfig hat den Wechsel auf $Width x $Height abgelehnt.`n`nFehlercode: $rc`n`nEs wurde kein anderer Monitor veraendert."
        exit 30
    }

    Start-Sleep -Milliseconds 700

    $after = @([DisplayConfigNative]::GetActiveMonitors() | Where-Object {
        [string]::Equals($_.DevicePath, $registered.DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
    })

    if ($after.Count -ne 1) {
        Show-ErrorMessage "Der Zielmonitor konnte nach dem Wechsel nicht mehr eindeutig gefunden werden.`n`nAngefordert war $Width x $Height. Bitte Diagnose.cmd ausfuehren."
        exit 31
    }

    if ($after[0].Width -ne $Width -or $after[0].Height -ne $Height) {
        Show-ErrorMessage "Windows hat nicht die angeforderte Aufloesung gesetzt.`n`nAngefordert: $Width x $Height`nTatsaechlich: $($after[0].Width) x $($after[0].Height)`n`nBitte Diagnose.cmd ausfuehren. Es wurde kein weiterer Monitor veraendert."
        exit 32
    }
}

function Toggle-SelectedMonitor {
    Initialize-NativeApi
    $config = Read-Config
    $registered = @(Get-RegisteredMonitors $config)

    if ($registered.Count -eq 0) {
        Register-MonitorUnderCursor $true
        exit 0
    }

    $pair = Select-ToggleTarget $config
    $active = $pair.Active
    $monitor = $pair.Config

    $nativeWidth = [int]$monitor.NativeWidth
    $nativeHeight = [int]$monitor.NativeHeight
    $reducedWidth = [int]$monitor.ReducedWidth
    $reducedHeight = [int]$monitor.ReducedHeight

    if ($active.Width -eq $nativeWidth -and $active.Height -eq $nativeHeight) {
        Invoke-ResolutionChange $pair $reducedWidth $reducedHeight $true
        exit 0
    }

    if ($active.Width -eq $reducedWidth -and $active.Height -eq $reducedHeight) {
        Invoke-ResolutionChange $pair $nativeWidth $nativeHeight $false
        exit 0
    }

    Show-Info "Der registrierte Monitor laeuft aktuell mit $($active.Width) x $($active.Height).`n`nDieses Profil schaltet nur zwischen $nativeWidth x $nativeHeight und $reducedWidth x $reducedHeight.`n`nEs wurde nichts veraendert."
    exit 23
}

function Restore-NativeForRegistered {
    Initialize-NativeApi
    $config = Read-Config
    $activeRegistered = @(Get-ActiveRegisteredMonitors $config)

    foreach ($pair in $activeRegistered) {
        $active = $pair.Active
        $monitor = $pair.Config
        $nativeWidth = [int]$monitor.NativeWidth
        $nativeHeight = [int]$monitor.NativeHeight
        $reducedWidth = [int]$monitor.ReducedWidth
        $reducedHeight = [int]$monitor.ReducedHeight

        if ($active.Width -eq $nativeWidth -and $active.Height -eq $nativeHeight) {
            continue
        }

        if ($active.Width -eq $reducedWidth -and $active.Height -eq $reducedHeight) {
            Invoke-ResolutionChange $pair $nativeWidth $nativeHeight $false
        }
    }
}

function Write-MonitorList {
    Initialize-NativeApi
    $config = Read-Config
    $active = @([DisplayConfigNative]::GetActiveMonitors())
    $registered = @(Get-RegisteredMonitors $config)

    Write-Host ''
    Write-Host 'Registrierte Ultrawide-Monitore'
    Write-Host '================================'
    if ($registered.Count -eq 0) {
        Write-Host 'Keine registrierten Monitore.'
        return
    }

    for ($i = 0; $i -lt $registered.Count; $i++) {
        $r = $registered[$i]
        $isActive = @($active | Where-Object {
            [string]::Equals($_.DevicePath, $r.DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
        }).Count -eq 1
        $state = if ($isActive) { 'aktiv' } else { 'nicht aktiv' }
        Write-Host ("[{0}] {1} - {2} x {3} <-> {4} x {5} - {6}" -f ($i + 1), $r.FriendlyName, $r.NativeWidth, $r.NativeHeight, $r.ReducedWidth, $r.ReducedHeight, $state)
        Write-Host ("    DevicePath: {0}" -f $r.DevicePath)
    }
}

function Remove-RegisteredMonitorByDevicePath([string]$DevicePath) {
    $config = Read-Config
    $before = @($config.Monitors).Count
    $config.Monitors = @($config.Monitors | Where-Object {
        -not [string]::Equals($_.DevicePath, $DevicePath, [System.StringComparison]::OrdinalIgnoreCase)
    })
    $after = @($config.Monitors).Count
    Write-Config $config
    return ($before -ne $after)
}

function Reset-Configuration {
    $config = New-DefaultConfig
    Write-Config $config
}

function Invoke-Manage {
    Initialize-NativeApi

    while ($true) {
        Write-MonitorList
        Write-Host ''
        Write-Host 'Aktionen:'
        Write-Host '  R = Monitor per Nummer entfernen'
        Write-Host '  C = Konfiguration komplett zuruecksetzen'
        Write-Host '  Q = Beenden'
        $choice = Read-Host 'Auswahl'

        if ([string]::IsNullOrWhiteSpace($choice)) {
            continue
        }

        switch -Regex ($choice.Trim()) {
            '^[Qq]$' { return }
            '^[Cc]$' {
                $confirm = Read-Host 'Wirklich alle Registrierungen entfernen? Tippe JA'
                if ($confirm -eq 'JA') {
                    Reset-Configuration
                    Write-Host 'Konfiguration wurde zurueckgesetzt.'
                }
            }
            '^[Rr]$' {
                $config = Read-Config
                $registered = @(Get-RegisteredMonitors $config)
                if ($registered.Count -eq 0) {
                    Write-Host 'Keine registrierten Monitore.'
                    continue
                }

                $numberText = Read-Host 'Nummer des zu entfernenden Monitors'
                $number = 0
                if (-not [int]::TryParse($numberText, [ref]$number) -or $number -lt 1 -or $number -gt $registered.Count) {
                    Write-Host 'Ungueltige Nummer.'
                    continue
                }

                $target = $registered[$number - 1]
                if (Remove-RegisteredMonitorByDevicePath $target.DevicePath) {
                    Write-Host 'Monitor wurde entfernt.'
                }
            }
            default {
                Write-Host 'Ungueltige Auswahl.'
            }
        }
    }
}

function Write-Diagnosis {
    Initialize-NativeApi

    $lines = New-Object System.Collections.Generic.List[string]
    $layoutCheck = [DisplayConfigNative]::ValidateNativeLayouts()
    if ([string]::IsNullOrWhiteSpace($layoutCheck)) {
        $layoutCheck = 'OK'
    }

    $config = Read-Config
    $active = @([DisplayConfigNative]::GetActiveMonitors())
    $cursor = [DisplayConfigNative]::GetCursorMonitor()
    $cursorActive = $null
    if ($cursor.Found) {
        $cursorActive = @($active | Where-Object {
            [string]::Equals($_.GdiName, $cursor.GdiName, [System.StringComparison]::OrdinalIgnoreCase)
        } | Select-Object -First 1)
    }

    $lines.Add('Ultrawide Resolution Toggle - Diagnose')
    $lines.Add('======================================')
    $lines.Add(('Zeit: ' + (Get-Date)))
    $lines.Add(('PowerShell-Version: ' + $PSVersionTable.PSVersion))
    $lines.Add(('ConfigPath: ' + $ConfigPath))
    $lines.Add(('Native-Struct-Layout-Pruefung: ' + $layoutCheck))
    $lines.Add('')

    $lines.Add('Monitor unter dem Mauszeiger:')
    if ($cursor.Found) {
        $lines.Add(('  Position: {0},{1}' -f $cursor.X, $cursor.Y))
        $lines.Add(('  GDI Name: ' + $cursor.GdiName))
        $lines.Add(('  Bounds: {0},{1} - {2},{3}' -f $cursor.Left, $cursor.Top, $cursor.Right, $cursor.Bottom))
        if ($null -ne $cursorActive) {
            $cursorRegistered = @(Find-RegisteredConfigForActive $config $cursorActive).Count -eq 1
            $lines.Add(('  DisplayConfig-Zuordnung: ' + $cursorActive.DevicePath))
            $lines.Add(('  Registriert: ' + $(if ($cursorRegistered) { 'ja' } else { 'nein' })))
        }
        else {
            $lines.Add('  DisplayConfig-Zuordnung: nicht gefunden')
        }
    }
    else {
        $lines.Add('  Nicht ermittelt')
    }
    $lines.Add('')

    $lines.Add(('Aktive Displays: ' + $active.Count))
    foreach ($m in $active) {
        $registeredMatches = @(Find-RegisteredConfigForActive $config $m)
        $registeredText = if ($registeredMatches.Count -eq 1) { 'ja' } else { 'nein' }
        $registeredConfig = if ($registeredMatches.Count -eq 1) { $registeredMatches[0] } else { $null }

        $lines.Add('')
        $lines.Add(('Friendly Name: ' + $m.FriendlyName))
        $lines.Add(('GDI Name: ' + $m.GdiName))
        $lines.Add(('DevicePath: ' + $m.DevicePath))
        $lines.Add(('EDID Manufacturer: ' + $m.EdidManufacturerId))
        $lines.Add(('EDID Product: ' + $m.EdidProductCodeId))
        $lines.Add(('Connector: ' + $m.ConnectorInstance))
        $lines.Add(('OutputTechnology: ' + $m.OutputTechnology))
        $lines.Add(('Adapter LUID: {0}:{1}' -f $m.AdapterHighPart, $m.AdapterLowPart))
        $lines.Add(('Source Id: ' + $m.SourceId))
        $lines.Add(('Target Id: ' + $m.TargetId))
        $lines.Add(('Aktuelle Source-Aufloesung: {0} x {1} @ {2} Hz' -f $m.Width, $m.Height, $m.Frequency))
        $lines.Add(('DisplayConfig Source-Mode: {0} x {1}' -f $m.DisplayConfigSourceWidth, $m.DisplayConfigSourceHeight))
        $lines.Add(('Source-Position: {0},{1}' -f $m.SourceX, $m.SourceY))
        $lines.Add(('Aktuelle Target-Aufloesung: {0} x {1}' -f $m.TargetWidth, $m.TargetHeight))
        $lines.Add(('Scaling-Modus: {0} ({1})' -f $m.Scaling, (Get-ScalingName $m.Scaling)))
        $lines.Add(('Registriert: ' + $registeredText))

        if ($null -ne $registeredConfig) {
            $lines.Add(('Erkannte native Aufloesung: {0} x {1}' -f $registeredConfig.NativeWidth, $registeredConfig.NativeHeight))
            $lines.Add(('Reduzierte Aufloesung: {0} x {1}' -f $registeredConfig.ReducedWidth, $registeredConfig.ReducedHeight))
        }
    }

    $lines.Add('')
    $lines.Add('Gespeicherte Konfiguration:')
    if (Test-Path $ConfigPath) {
        $lines.Add((Get-Content $ConfigPath -Raw))
    }
    else {
        $lines.Add('Keine Konfiguration vorhanden.')
    }

    $lines | Set-Content -Path $DiagPath -Encoding UTF8
    Show-Info "Diagnose erstellt:`n`n$DiagPath`n`nEs wurden keine Anzeigeeinstellungen veraendert."
}

try {
    Initialize-NativeApi

    if ($Diagnose) {
        Write-Diagnosis
        exit 0
    }

    if ($Register) {
        Register-MonitorUnderCursor
        exit 0
    }

    if ($List) {
        Write-MonitorList
        exit 0
    }

    if ($Reset) {
        Reset-Configuration
        Write-Host 'Konfiguration wurde zurueckgesetzt.'
        exit 0
    }

    if (-not [string]::IsNullOrWhiteSpace($RemoveDevicePath)) {
        if (Remove-RegisteredMonitorByDevicePath $RemoveDevicePath) {
            Write-Host 'Monitor wurde entfernt.'
            exit 0
        }
        Write-Host 'Kein passender registrierter Monitor gefunden.'
        exit 1
    }

    if ($Manage) {
        Invoke-Manage
        exit 0
    }

    if ($RestoreNative) {
        Restore-NativeForRegistered
        exit 0
    }

    Toggle-SelectedMonitor
}
catch {
    $msg = $_.Exception.Message
    try {
        $details = $_ | Out-String
        $details | Set-Content -Path $DiagPath -Encoding UTF8
    } catch {}

    Show-ErrorMessage "Das Skript ist unerwartet abgebrochen:`n`n$msg`n`nDetails wurden - soweit moeglich - hier gespeichert:`n$DiagPath"
    exit 99
}
