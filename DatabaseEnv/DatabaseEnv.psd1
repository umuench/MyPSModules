@{
    RootModule           = 'DatabaseEnv.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID                 = 'a7b3c9d2-5e4f-4a1b-9c8d-6e7f3a2b1c5d'

    Author      = 'Uwe Markus Münch'
    CompanyName = 'GFN-Retrainee'
    Copyright   = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description = 'Erstellt sichere .env-Dateien fuer Datenbanken (MySQL, MariaDB, PostgreSQL, MSSQL) mit Vorlagen-Unterstuetzung und maskierter Passworteingabe.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('New-EnvDB')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('nedb')

    PrivateData = @{
        PSData = @{
            Tags         = @('Database', 'Environment', 'MySQL', 'MariaDB', 'PostgreSQL', 'MSSQL', 'DotEnv', 'Security')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure; Comment-Based Help ergaenzt.'
        }
    }
}