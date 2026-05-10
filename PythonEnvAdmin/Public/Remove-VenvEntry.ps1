function Remove-VenvEntry {
    <#
    .SYNOPSIS
        Entfernt einen Venv-Eintrag aus der Registry (loescht keine Dateien).
    .PARAMETER Name
        Name des zu entfernenden Eintrags.
    .EXAMPLE
        Remove-VenvEntry -Name 'MyApp'
    .EXAMPLE
        Remove-VenvEntry -Name 'MyApp' -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $items    = @(Get-VenvRegistry)
    $existing = $items | Where-Object { $_.Name -eq $Name }
    if (-not $existing) { throw "Kein Eintrag mit Name '$Name' gefunden." }

    if ($PSCmdlet.ShouldProcess($Name, 'Venv-Eintrag entfernen')) {
        $filtered = @($items | Where-Object { $_.Name -ne $Name })
        Save-VenvRegistry -Data $filtered
    }
}