function Initialize-VenvRegistry {
    <#
    .SYNOPSIS
        Erstellt die venvs.json-Registrierungsdatei, falls sie noch nicht existiert.
    #>
    if (-not (Test-Path -LiteralPath $script:RegistryPath)) {
        '[]' | Set-Content -LiteralPath $script:RegistryPath -Encoding UTF8
    }
}