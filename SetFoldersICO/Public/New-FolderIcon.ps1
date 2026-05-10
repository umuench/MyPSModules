function New-FolderIcon {
    <#
    .SYNOPSIS
        Erstellt ein einzelnes ICO-Icon fuer einen Ordner.
    .DESCRIPTION
        Ermittelt die passende Technologie-Definition fuer den Ordnernamen,
        generiert ein SVG via Get-SvgTemplate, konvertiert es per Inkscape in
        eine ICO-Datei und speichert diese im Ordner.
        Mit -Apply wird das Icon sofort via Set-FolderIcon registriert.
    .PARAMETER FolderPath
        Pfad zum Zielordner.
    .PARAMETER InkscapePath
        Optionaler Pfad zur inkscape.exe (ueberschreibt Auto-Erkennung).
    .PARAMETER Apply
        Wendet das erstellte Icon direkt auf den Ordner an.
    .PARAMETER ApplyExistingIco
        Wendet eine bereits vorhandene ICO-Datei an, wenn Inkscape fehlt.
    .PARAMETER Force
        Ueberschreibt eine vorhandene ICO-Datei.
    .EXAMPLE
        New-FolderIcon -FolderPath 'C:\Dev\Python' -Apply
    .EXAMPLE
        New-FolderIcon -FolderPath 'C:\Dev\MyProject' -Apply -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$FolderPath,

        [string]$InkscapePath,

        [switch]$Apply,
        [switch]$ApplyExistingIco,
        [switch]$Force
    )

    if (-not (Test-Path $FolderPath -PathType Container)) {
        Write-Error "Ordner existiert nicht: $FolderPath"
        return
    }

    $inkscapeExe = if ($InkscapePath -and (Test-Path $InkscapePath)) {
        $InkscapePath
    } else {
        $script:DefaultInkscapePaths
    }

    $folderName = Split-Path $FolderPath -Leaf
    $icoPath    = Join-Path $FolderPath "$folderName.ico"

    if (-not $inkscapeExe) {
        if ($ApplyExistingIco -and (Test-Path $icoPath)) {
            if ($Apply) {
                $applied = Set-FolderIcon -FolderPath $FolderPath -IconPath $icoPath -Force
                if ($applied) {
                    Write-Host "[OK] Vorhandenes Icon angewendet: $icoPath" -ForegroundColor Green
                    Update-ExplorerIconCache | Out-Null
                }
            } else {
                Write-Host "[i]  Vorhandenes Icon gefunden: $icoPath" -ForegroundColor Yellow
            }
            return
        }
        Write-Error 'Inkscape nicht gefunden. Bitte installieren, -InkscapePath angeben oder -ApplyExistingIco nutzen.'
        return
    }

    if ((Test-Path $icoPath) -and -not $Force) {
        Write-Warning "Icon existiert bereits: $icoPath (nutze -Force zum Ueberschreiben)"
        return
    }

    if ((Test-Path $icoPath) -and $Force) {
        $existing = Get-Item $icoPath -Force
        $existing.Attributes = 'Normal'
    }

    $techMatch  = Get-TechDefinition -FolderName $folderName
    $definition = if ($techMatch) { $techMatch.Definition } else { New-DynamicTechDefinition -FolderName $folderName }

    $tempDir  = Join-Path $env:TEMP "FolderIcon_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $svgPath    = Join-Path $tempDir "$folderName.svg"
    $svgContent = Get-SvgTemplate -Abbreviation $definition.Abbr -BackgroundColor $definition.BgColor -ForegroundColor $definition.FgColor
    $svgContent | Out-File -FilePath $svgPath -Encoding UTF8 -Force

    $success = Convert-SvgToIco -SvgPath $svgPath -IcoPath $icoPath -InkscapePath $inkscapeExe

    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    if ($success) {
        Write-Host "[OK] Icon erstellt: $icoPath" -ForegroundColor Green

        if ($Apply) {
            $applied = Set-FolderIcon -FolderPath $FolderPath -IconPath $icoPath -Force
            if ($applied) {
                Write-Host "[OK] Icon angewendet auf: $FolderPath" -ForegroundColor Green
                Update-ExplorerIconCache | Out-Null
            }
        }
    } else {
        Write-Error 'Icon-Erstellung fehlgeschlagen.'
    }
}
