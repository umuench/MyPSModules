function Format-TaskPath {
    <#
    .SYNOPSIS
        Normalisiert einen Task-Scheduler-Pfad fuer konsistente Verarbeitung.
    .DESCRIPTION
        Konvertiert Vorwaertsschraegstriche zu Rueckwaertsschraegstrichen, entfernt
        mehrfache Schraegstriche und stellt sicher, dass der Pfad mit '\' beginnt.
        Mit -EnsureTrailing wird ein abschliessender '\' garantiert.
    .PARAMETER Path
        Der zu normalisierende Task-Pfad.
    .PARAMETER EnsureTrailing
        Fuegt einen abschliessenden Backslash an.
    .EXAMPLE
        Format-TaskPath -Path 'Eigene/System'
        # Gibt '\Eigene\System' zurueck

    .EXAMPLE
        Format-TaskPath -Path '\Eigene\' -EnsureTrailing
        # Gibt '\Eigene\' zurueck
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$EnsureTrailing
    )

    $normalized = ($Path -replace '/', '\').Trim()
    $normalized = $normalized -replace '\\+', '\'

    if ([string]::IsNullOrWhiteSpace($normalized) -or $normalized -eq '\') {
        return '\'
    }

    if (-not $normalized.StartsWith('\')) {
        $normalized = '\' + $normalized
    }

    $normalized = $normalized.TrimEnd('\')

    if ($EnsureTrailing) {
        return $normalized + '\'
    }

    return $normalized
}
