function ConvertTo-Array {
    <#
    .SYNOPSIS
        Stellt sicher, dass der Rueckgabewert immer ein Array ist.
    .DESCRIPTION
        Gibt $null als leeres Array zurueck, einzelne Objekte werden in @() gewrappt.
        Notwendig, weil ConvertFrom-Json bei einem einzelnen Element kein Array liefert.
    .PARAMETER InputObject
        Der zu konvertierende Wert.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        if ($null -eq $InputObject) { return @() }
        if ($InputObject -is [System.Array]) { return $InputObject }
        return @($InputObject)
    }
}