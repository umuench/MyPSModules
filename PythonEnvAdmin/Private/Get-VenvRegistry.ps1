function Get-VenvRegistry {
    <#
    .SYNOPSIS
        Liest alle Eintraege aus der venvs.json-Registrierungsdatei.
    .DESCRIPTION
        Initialisiert die Datei bei Bedarf und gibt ein Array zurueck.
        Ein leeres Array wird bei leerer oder fehlender Datei zurueckgegeben.
    #>
    Initialize-VenvRegistry

    $raw = Get-Content -LiteralPath $script:RegistryPath -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }

    $data = $raw | ConvertFrom-Json
    return @(ConvertTo-Array $data)
}