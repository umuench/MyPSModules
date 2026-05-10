function Add-Venv {
    <#
    .SYNOPSIS
        Fuegt ein Python Virtual Environment zur Verwaltungsregistry hinzu.
    .PARAMETER Name
        Eindeutiger Name des Venvs.
    .PARAMETER ProjectPath
        Pfad zum Projektverzeichnis (muss existieren).
    .PARAMETER VenvFolderName
        Unterordner fuer das Venv relativ zum Projektpfad. Standard: .venv
    .PARAMETER RequirementsPath
        Pfad zur requirements.txt. Standard: requirements.txt
    .PARAMETER ConstraintsPath
        Pfad zur constraints.txt. Standard: constraints.txt
    .PARAMETER ExcludePackages
        Pakete, die bei Updates ausgeschlossen werden sollen.
    .EXAMPLE
        Add-Venv -Name 'MyApp' -ProjectPath 'C:\Projekte\MyApp'
    .EXAMPLE
        Add-Venv -Name 'MyApp' -ProjectPath 'C:\Projekte\MyApp' -ExcludePackages 'torch','numpy'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$ProjectPath,

        [string]$VenvFolderName    = '.venv',
        [string]$RequirementsPath  = 'requirements.txt',
        [string]$ConstraintsPath   = 'constraints.txt',
        [string[]]$ExcludePackages = @()
    )

    $resolvedProjectPath = Resolve-ManagedPath -Path $ProjectPath -ProjectPath $null
    if (-not (Test-Path -LiteralPath $resolvedProjectPath)) {
        throw "Projektpfad nicht gefunden: $resolvedProjectPath"
    }

    $items = @(Get-VenvRegistry)
    if ($items | Where-Object { $_.Name -eq $Name }) {
        throw "Ein Eintrag mit dem Namen '$Name' existiert bereits."
    }
    if ($items | Where-Object { (Resolve-ManagedPath -Path $_.ProjectPath -ProjectPath $null) -eq $resolvedProjectPath }) {
        throw "Ein Eintrag mit diesem Projektpfad existiert bereits."
    }

    $entry = [pscustomobject]@{
        Name             = $Name
        ProjectPath      = $resolvedProjectPath
        VenvPath         = (Resolve-ManagedPath -Path $VenvFolderName   -ProjectPath $resolvedProjectPath)
        RequirementsPath = (Resolve-ManagedPath -Path $RequirementsPath -ProjectPath $resolvedProjectPath)
        ConstraintsPath  = (Resolve-ManagedPath -Path $ConstraintsPath  -ProjectPath $resolvedProjectPath)
        ExcludePackages  = @($ExcludePackages | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    }

    $items += $entry
    Save-VenvRegistry -Data $items
    Get-Venv -Name $Name | Select-Object -First 1
}