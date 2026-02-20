<#
.SYNOPSIS
    Installiert das SetFoldersICO PowerShell-Modul.

.DESCRIPTION
    Kopiert das Modul in den PowerShell-Module-Ordner des Benutzers.
    Nach der Installation ist das Modul automatisch verfügbar.

.EXAMPLE
    .\Install-SetFoldersICO.ps1
#>

[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Modul-Pfad bestimmen
$modulePath = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\SetFoldersICO"

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     📦 SetFoldersICO - Modul-Installation                    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Prüfe ob bereits installiert
if ((Test-Path $modulePath) -and -not $Force) {
    Write-Host "⚠️  Modul bereits installiert in:" -ForegroundColor Yellow
    Write-Host "   $modulePath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Nutze -Force zum Überschreiben." -ForegroundColor Gray
    Write-Host ""
    return
}

# Quell-Dateien finden
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceFiles = @(
    (Join-Path $scriptDir "SetFoldersICO.psd1"),
    (Join-Path $scriptDir "SetFoldersICO.psm1")
)

foreach ($file in $sourceFiles) {
    if (-not (Test-Path $file)) {
        Write-Error "Quelldatei nicht gefunden: $file"
        return
    }
}

try {
    # Zielordner erstellen
    if (-not (Test-Path $modulePath)) {
        New-Item -ItemType Directory -Path $modulePath -Force | Out-Null
        Write-Host "✅ Modul-Ordner erstellt:" -ForegroundColor Green
        Write-Host "   $modulePath" -ForegroundColor Gray
    }
    
    # Dateien kopieren
    foreach ($file in $sourceFiles) {
        Copy-Item -Path $file -Destination $modulePath -Force
        $fileName = Split-Path $file -Leaf
        Write-Host "✅ Kopiert: $fileName" -ForegroundColor Green
    }
    
    # README kopieren (optional)
    $readmePath = Join-Path $scriptDir "README.md"
    if (Test-Path $readmePath) {
        Copy-Item -Path $readmePath -Destination $modulePath -Force
        Write-Host "✅ Kopiert: README.md" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ Installation erfolgreich!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 Installiert in:" -ForegroundColor Yellow
    Write-Host "   $modulePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 Verwendung:" -ForegroundColor Yellow
    Write-Host "   # Icons für alle Dev-Ordner erstellen und anwenden" -ForegroundColor Gray
    Write-Host "   Set-DevFolderIcons -BasePath 'C:\Dev' -ApplyToFolders" -ForegroundColor White
    Write-Host ""
    Write-Host "   # Kurzform" -ForegroundColor Gray
    Write-Host "   sfdi -BasePath 'C:\Dev' -ini" -ForegroundColor White
    Write-Host ""
    Write-Host "   # Hilfe anzeigen" -ForegroundColor Gray
    Write-Host "   Get-Help Set-DevFolderIcons -Full" -ForegroundColor White
    Write-Host ""
    Write-Host "   # Verfügbare Technologien anzeigen" -ForegroundColor Gray
    Write-Host "   Get-TechDefinitions | Format-Table" -ForegroundColor White
    Write-Host ""
    
    # Prüfe Inkscape
    $inkscapePaths = @(
        "C:\Program Files\Inkscape\bin\inkscape.exe",
        "C:\Program Files (x86)\Inkscape\bin\inkscape.exe",
        "$env:LOCALAPPDATA\Programs\Inkscape\bin\inkscape.exe"
    )
    
    $inkscapeFound = $inkscapePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if (-not $inkscapeFound) {
        Write-Host "⚠️  Hinweis: Inkscape nicht gefunden!" -ForegroundColor Yellow
        Write-Host "   Das Modul benötigt Inkscape für die Icon-Generierung." -ForegroundColor Gray
        Write-Host ""
        Write-Host "   Installation:" -ForegroundColor Gray
        Write-Host "   choco install inkscape" -ForegroundColor White
        Write-Host "   # oder" -ForegroundColor Gray
        Write-Host "   winget install Inkscape.Inkscape" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "✅ Inkscape gefunden: $inkscapeFound" -ForegroundColor Green
        Write-Host ""
    }
}
catch {
    Write-Error "Installation fehlgeschlagen: $_"
}
