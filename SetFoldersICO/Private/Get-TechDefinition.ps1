function Get-TechDefinition {
    <#
    .SYNOPSIS
        Sucht eine Technologie-Definition fuer einen Ordnernamen.
    .DESCRIPTION
        Prueft zunaechst benutzerdefinierte Definitionen (exakter Treffer),
        dann Standard-Definitionen (exakter Treffer), dann einen Partial-Match
        in den Standard-Definitionen.
        Gibt $null zurueck, wenn kein Treffer gefunden wird.
    .PARAMETER FolderName
        Name des Ordners, fuer den eine Definition gesucht wird.
    .EXAMPLE
        $def = Get-TechDefinition -FolderName 'Python'
        if ($def) { Write-Host $def.Definition.BgColor }
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FolderName
    )

    foreach ($key in $script:CustomTechDefinitions.Keys) {
        if ($key -ieq $FolderName) {
            return @{ Name = $key; Definition = $script:CustomTechDefinitions[$key] }
        }
    }

    foreach ($key in $script:TechDefinitions.Keys) {
        if ($key -ieq $FolderName) {
            return @{ Name = $key; Definition = $script:TechDefinitions[$key] }
        }
    }

    foreach ($key in $script:TechDefinitions.Keys) {
        if ($FolderName -ilike "*$key*") {
            return @{ Name = $key; Definition = $script:TechDefinitions[$key] }
        }
    }

    return $null
}
