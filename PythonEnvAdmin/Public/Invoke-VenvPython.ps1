function Invoke-VenvPython {
    <#
    .SYNOPSIS
        Fuehrt einen Python-Befehl im Kontext eines registrierten Venvs aus.
    .PARAMETER Name
        Name des Venvs.
    .PARAMETER Args
        Argumente, die an python.exe weitergegeben werden.
    .EXAMPLE
        Invoke-VenvPython -Name 'MyApp' -- -c "import sys; print(sys.version)"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Args
    )

    $venv = Get-Venv -Name $Name | Select-Object -First 1
    if (-not $venv)           { throw "Venv '$Name' nicht gefunden." }
    if (-not $venv.PythonFound) { throw "python.exe nicht gefunden: $($venv.PythonExe)" }

    & $venv.PythonExe @Args
}