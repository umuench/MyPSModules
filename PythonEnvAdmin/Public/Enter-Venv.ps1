function Enter-Venv {
    <#
    .SYNOPSIS
        Wechselt ins Projektverzeichnis und aktiviert das Virtual Environment.
    .PARAMETER Name
        Name des zu aktivierenden Venvs.
    .EXAMPLE
        Enter-Venv -Name 'MyApp'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $venv = Get-Venv -Name $Name | Select-Object -First 1
    if (-not $venv)             { throw "Venv '$Name' nicht gefunden." }
    if (-not $venv.ActivateFound) { throw "Activate.ps1 nicht gefunden: $($venv.Activate)" }

    Set-Location -LiteralPath $venv.ProjectPath
    . $venv.Activate
}