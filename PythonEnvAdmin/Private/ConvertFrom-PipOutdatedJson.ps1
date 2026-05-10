function ConvertFrom-PipOutdatedJson {
    <#
    .SYNOPSIS
        Parst die JSON-Ausgabe von "pip list --outdated --format=json".
    .PARAMETER Json
        Der JSON-String aus der pip-Ausgabe.
    #>
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Json
    )

    if ([string]::IsNullOrWhiteSpace($Json)) { return @() }

    $parsed = $Json | ConvertFrom-Json
    return @(ConvertTo-Array $parsed)
}