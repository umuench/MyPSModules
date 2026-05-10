function Update-AllVenvs {
    <#
    .SYNOPSIS
        Aktualisiert alle registrierten Virtual Environments nacheinander.
    .DESCRIPTION
        Ruft Update-VenvPip fuer jedes registrierte Venv auf. Fehler werden abgefangen
        und als Fehlerobjekt in den Ergebnissen aufgefuehrt.
    .PARAMETER UpgradeAll
        Fuehrt das tatsaechliche Upgrade durch (ohne: nur Anzeige veralteter Pakete).
    .PARAMETER SkipPipUpgrade
        Ueberspringt das pip-Upgrade in jedem Venv.
    .PARAMETER ExcludePackages
        Pakete, die in allen Venvs ausgeschlossen werden.
    .PARAMETER UseGlobalConstraints
        Wendet constraints.global.txt in allen Venvs an.
    .PARAMETER IgnoreProjectConstraints
        Ignoriert projektspezifische constraints.txt in allen Venvs.
    .EXAMPLE
        Update-AllVenvs -UpgradeAll
    #>
    [CmdletBinding()]
    param(
        [switch]$UpgradeAll,
        [switch]$SkipPipUpgrade,
        [string[]]$ExcludePackages    = @(),
        [switch]$UseGlobalConstraints,
        [switch]$IgnoreProjectConstraints
    )

    foreach ($venv in Get-Venv) {
        try {
            Update-VenvPip -Name $venv.Name `
                -UpgradeAll:$UpgradeAll `
                -SkipPipUpgrade:$SkipPipUpgrade `
                -ExcludePackages $ExcludePackages `
                -UseGlobalConstraints:$UseGlobalConstraints `
                -IgnoreProjectConstraints:$IgnoreProjectConstraints `
                -ErrorAction Stop
        }
        catch {
            [pscustomobject]@{
                Name             = $venv.Name
                PipUpgraded      = (-not $SkipPipUpgrade)
                OutdatedBefore   = $null
                ExcludedOutdated = $null
                UpgradedPackages = 0
                OutdatedAfter    = $null
                Status           = 'Fehler'
                ExcludedPackages = @($ExcludePackages)
                PipCheck         = $null
                ErrorMessage     = $_.Exception.Message
            }
        }
    }
}