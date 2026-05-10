function Quote-EnvValue {
    <#
    .SYNOPSIS
        Umgibt einen .env-Wert mit Anfuehrungszeichen, wenn er Sonderzeichen enthaelt.
    .PARAMETER Value
        Der zu pruefende Wert.
    .EXAMPLE
        Quote-EnvValue 'pa$$word 123'   # Gibt '"pa$$word 123"' zurueck
    #>
    param([string]$Value)

    if ([string]::IsNullOrEmpty($Value)) { return "" }

    if ($Value -match '[ #=$]') {
        $escaped = $Value -replace '"', '\"'
        return """$escaped"""
    }
    return $Value
}