function Get-TechDefinitions {
    <#
    .SYNOPSIS
        Zeigt alle verfuegbaren Technologie-Definitionen an.
    .DESCRIPTION
        Gibt eine sortierte Liste aller integrierten und benutzerdefinierten
        Technologie-Eintraege aus. Kann nach Kategorie oder Name gefiltert werden.
    .PARAMETER Category
        Filtert nach Kategorie (z.B. 'Language', 'Frontend', 'DevOps').
    .PARAMETER Name
        Sucht nach Name mit Wildcard-Unterstuetzung (z.B. '*React*').
    .EXAMPLE
        Get-TechDefinitions
    .EXAMPLE
        Get-TechDefinitions -Category Language
    .EXAMPLE
        Get-TechDefinitions -Name '*React*'
    #>
    [CmdletBinding()]
    param(
        [string]$Category,
        [string]$Name
    )

    $allDefs = $script:TechDefinitions + $script:CustomTechDefinitions

    $results = foreach ($key in ($allDefs.Keys | Sort-Object)) {
        $def = $allDefs[$key]

        if ($Category -and $def.Category -ne $Category) { continue }
        if ($Name     -and $key -notlike $Name)          { continue }

        [PSCustomObject]@{
            Name     = $key
            Abbr     = $def.Abbr
            BgColor  = $def.BgColor
            FgColor  = $def.FgColor
            Category = $def.Category
            Custom   = $script:CustomTechDefinitions.ContainsKey($key)
        }
    }

    return $results
}
