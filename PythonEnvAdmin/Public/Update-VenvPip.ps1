function Update-VenvPip {
    <#
    .SYNOPSIS
        Aktualisiert Pakete in einem Virtual Environment via pip.
    .DESCRIPTION
        Ohne -UpgradeAll werden nur veraltete Pakete als Tabelle angezeigt.
        Mit -UpgradeAll werden alle aktualisierbaren Pakete (ausser Ausschluss-Liste) aktualisiert.
    .PARAMETER Name
        Name des Venvs.
    .PARAMETER UpgradeAll
        Fuehrt das tatsaechliche Upgrade aller aktualisierbaren Pakete durch.
    .PARAMETER SkipPipUpgrade
        Ueberspringt das vorherige pip-Upgrade.
    .PARAMETER ExcludePackages
        Pakete, die zusaetzlich zur venv-spezifischen Ausschlussliste uebersprungen werden.
    .PARAMETER UseGlobalConstraints
        Wendet constraints.global.txt zusaetzlich an.
    .PARAMETER IgnoreProjectConstraints
        Ignoriert die projektspezifische constraints.txt.
    .EXAMPLE
        Update-VenvPip -Name 'MyApp'
        Zeigt veraltete Pakete an ohne zu aktualisieren.
    .EXAMPLE
        Update-VenvPip -Name 'MyApp' -UpgradeAll -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [switch]$UpgradeAll,
        [switch]$SkipPipUpgrade,
        [string[]]$ExcludePackages    = @(),
        [switch]$UseGlobalConstraints,
        [switch]$IgnoreProjectConstraints
    )

    $venv = Get-Venv -Name $Name | Select-Object -First 1
    if (-not $venv)           { throw "Venv '$Name' nicht gefunden." }
    if (-not $venv.PythonFound) { throw "python.exe nicht gefunden: $($venv.PythonExe)" }

    if (-not $SkipPipUpgrade -and $PSCmdlet.ShouldProcess($Name, 'pip aktualisieren')) {
        & $venv.PythonExe -m pip install --upgrade pip
        if ($LASTEXITCODE -ne 0) { throw "Fehler beim Aktualisieren von pip in '$Name'." }
    }

    $effectiveExcludes  = Get-EffectiveExcludePackages -Venv $venv -ExcludePackages $ExcludePackages
    $outdatedBefore     = @(Get-OutdatedPackages -Venv $venv)
    $updatablePackages  = @($outdatedBefore | Where-Object { $_.name -notin $effectiveExcludes })
    $excludedOutdated   = @($outdatedBefore | Where-Object { $_.name -in  $effectiveExcludes })

    if (-not $UpgradeAll) {
        $updatablePackages |
            Sort-Object name |
            Select-Object @{Name='Name';    Expression={$_.name}},
                          @{Name='Current'; Expression={$_.version}},
                          @{Name='Latest';  Expression={$_.latest}},
                          @{Name='Type';    Expression={$_.type}}
        return
    }

    if ($updatablePackages.Count -eq 0) {
        $check = Invoke-PipCheck -Venv $venv
        return [pscustomobject]@{
            Name             = $Name
            PipUpgraded      = (-not $SkipPipUpgrade)
            OutdatedBefore   = $outdatedBefore.Count
            ExcludedOutdated = $excludedOutdated.Count
            UpgradedPackages = 0
            OutdatedAfter    = $outdatedBefore.Count
            Status           = if ($outdatedBefore.Count -eq 0) { 'Aktuell' } else { 'Nur ausgeschlossen' }
            ExcludedPackages = @($effectiveExcludes)
            PipCheck         = $check.Output
        }
    }

    $packageNames  = @($updatablePackages | ForEach-Object { $_.name } | Sort-Object -Unique)
    $installArgs   = @('-m', 'pip', 'install', '--upgrade')

    if (-not $IgnoreProjectConstraints -and $venv.ConstraintsFound) {
        $installArgs += @('-c', $venv.ConstraintsPath)
    }
    if ($UseGlobalConstraints -and $venv.GlobalConstraintsFound) {
        $installArgs += @('-c', $venv.GlobalConstraintsPath)
    }
    $installArgs += $packageNames

    if ($PSCmdlet.ShouldProcess($Name, "Pakete aktualisieren: $($packageNames -join ', ')")) {
        & $venv.PythonExe @installArgs
        if ($LASTEXITCODE -ne 0) { throw "Fehler beim Aktualisieren der Pakete in '$Name'." }
    }

    $remaining = @(Get-OutdatedPackages -Venv $venv)
    $check     = Invoke-PipCheck -Venv $venv

    [pscustomobject]@{
        Name             = $Name
        PipUpgraded      = (-not $SkipPipUpgrade)
        OutdatedBefore   = $outdatedBefore.Count
        ExcludedOutdated = $excludedOutdated.Count
        UpgradedPackages = $packageNames.Count
        OutdatedAfter    = $remaining.Count
        Status           = if ($remaining.Count -eq 0) { 'OK' } else { 'Teilweise aktualisiert' }
        ExcludedPackages = @($effectiveExcludes)
        PipCheck         = $check.Output
    }
}