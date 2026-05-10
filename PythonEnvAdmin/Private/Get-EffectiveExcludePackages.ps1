function Get-EffectiveExcludePackages {
    <#
    .SYNOPSIS
        Gibt die zusammengefuehrte, deduplizierte Ausschlussliste fuer ein Venv zurueck.
    .PARAMETER Venv
        Das Venv-Info-Objekt.
    .PARAMETER ExcludePackages
        Zusaetzliche Pakete, die vom Aufrufer ausgeschlossen werden sollen.
    #>
    param(
        [Parameter(Mandatory)]
        $Venv,

        [string[]]$ExcludePackages = @()
    )

    @($Venv.ExcludePackages + $ExcludePackages |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -Unique)
}