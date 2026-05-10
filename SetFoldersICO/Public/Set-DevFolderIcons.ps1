function Set-DevFolderIcons {
    <#
    .SYNOPSIS
        Generiert und wendet Icons fuer alle Unterordner eines Entwicklungsverzeichnisses an.
    .DESCRIPTION
        Scannt einen Basisordner nach Unterordnern und erstellt fuer jeden
        erkannten Technologie-Ordner eine passende ICO-Datei via Inkscape.

        Mit -ApplyToFolders werden die Icons vollstaendig eingerichtet:
          - ICO-Datei wird im jeweiligen Unterordner erstellt
          - ICO-Datei und desktop.ini erhalten Hidden+System-Attribute
          - Ordner erhaelt das System-Attribut

        Ohne -ApplyToFolders werden die ICO-Dateien nur im OutputPath abgelegt.
    .PARAMETER BasePath
        Basisverzeichnis mit den Entwicklungsordnern (Standard: ~\Development).
    .PARAMETER OutputPath
        Ausgabepfad fuer ICO-Dateien ohne -ApplyToFolders (Standard: BasePath).
    .PARAMETER InkscapePath
        Pfad zur inkscape.exe (ueberschreibt Auto-Erkennung).
    .PARAMETER IconSize
        Groesse der Icons in Pixeln: 16, 32, 48, 64, 128 oder 256 (Standard: 256).
    .PARAMETER Force
        Ueberschreibt vorhandene ICO-Dateien.
    .PARAMETER ApplyToFolders
        Wendet Icons direkt auf die Ordner an und erstellt desktop.ini.
        Alias: -ini
    .PARAMETER ApplyExistingIco
        Wendet vorhandene ICO-Dateien an, auch wenn Inkscape fehlt.
    .EXAMPLE
        Set-DevFolderIcons -BasePath 'C:\Dev' -ApplyToFolders
    .EXAMPLE
        sfdi -BasePath 'D:\Projects' -ini -Force
    .EXAMPLE
        Set-DevFolderIcons -ApplyToFolders -ApplyExistingIco
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$BasePath = "C:\Users\$env:USERNAME\Development",

        [string]$OutputPath,

        [string]$InkscapePath,

        [ValidateSet(16, 32, 48, 64, 128, 256)]
        [int]$IconSize = 256,

        [switch]$Force,

        [Alias('ini')]
        [switch]$ApplyToFolders,

        [switch]$ApplyExistingIco
    )

    if (-not (Test-Path $BasePath -PathType Container)) {
        Write-Error "Basispfad existiert nicht: $BasePath"
        return
    }

    if (-not $OutputPath) { $OutputPath = $BasePath }

    $inkscapeExe = if ($InkscapePath -and (Test-Path $InkscapePath)) {
        $InkscapePath
    } else {
        $script:DefaultInkscapePaths
    }

    if (-not $inkscapeExe -and -not $ApplyExistingIco) {
        Write-Error @'
Inkscape nicht gefunden!

Installation:
  - Download: https://inkscape.org/release/
  - Oder: choco install inkscape
  - Oder: winget install Inkscape.Inkscape

Nach Installation erneut ausfuehren oder -InkscapePath angeben.
'@
        return
    }

    Write-Host ''
    Write-Host '================================================================' -ForegroundColor Cyan
    Write-Host '  Development Folder Icon Generator  --  SetFoldersICO v1.0.0  ' -ForegroundColor Cyan
    Write-Host '================================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Basispfad : ' -ForegroundColor Yellow -NoNewline; Write-Host $BasePath
    Write-Host 'Ausgabe   : ' -ForegroundColor Yellow -NoNewline
    if ($ApplyToFolders) {
        Write-Host 'In jeweiligem Unterordner (versteckt)' -ForegroundColor Cyan
    } else {
        Write-Host $OutputPath
    }
    Write-Host 'Inkscape  : ' -ForegroundColor Yellow -NoNewline
    if ($inkscapeExe) { Write-Host $inkscapeExe } else { Write-Host 'nicht vorhanden (ApplyExistingIco)' -ForegroundColor Yellow }
    Write-Host 'Ikongroesse: ' -ForegroundColor Yellow -NoNewline; Write-Host "${IconSize}px"
    Write-Host 'desktop.ini: ' -ForegroundColor Yellow -NoNewline
    if ($ApplyToFolders) {
        Write-Host 'Ja (Icons + INI versteckt, Ordner mit System-Attribut)' -ForegroundColor Green
    } else {
        Write-Host 'Nein (nur ICO-Dateien im Ausgabeordner)' -ForegroundColor Gray
    }
    Write-Host ''

    $folders = Get-ChildItem -Path $BasePath -Directory | Sort-Object Name

    if ($folders.Count -eq 0) {
        Write-Warning "Keine Unterordner in $BasePath gefunden."
        return
    }

    Write-Host "[SCAN] Gefundene Ordner: $($folders.Count)" -ForegroundColor Cyan
    Write-Host ''
    Write-Host ('-' * 65) -ForegroundColor DarkGray

    $tempDir = Join-Path $env:TEMP "DevFolderIcons_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $successCount = 0
    $skipCount    = 0
    $errorCount   = 0

    foreach ($folder in $folders) {
        $folderName = $folder.Name

        if ($ApplyToFolders) {
            $icoPath = Join-Path $folder.FullName "$folderName.ico"
        } else {
            $icoPath = Join-Path $OutputPath "$folderName.ico"
        }

        if ((Test-Path $icoPath) -and -not $Force) {
            Write-Host '[>>] ' -ForegroundColor DarkGray -NoNewline
            Write-Host $folderName.PadRight(25) -ForegroundColor DarkGray -NoNewline
            Write-Host 'bereits vorhanden' -ForegroundColor DarkGray
            $skipCount++
            continue
        }

        if ((Test-Path $icoPath) -and $Force) {
            $existingIco = Get-Item $icoPath -Force
            $existingIco.Attributes = 'Normal'
        }

        $techMatch = Get-TechDefinition -FolderName $folderName

        if ($techMatch) {
            $definition = $techMatch.Definition
            $matchType  = '[+]'
            $matchColor = 'Green'
        } else {
            $definition = New-DynamicTechDefinition -FolderName $folderName
            $matchType  = '[~]'
            $matchColor = 'Yellow'
        }

        $success = $false
        if ($inkscapeExe) {
            $svgContent = Get-SvgTemplate -Abbreviation $definition.Abbr `
                                          -BackgroundColor $definition.BgColor `
                                          -ForegroundColor $definition.FgColor `
                                          -Size $IconSize
            $svgPath = Join-Path $tempDir "$folderName.svg"
            $svgContent | Out-File -FilePath $svgPath -Encoding UTF8 -Force

            $success = Convert-SvgToIco -SvgPath $svgPath `
                                        -IcoPath $icoPath `
                                        -InkscapePath $inkscapeExe `
                                        -Size $IconSize
        } elseif ($ApplyExistingIco -and (Test-Path $icoPath)) {
            $success = $true
        }

        if ($success) {
            Write-Host "$matchType " -ForegroundColor $matchColor -NoNewline
            Write-Host $folderName.PadRight(25) -NoNewline
            Write-Host '[' -NoNewline -ForegroundColor DarkGray
            Write-Host $definition.Abbr.PadRight(3) -NoNewline -ForegroundColor White
            Write-Host '] ' -NoNewline -ForegroundColor DarkGray
            Write-Host $definition.BgColor -NoNewline -ForegroundColor Cyan

            if ($ApplyToFolders) {
                $iniApplied = Set-FolderIcon -FolderPath $folder.FullName -IconPath $icoPath -Force
                if ($iniApplied) {
                    Write-Host ' -> ' -NoNewline -ForegroundColor DarkGray
                    Write-Host '[OK] ini' -NoNewline -ForegroundColor Green
                }
            }

            Write-Host ' -> ' -NoNewline -ForegroundColor DarkGray
            Write-Host $definition.Category -ForegroundColor DarkCyan

            $successCount++
        } else {
            Write-Host '[!!] ' -ForegroundColor Red -NoNewline
            Write-Host $folderName.PadRight(25) -NoNewline
            Write-Host 'Konvertierung fehlgeschlagen' -ForegroundColor Red
            $errorCount++
        }
    }

    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    if ($ApplyToFolders -and $successCount -gt 0) {
        Write-Host ''
        Write-Host '[~~] Aktualisiere Windows Icon-Cache...' -ForegroundColor Cyan
        $cacheRefreshed = Update-ExplorerIconCache
        if ($cacheRefreshed) {
            Write-Host '     [OK] Icon-Cache aktualisiert' -ForegroundColor Green
        } else {
            Write-Host '     [!]  Cache erfordert ggf. Explorer-Neustart' -ForegroundColor Yellow
        }
    }

    Write-Host ''
    Write-Host ('-' * 65) -ForegroundColor DarkGray
    Write-Host ''
    Write-Host 'Zusammenfassung:' -ForegroundColor Cyan
    Write-Host '   [OK]  Erfolgreich:  ' -NoNewline; Write-Host $successCount -ForegroundColor Green
    Write-Host '   [>>]  Uebersprungen:' -NoNewline; Write-Host $skipCount    -ForegroundColor Yellow
    Write-Host '   [!!]  Fehler:       ' -NoNewline; Write-Host $errorCount   -ForegroundColor Red
    Write-Host ''

    if ($successCount -gt 0 -and $ApplyToFolders) {
        Write-Host '[i] Angelegte Struktur:' -ForegroundColor Yellow
        Write-Host '   Ordner        -> System-Attribut' -ForegroundColor Gray
        Write-Host '   desktop.ini   -> Hidden + System'  -ForegroundColor Gray
        Write-Host '   [Name].ico    -> Hidden + System'  -ForegroundColor Gray
        Write-Host ''
    }
}
