function Set-VenvConfig {
    <#
    .SYNOPSIS
        Aktualisiert die Konfiguration eines registrierten Virtual Environments.
    .PARAMETER Name
        Name des zu aendernden Venvs.
    .PARAMETER ProjectPath
        Neuer Projektpfad.
    .PARAMETER VenvPath
        Neuer Venv-Pfad.
    .PARAMETER RequirementsPath
        Neuer Pfad zur requirements.txt.
    .PARAMETER ConstraintsPath
        Neuer Pfad zur constraints.txt.
    .PARAMETER ExcludePackages
        Neue Ausschlussliste.
    .PARAMETER ClearRequirementsPath
        Entfernt den gespeicherten RequirementsPath (Fallback auf Standard).
    .PARAMETER ClearConstraintsPath
        Entfernt den gespeicherten ConstraintsPath (Fallback auf Standard).
    .PARAMETER ClearExcludePackages
        Leert die Ausschlussliste.
    .EXAMPLE
        Set-VenvConfig -Name 'MyApp' -ExcludePackages 'torch'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$ProjectPath,
        [string]$VenvPath,
        [string]$RequirementsPath,
        [string]$ConstraintsPath,
        [string[]]$ExcludePackages,

        [switch]$ClearRequirementsPath,
        [switch]$ClearConstraintsPath,
        [switch]$ClearExcludePackages
    )

    $items = @(Get-VenvRegistry)
    $entry = $items | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
    if (-not $entry) { throw "Venv '$Name' nicht gefunden." }

    $effectiveProjectPath = if ($PSBoundParameters.ContainsKey('ProjectPath')) {
        Resolve-ManagedPath -Path $ProjectPath -ProjectPath $null
    } else {
        Resolve-ManagedPath -Path $entry.ProjectPath -ProjectPath $null
    }
    $entry.ProjectPath = $effectiveProjectPath

    if ($PSBoundParameters.ContainsKey('VenvPath')) {
        $entry.VenvPath = Resolve-ManagedPath -Path $VenvPath -ProjectPath $effectiveProjectPath
    }

    if ($ClearRequirementsPath) {
        $entry.PSObject.Properties.Remove('RequirementsPath') | Out-Null
    } elseif ($PSBoundParameters.ContainsKey('RequirementsPath')) {
        $entry.RequirementsPath = Resolve-ManagedPath -Path $RequirementsPath -ProjectPath $effectiveProjectPath
    }

    if ($ClearConstraintsPath) {
        $entry.PSObject.Properties.Remove('ConstraintsPath') | Out-Null
    } elseif ($PSBoundParameters.ContainsKey('ConstraintsPath')) {
        $entry.ConstraintsPath = Resolve-ManagedPath -Path $ConstraintsPath -ProjectPath $effectiveProjectPath
    }

    if ($ClearExcludePackages) {
        $entry.ExcludePackages = @()
    } elseif ($PSBoundParameters.ContainsKey('ExcludePackages')) {
        $entry.ExcludePackages = @($ExcludePackages | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    }

    Save-VenvRegistry -Data $items
    Get-Venv -Name $Name | Select-Object -First 1
}