function New-DynamicTechDefinition {
    <#
    .SYNOPSIS
        Generiert eine Technologie-Definition fuer einen unbekannten Ordner.
    .DESCRIPTION
        Leitet Abkuerzung und Farbe algorithmisch aus dem Ordnernamen ab:
        - Abkuerzung: Konsonanten oder Anfangsbuchstaben (max. 3 Zeichen)
        - Farbe: Hash-basierter HSL-Wert mit fester Saettigung und Helligkeit
        - Schriftfarbe: Schwarz oder Weiss je nach Luminanz des Hintergrunds
    .PARAMETER FolderName
        Ordnername, fuer den eine Definition generiert werden soll.
    .EXAMPLE
        $def = New-DynamicTechDefinition -FolderName 'MyCustomFramework'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FolderName
    )

    $consonants = ($FolderName -replace '[aeiouAEIOU]', '')
    $abbr = if ($FolderName.Length -le 3) {
        $FolderName.ToUpper()
    } elseif ($consonants.Length -ge 2) {
        $consonants.Substring(0, [Math]::Min(3, $consonants.Length)).ToUpper()
    } else {
        $FolderName.Substring(0, [Math]::Min(3, $FolderName.Length)).ToUpper()
    }

    $hash = [System.Math]::Abs($FolderName.GetHashCode())
    $hue  = $hash % 360
    $s    = 0.65
    $l    = 0.45

    $c  = (1 - [Math]::Abs(2 * $l - 1)) * $s
    $x  = $c * (1 - [Math]::Abs(($hue / 60) % 2 - 1))
    $m  = $l - $c / 2

    $r1 = 0.0; $g1 = 0.0; $b1 = 0.0

    switch ([Math]::Floor($hue / 60)) {
        0 { $r1 = $c; $g1 = $x; $b1 = 0 }
        1 { $r1 = $x; $g1 = $c; $b1 = 0 }
        2 { $r1 = 0;  $g1 = $c; $b1 = $x }
        3 { $r1 = 0;  $g1 = $x; $b1 = $c }
        4 { $r1 = $x; $g1 = 0;  $b1 = $c }
        5 { $r1 = $c; $g1 = 0;  $b1 = $x }
        default { $r1 = $c; $g1 = 0; $b1 = $x }
    }

    $r = [Math]::Max(0, [Math]::Min(255, [int](($r1 + $m) * 255)))
    $g = [Math]::Max(0, [Math]::Min(255, [int](($g1 + $m) * 255)))
    $b = [Math]::Max(0, [Math]::Min(255, [int](($b1 + $m) * 255)))

    $bgColor   = '#{0:X2}{1:X2}{2:X2}' -f $r, $g, $b
    $luminance = (0.299 * $r + 0.587 * $g + 0.114 * $b) / 255
    $fgColor   = if ($luminance -gt 0.5) { '#000000' } else { '#FFFFFF' }

    return @{
        Abbr     = $abbr
        BgColor  = $bgColor
        FgColor  = $fgColor
        Category = 'Auto'
    }
}
