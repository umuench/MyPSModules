function Read-CharSet {
    <#
    .SYNOPSIS
        Laedt einen benannten Zeichensatz aus der CharSets-Dateiablage des Moduls.
    .DESCRIPTION
        Sucht im CharSets-Unterverzeichnis nach einer .txt-Datei mit dem angegebenen
        Namen (case-insensitiv). Whitespace wird aus dem Inhalt entfernt.
        Wirf einen Fehler, wenn der Zeichensatz nicht gefunden wird oder weniger
        als 12 Zeichen enthaelt.
    .PARAMETER Name
        Name des Zeichensatzes (ohne .txt-Erweiterung, z.B. 'hetzner').
    .EXAMPLE
        $chars = Read-CharSet -Name 'hetzner'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $charSetDir = Join-Path $PSScriptRoot '..\CharSets'
    $path       = Join-Path $charSetDir "$Name.txt"

    if (-not (Test-Path $path)) {
        $match = Get-ChildItem -Path $charSetDir -Filter '*.txt' -File -ErrorAction SilentlyContinue |
            Where-Object { $_.BaseName -ieq $Name } |
            Select-Object -First 1

        if ($match) {
            $path = $match.FullName
        } else {
            throw "CharSet '$Name' nicht gefunden in '$charSetDir'"
        }
    }

    $chars = (Get-Content $path -Raw) -replace '\s', ''

    if ($chars.Length -lt 12) {
        throw "CharSet '$Name' ist unsicher klein (weniger als 12 Zeichen)"
    }

    return $chars.ToCharArray()
}
