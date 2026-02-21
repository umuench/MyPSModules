@{
    # Skript-Modul oder Binär-Moduldatei, die mit diesem Manifest verknüpft ist
    RootModule = 'DatabaseEnv.psm1'

    # Die Versionsnummer dieses Moduls
    ModuleVersion = '2.2.1'

    # Unterstützte PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID zur eindeutigen Identifizierung dieses Moduls
    GUID = 'a7b3c9d2-5e4f-4a1b-9c8d-6e7f3a2b1c5d'

    # Autor dieses Moduls
    Author = 'Gemini (für umuench)'

    # Unternehmen oder Hersteller dieses Moduls
    CompanyName = ''

    # Urheberrechtserklärung für dieses Modul
    Copyright = '(c) 2025. Alle Rechte vorbehalten.'

    # Beschreibung der von diesem Modul bereitgestellten Funktionen
    Description = 'Erstellt sichere .env-Dateien für Datenbanken (MySQL/MariaDB) mit Unterstützung für Vorlagen und maskierte Passwortabfrage.'

    # Die für dieses Modul mindestens erforderliche Version des Windows PowerShell-Moduls
    PowerShellVersion = '5.1'

    # Aus diesem Modul zu exportierende Funktionen
    FunctionsToExport = @('New-EnvDB')

    # Aus diesem Modul zu exportierende Cmdlets
    CmdletsToExport = @()

    # Die aus diesem Modul zu exportierenden Variablen
    VariablesToExport = @()

    # Aus diesem Modul zu exportierende Aliase
    AliasesToExport = @('nedb')

    # Private Daten, die an das in "RootModule/ModuleToProcess" angegebene Modul übergeben werden sollen
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Database', 'Environment', 'MySQL', 'MariaDB', 'Configuration', 'Security', 'DotEnv')

            # ReleaseNotes of this module
            ReleaseNotes = @'
Version 2.2.1
- Added global profile user/pass fallbacks
- Added alias: nedb

Version 2.2.0
- Added profile support (system-specific and global suffixes)

Version 2.1.0
- Added PostgreSQL and MSSQL support

Version 2.0.1
- TemplatePath parameter to load custom templates
- SecureString password support
- Defaults for host/port if template missing

Version 2.0.0
- Rename zu New-EnvDB (Standard-Verb)
- Sicherheits-Feature: Interaktive, maskierte Passwortabfrage (Read-Host -AsSecureString)
- Unterstützung für Vorlagen-basierte Konfiguration
- Sichere Passwort-Verwaltung mit SecureString
- Unterstützung für MySQL und MariaDB
'@
        }
    }
}
