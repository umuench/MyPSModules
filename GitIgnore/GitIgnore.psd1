@{
    # Skript-Modul oder Binär-Moduldatei, die mit diesem Manifest verknüpft ist
    RootModule = 'GitIgnore.psm1'

    # Die Versionsnummer dieses Moduls
    ModuleVersion = '1.2.0'

    # Unterstützte PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID zur eindeutigen Identifizierung dieses Moduls
    GUID = 'b8c4d3e5-6f7a-4b2c-8d9e-7f8a4b3c2d6e'

    # Autor dieses Moduls
    Author = 'Gemini AI'

    # Unternehmen oder Hersteller dieses Moduls
    CompanyName = ''

    # Urheberrechtserklärung für dieses Modul
    Copyright = '(c) 2023-2025. Alle Rechte vorbehalten.'

    # Beschreibung der von diesem Modul bereitgestellten Funktionen
    Description = 'Erstellt und verwaltet .gitignore-Dateien mit Auto-Detection für Node.js, Python, Java und mehr. Nutzt Vorlagen mit intelligenter Deduplizierung.'

    # Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
    PowerShellVersion = '5.1'

    # Aus diesem Modul zu exportierende Funktionen
    FunctionsToExport = @('New-GitIgnore')

    # Aus diesem Modul zu exportierende Cmdlets
    CmdletsToExport = @()

    # Die aus diesem Modul zu exportierenden Variablen
    VariablesToExport = @()

    # Aus diesem Modul zu exportierende Aliase
    AliasesToExport = @('ngi')

    # Private Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Git', 'GitIgnore', 'VersionControl', 'Node', 'Python', 'Java', 'Template', 'Development')

            # ReleaseNotes of this module
            ReleaseNotes = @'
Version 1.2.0
- TemplatePath parameter and env-based fallback
- Module-local Templates fallback

Version 1.1.0
- Auto-Detection für Node.js, Python und Java Projekte
- Intelligente Deduplizierung von Regeln
- Append-Modus zum Erweitern bestehender .gitignore-Dateien
- Template-basierte Generierung
- Unterstützung für mehrere Projekt-Typen gleichzeitig
'@
        }
    }
}
