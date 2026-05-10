function Get-OutdatedPackages {
    <#
    .SYNOPSIS
        Ermittelt veraltete Pakete in einem Venv via "pip list --outdated".
    .PARAMETER Venv
        Das Venv-Info-Objekt.
    #>
    param(
        [Parameter(Mandatory)]
        $Venv
    )

    $json = & $Venv.PythonExe -m pip list --outdated --format=json
    if ($LASTEXITCODE -ne 0) {
        throw "Fehler beim Ermitteln veralteter Pakete fuer '$($Venv.Name)'."
    }

    ConvertFrom-PipOutdatedJson -Json ($json | Out-String)
}