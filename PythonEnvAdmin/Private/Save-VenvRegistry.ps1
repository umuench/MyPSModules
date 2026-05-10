function Save-VenvRegistry {
    <#
    .SYNOPSIS
        Schreibt die Venv-Eintraege als JSON in die Registrierungsdatei.
    .PARAMETER Data
        Array der zu speichernden Venv-Eintraege.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Data
    )
    $Data | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $script:RegistryPath -Encoding UTF8
}