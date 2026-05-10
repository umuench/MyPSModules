function Invoke-GitIgnoreLineProcessing {
    <#
    .SYNOPSIS
        Fuegt Zeilen dedupliziert in die Ausgabeliste ein.
    .DESCRIPTION
        Nicht-leere, nicht-kommentierte Zeilen werden gegen $SeenRules geprueft.
        Neue Regeln werden dem HashSet und der Ausgabeliste hinzugefuegt.
        Leere Zeilen und Kommentare werden immer durchgelassen.
        HashSet und List werden als .NET-Referenztypen in-place veraendert.
    .PARAMETER Lines
        Zu verarbeitende Zeilen.
    .PARAMETER SourceName
        Anzeigename der Quelle (fuer Konsolenausgabe).
    .PARAMETER SeenRules
        HashSet fuer bereits gesehene Regeln (deduplizierung, in-place).
    .PARAMETER FinalContent
        Zielliste fuer die Ausgabe (in-place).
    #>
    param(
        [AllowNull()]
        [string[]]$Lines,

        [string]$SourceName,

        [Parameter(Mandatory)]
        [System.Collections.Generic.HashSet[string]]$SeenRules,

        [Parameter(Mandatory)]
        [System.Collections.Generic.List[string]]$FinalContent
    )

    foreach ($Line in $Lines) {
        $Trimmed = $Line.Trim()
        if ($Trimmed.Length -gt 0 -and -not $Trimmed.StartsWith('#')) {
            if (-not $SeenRules.Contains($Trimmed)) {
                [void]$SeenRules.Add($Trimmed)
                [void]$FinalContent.Add($Line)
            }
        }
        else {
            [void]$FinalContent.Add($Line)
        }
    }

    if ($Lines) {
        Write-Host "  [+] Processed $SourceName" -ForegroundColor Green
    }
}