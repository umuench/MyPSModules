function Install-VenvRequirements {
    <#
    .SYNOPSIS
        Installiert Pakete aus requirements.txt in ein Virtual Environment.
    .PARAMETER Name
        Name des Venvs.
    .PARAMETER SkipPipUpgrade
        Ueberspringt das vorherige pip-Upgrade.
    .PARAMETER UseGlobalConstraints
        Wendet constraints.global.txt zusaetzlich an.
    .PARAMETER IgnoreProjectConstraints
        Ignoriert die projektspezifische constraints.txt.
    .EXAMPLE
        Install-VenvRequirements -Name 'MyApp'
    .EXAMPLE
        Install-VenvRequirements -Name 'MyApp' -UseGlobalConstraints -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [switch]$SkipPipUpgrade,
        [switch]$UseGlobalConstraints,
        [switch]$IgnoreProjectConstraints
    )

    $venv = Get-Venv -Name $Name | Select-Object -First 1
    if (-not $venv)                { throw "Venv '$Name' nicht gefunden." }
    if (-not $venv.PythonFound)    { throw "python.exe nicht gefunden: $($venv.PythonExe)" }
    if (-not $venv.RequirementsFound) { throw "requirements.txt nicht gefunden: $($venv.RequirementsPath)" }

    if (-not $SkipPipUpgrade -and $PSCmdlet.ShouldProcess($Name, 'pip aktualisieren')) {
        & $venv.PythonExe -m pip install --upgrade pip
        if ($LASTEXITCODE -ne 0) { throw "Fehler beim Aktualisieren von pip in '$Name'." }
    }

    $pipArgs = @('-m', 'pip', 'install')
    if (-not $IgnoreProjectConstraints -and $venv.ConstraintsFound) {
        $pipArgs += @('-c', $venv.ConstraintsPath)
    }
    if ($UseGlobalConstraints -and $venv.GlobalConstraintsFound) {
        $pipArgs += @('-c', $venv.GlobalConstraintsPath)
    }
    $pipArgs += @('-r', $venv.RequirementsPath)

    if ($PSCmdlet.ShouldProcess($Name, 'Pakete aus requirements installieren')) {
        & $venv.PythonExe @pipArgs
        if ($LASTEXITCODE -ne 0) { throw "Fehler beim Installieren der requirements fuer '$Name'." }
    }

    $check = Invoke-PipCheck -Venv $venv
    [pscustomobject]@{
        Name              = $Name
        RequirementsPath  = $venv.RequirementsPath
        ConstraintsPath   = if ($venv.ConstraintsFound) { $venv.ConstraintsPath } else { $null }
        GlobalConstraints = if ($UseGlobalConstraints -and $venv.GlobalConstraintsFound) { $venv.GlobalConstraintsPath } else { $null }
        Status            = if ($check.ExitCode -eq 0) { 'OK' } else { 'Warnung' }
        PipCheck          = $check.Output
    }
}