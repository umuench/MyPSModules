function Add-TechDefinition {
    <#
    .SYNOPSIS
        Fuegt eine benutzerdefinierte Technologie-Definition hinzu.
    .DESCRIPTION
        Registriert eine neue Technologie in $script:CustomTechDefinitions.
        Benutzerdefinierte Eintraege haben Vorrang vor den integrierten Definitionen
        bei der Icon-Erstellung. Die Aenderung gilt nur fuer die aktuelle Sitzung.
    .PARAMETER Name
        Schluessel-Name (entspricht dem Ordnernamen, z.B. 'MyFramework').
    .PARAMETER Abbr
        Abkuerzung fuer das Icon (1-3 Zeichen).
    .PARAMETER BgColor
        Hintergrundfarbe als Hex-String (Format: '#RRGGBB').
    .PARAMETER FgColor
        Textfarbe als Hex-String (Standard: '#FFFFFF').
    .PARAMETER Category
        Kategorie fuer die Anzeige bei Get-TechDefinitions (Standard: 'Custom').
    .EXAMPLE
        Add-TechDefinition -Name 'MyTech' -Abbr 'MT' -BgColor '#FF0000'
    .EXAMPLE
        Add-TechDefinition -Name 'Elysium' -Abbr 'El' -BgColor '#2A4080' -FgColor '#FFD700' -Category 'Framework'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateLength(1, 3)]
        [string]$Abbr,

        [Parameter(Mandatory)]
        [ValidatePattern('^#[0-9A-Fa-f]{6}$')]
        [string]$BgColor,

        [string]$FgColor   = '#FFFFFF',
        [string]$Category  = 'Custom'
    )

    $script:CustomTechDefinitions[$Name] = @{
        Abbr     = $Abbr
        BgColor  = $BgColor
        FgColor  = $FgColor
        Category = $Category
    }

    Write-Host "[OK] Technologie '$Name' hinzugefuegt." -ForegroundColor Green
}
