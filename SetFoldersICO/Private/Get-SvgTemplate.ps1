function Get-SvgTemplate {
    <#
    .SYNOPSIS
        Generiert ein SVG-Template fuer ein Technologie-Icon.
    .DESCRIPTION
        Erstellt ein gerundetes Rechteck mit zentriertem Text als SVG-String.
        Die Schriftgroesse wird automatisch an die Laenge der Abkuerzung angepasst.
    .PARAMETER Abbreviation
        Das Textkuerzel (1-3 Zeichen) fuer das Icon.
    .PARAMETER BackgroundColor
        Hintergrundfarbe als Hex-String (z.B. '#3776AB').
    .PARAMETER ForegroundColor
        Textfarbe als Hex-String.
    .PARAMETER Size
        Kantenlaenge des Icons in Pixeln (Standard: 256).
    .EXAMPLE
        Get-SvgTemplate -Abbreviation 'Py' -BackgroundColor '#3776AB' -ForegroundColor '#FFD43B'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Abbreviation,
        [Parameter(Mandatory)]
        [string]$BackgroundColor,
        [Parameter(Mandatory)]
        [string]$ForegroundColor,
        [int]$Size = 256
    )

    $padding    = [math]::Round($Size * 0.04)
    $rectSize   = $Size - (2 * $padding)
    $cornerRadius = [math]::Round($rectSize * 0.18)
    $fontSize   = switch ($Abbreviation.Length) {
        1       { [math]::Round($rectSize * 0.65) }
        2       { [math]::Round($rectSize * 0.50) }
        default { [math]::Round($rectSize * 0.38) }
    }

    $encodedAbbr = [System.Web.HttpUtility]::HtmlEncode($Abbreviation)

    return @"
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $Size $Size" width="$Size" height="$Size">
  <rect x="$padding" y="$padding" width="$rectSize" height="$rectSize" rx="$cornerRadius" ry="$cornerRadius" fill="$BackgroundColor"/>
  <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle" font-family="Segoe UI, SF Pro Display, -apple-system, sans-serif" font-weight="700" font-size="${fontSize}px" fill="$ForegroundColor">$encodedAbbr</text>
</svg>
"@
}
