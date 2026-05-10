@{
    RootModule           = 'GitIgnore.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID                 = 'b8c4d3e5-6f7a-4b2c-8d9e-7f8a4b3c2d6e'

    Author      = 'Uwe Markus Münch'
    CompanyName = 'GFN-Retrainee'
    Copyright   = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description = 'Erstellt und verwaltet .gitignore-Dateien mit Auto-Erkennung fuer Node.js, Python, Java u.v.m. Nutzt Vorlagen mit intelligenter Deduplizierung.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('New-GitIgnore')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('ngi')

    PrivateData = @{
        PSData = @{
            Tags         = @('Git', 'GitIgnore', 'VersionControl', 'Node', 'Python', 'Java', 'Template', 'Development')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure; Process-Lines in Private extrahiert.'
        }
    }
}