function Get-Venv {
    <#
    .SYNOPSIS
        Listet registrierte Python Virtual Environments auf.
    .DESCRIPTION
        Gibt alle oder gefilterte Venv-Eintraege aus der Registry zurueck,
        angereichert mit aufgeloesten Pfaden und Existenzpruefungen.
    .PARAMETER Name
        Optionaler Name oder Projektpfad-Teilstring fuer die Filterung.
    .EXAMPLE
        Get-Venv
        Listet alle registrierten Venvs auf.
    .EXAMPLE
        Get-Venv -Name 'MyProject'
        Gibt den Eintrag fuer 'MyProject' zurueck.
    #>
    [CmdletBinding()]
    param(
        [string]$Name
    )

    $items = Get-VenvRegistry | ForEach-Object { New-VenvInfo -Item $_ }

    if ([string]::IsNullOrWhiteSpace($Name)) { return $items }

    $items | Where-Object { $_.Name -like $Name -or $_.ProjectPath -like "*$Name*" }
}