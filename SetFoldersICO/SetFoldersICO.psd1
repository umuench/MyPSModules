@{
    # Modul-Identifikation
    RootModule        = 'SetFoldersICO.psm1'
    ModuleVersion     = '1.3.0'
    GUID              = 'a3b7c9d1-e5f7-4a2b-8c6d-0e1f2a3b4c5d'
    
    # Autor-Informationen
    Author            = 'Uwe'
    CompanyName       = 'Private'
    Copyright         = '(c) 2025. MIT License.'
    Description       = 'Generiert und wendet individuelle Ordner-Icons für Entwicklungsprojekte an. Unterstützt 280+ Technologien mit offiziellen Markenfarben.'
    
    # PowerShell-Anforderungen
    PowerShellVersion = '5.1'
    
    # Exportierte Funktionen (öffentliche API)
    FunctionsToExport = @(
        'Set-DevFolderIcons',      # Hauptfunktion: Generiert Icons für alle Unterordner
        'Set-FolderIcon',          # Wendet ein einzelnes Icon auf einen Ordner an
        'Remove-FolderIcon',       # Entfernt Icon von einem Ordner
        'Update-ExplorerIconCache', # Aktualisiert den Windows Icon-Cache
        'Get-TechDefinitions',     # Zeigt verfügbare Technologie-Definitionen
        'Add-TechDefinition',      # Fügt eine neue Technologie hinzu
        'New-FolderIcon'           # Erstellt ein einzelnes Icon für einen Ordner
    )
    
    # Exportierte Aliase
    AliasesToExport   = @(
        'sfdi',    # Set-DevFolderIcons
        'sfi',     # Set-FolderIcon
        'rfi',     # Remove-FolderIcon
        'gtd',     # Get-TechDefinitions
        'nfi'      # New-FolderIcon
    )
    
    # Keine Variablen oder Cmdlets exportieren
    VariablesToExport = @()
    CmdletsToExport   = @()
    
    # Private Daten
    PrivateData       = @{
        PSData = @{
            Tags         = @('Folder', 'Icons', 'Development', 'Windows', 'Explorer', 'Customization')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = ''
            ReleaseNotes = @'
Version 1.3.0:
- INKSCAPE_PATH support
- ApplyExistingIco mode for no-Inkscape setups

Version 1.2.0:
- ICO-Dateien werden bei -ApplyToFolders im Unterordner erstellt
- ICO-Dateien erhalten Hidden + System Attribute
- Ordner erhalten System-Attribut für korrekte Anzeige
- Neue Funktion: New-FolderIcon für einzelne Icons
- Neue Funktion: Add-TechDefinition für benutzerdefinierte Technologien
- Modulare Struktur für einfache Installation
- 280+ Technologien mit offiziellen Markenfarben
'@
        }
    }
    
    # Externe Abhängigkeiten
    # RequiredModules = @()
    # RequiredAssemblies = @()
}
