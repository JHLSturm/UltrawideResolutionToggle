param(
    [Parameter(Mandatory = $true)]
    [string]$Key,
    [string[]]$TextArgs = @(),
    [switch]$BlankBefore,
    [switch]$BlankAfter,
    [switch]$Underline
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Localization.ps1')

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

if ($BlankBefore) {
    Write-Host
}

$text = Get-AppText -Key $Key -Args $TextArgs
Write-Host $text

if ($Underline) {
    Write-Host ('=' * $text.Length)
}

if ($BlankAfter) {
    Write-Host
}
