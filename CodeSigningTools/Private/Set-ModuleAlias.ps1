function Set-ModuleAlias {
    <#
    .SYNOPSIS
        Registriert einen Alias im aktuellen Modulbereich, sofern dieser nicht gesperrt ist.
    .DESCRIPTION
        Erstellt einen modul-internen Alias nur dann, wenn kein ReadOnly- oder Constant-Alias
        gleichen Namens existiert. Haengt den Aliasnamen an die uebergebene Exportliste an.
    .PARAMETER Name
        Der zu erstellende Aliasname.
    .PARAMETER Value
        Der Befehl, auf den der Alias zeigen soll.
    .PARAMETER ExportList
        [ref] auf ein String-Array, das Aliasnamen fuer Export-ModuleMember sammelt.
    .EXAMPLE
        $aliases = @()
        Set-ModuleAlias -Name 'gcs' -Value 'Get-CodeSigningCertificate' -ExportList ([ref]$aliases)
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Value,
        [ref]$ExportList
    )

    $existing = Get-Alias -Name $Name -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.Options -match 'ReadOnly|Constant') {
            return
        }
    }

    Set-Alias -Name $Name -Value $Value -Scope Script -Force
    $ExportList.Value += $Name
}