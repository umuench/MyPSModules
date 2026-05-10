function New-VenvInfo {
    <#
    .SYNOPSIS
        Erstellt ein angereichertes Venv-Info-Objekt aus einem Registry-Eintrag.
    .DESCRIPTION
        Loest alle Pfade auf, prueft deren Existenz und gibt ein PSCustomObject zurueck,
        das alle relevanten Informationen zum Virtual Environment enthaelt.
    .PARAMETER Item
        Ein Roheintrag aus der venvs.json-Registrierungsdatei.
    #>
    param(
        [Parameter(Mandatory)]
        $Item
    )

    $projectPath = Resolve-ManagedPath -Path $Item.ProjectPath -ProjectPath $null

    $venvPath = if ($Item.PSObject.Properties.Name -contains 'VenvPath' -and
                    -not [string]::IsNullOrWhiteSpace($Item.VenvPath)) {
        Resolve-ManagedPath -Path $Item.VenvPath -ProjectPath $projectPath
    } else {
        Resolve-ManagedPath -Path '.venv' -ProjectPath $projectPath
    }

    $requirementsPath = if ($Item.PSObject.Properties.Name -contains 'RequirementsPath' -and
                            -not [string]::IsNullOrWhiteSpace($Item.RequirementsPath)) {
        Resolve-ManagedPath -Path $Item.RequirementsPath -ProjectPath $projectPath
    } else {
        Resolve-ManagedPath -Path 'requirements.txt' -ProjectPath $projectPath
    }

    $constraintsPath = if ($Item.PSObject.Properties.Name -contains 'ConstraintsPath' -and
                           -not [string]::IsNullOrWhiteSpace($Item.ConstraintsPath)) {
        Resolve-ManagedPath -Path $Item.ConstraintsPath -ProjectPath $projectPath
    } else {
        Resolve-ManagedPath -Path 'constraints.txt' -ProjectPath $projectPath
    }

    $excludePackages = @()
    if ($Item.PSObject.Properties.Name -contains 'ExcludePackages' -and $null -ne $Item.ExcludePackages) {
        $excludePackages = @($Item.ExcludePackages |
            ForEach-Object { $_.ToString() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique)
    }

    $pythonExe       = Join-Path -Path $venvPath -ChildPath 'Scripts\python.exe'
    $pipExe          = Join-Path -Path $venvPath -ChildPath 'Scripts\pip.exe'
    $activate        = Join-Path -Path $venvPath -ChildPath 'Scripts\Activate.ps1'
    $globalConstraints = Get-GlobalConstraintsPath

    [pscustomobject]@{
        Name                   = $Item.Name
        ProjectPath            = $projectPath
        VenvPath               = $venvPath
        RequirementsPath       = $requirementsPath
        ConstraintsPath        = $constraintsPath
        GlobalConstraintsPath  = $globalConstraints
        ExcludePackages        = $excludePackages
        PythonExe              = $pythonExe
        PipExe                 = $pipExe
        Activate               = $activate
        ProjectExists          = Test-Path -LiteralPath $projectPath
        VenvExists             = Test-Path -LiteralPath $venvPath
        PythonFound            = Test-Path -LiteralPath $pythonExe
        PipFound               = Test-Path -LiteralPath $pipExe
        ActivateFound          = Test-Path -LiteralPath $activate
        RequirementsFound      = Test-Path -LiteralPath $requirementsPath
        ConstraintsFound       = Test-Path -LiteralPath $constraintsPath
        GlobalConstraintsFound = Test-Path -LiteralPath $globalConstraints
    }
}