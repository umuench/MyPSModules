function Test-Venv {
    <#
    .SYNOPSIS
        Prueft den Zustand eines oder aller registrierten Virtual Environments.
    .DESCRIPTION
        Gibt fuer jedes Venv eine Statustabelle zurueck, die zeigt ob Projekt,
        Venv-Ordner, Python, requirements.txt und constraints.txt erreichbar sind.
    .PARAMETER Name
        Optionaler Name; ohne Angabe werden alle Venvs geprueft.
    .EXAMPLE
        Test-Venv
        Prueft alle registrierten Venvs.
    .EXAMPLE
        Test-Venv -Name 'MyApp'
    #>
    [CmdletBinding()]
    param(
        [string]$Name
    )

    $venvs = if ([string]::IsNullOrWhiteSpace($Name)) { Get-Venv } else { Get-Venv -Name $Name }

    foreach ($venv in $venvs) {
        [pscustomobject]@{
            Name                   = $venv.Name
            ProjectExists          = $venv.ProjectExists
            VenvExists             = $venv.VenvExists
            PythonFound            = $venv.PythonFound
            RequirementsFound      = $venv.RequirementsFound
            ConstraintsFound       = $venv.ConstraintsFound
            GlobalConstraintsFound = $venv.GlobalConstraintsFound
            ExcludePackages        = @($venv.ExcludePackages) -join ', '
        }
    }
}