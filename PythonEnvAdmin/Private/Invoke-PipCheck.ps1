function Invoke-PipCheck {
    <#
    .SYNOPSIS
        Fuehrt "pip check" in einem Venv aus und gibt Ausgabe und Exit-Code zurueck.
    .PARAMETER Venv
        Das Venv-Info-Objekt.
    #>
    param(
        [Parameter(Mandatory)]
        $Venv
    )

    $output = & $Venv.PythonExe -m pip check 2>&1
    [pscustomobject]@{
        Output   = ($output -join "`n")
        ExitCode = $LASTEXITCODE
    }
}