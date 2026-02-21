@{
    # Skript-Modul oder Binär-Moduldatei, die mit diesem Manifest verknüpft ist
    RootModule = 'DirectoryTree.psm1'

    # Die Versionsnummer dieses Moduls
    ModuleVersion = '1.1.0'

    # Unterstützte PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID zur eindeutigen Identifizierung dieses Moduls
    GUID = '9f8a5c2d-4b3e-4f1a-8d7c-5e9b2a1f6c3d'

    # Autor dieses Moduls
    Author = 'Student'

    # Unternehmen oder Hersteller dieses Moduls
    CompanyName = ''

    # Urheberrechtserklärung für dieses Modul
    Copyright = '(c) 2025 Student. Alle Rechte vorbehalten.'

    # Beschreibung der von diesem Modul bereitgestellten Funktionen
    Description = 'Modul zum Erstellen einer hierarchischen Baumstruktur von Verzeichnissen mit optionalem JSON-Export.'

    # Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
    PowerShellVersion = '5.1'

    # Aus diesem Modul zu exportierende Funktionen
    FunctionsToExport = @('Get-DirectoryTree')

    # Aus diesem Modul zu exportierende Cmdlets
    CmdletsToExport = @()

    # Die aus diesem Modul zu exportierenden Variablen
    VariablesToExport = @()

    # Aus diesem Modul zu exportierende Aliase
    AliasesToExport = @('gdt')

    # Private Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Directory', 'Tree', 'FileSystem', 'JSON', 'Export', 'Utility')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @'
Version 1.1.0
- Added IncludeExtension and ExcludePattern filters

Version 1.0.0
- Initiale Version
- Rekursive Verzeichnisbaum-Erstellung
- Optionaler JSON-Export mit -OutPath Parameter
- Konfigurierbare JSON-Tiefe
'@
        }
    }
}
