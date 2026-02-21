<#
.SYNOPSIS
    Laedt alle Module im Benutzer-Module-Ordner neu (Update-Refresh).
#>

[CmdletBinding()]
param(
    [string]$ModuleRoot = "$env:USERPROFILE\Documents\PowerShell\Modules"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ModuleRoot)) {
    Write-Error "Modul-Root nicht gefunden: $ModuleRoot"
    exit 1
}

$modules = Get-ChildItem $ModuleRoot -Directory | Select-Object -ExpandProperty Name

foreach ($name in $modules) {
    if ($name -eq ".venv" -or $name -eq "venv") { continue }
    $psd1 = Join-Path $ModuleRoot "$name\$name.psd1"
    $psm1 = Join-Path $ModuleRoot "$name\$name.psm1"
    if (-not (Test-Path $psd1) -and -not (Test-Path $psm1)) {
        continue
    }
    if (Get-Module $name) {
        Remove-Module $name -Force -ErrorAction SilentlyContinue
    }
    try {
        Import-Module $name -Force -ErrorAction Stop
        Write-Host "Neu geladen: $name" -ForegroundColor Green
    }
    catch {
        Write-Warning "Konnte nicht laden: $name ($($_.Exception.Message))"
    }
}

Write-Host "Reload abgeschlossen." -ForegroundColor Cyan
