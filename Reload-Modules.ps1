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
