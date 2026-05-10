@{
    RootModule        = 'DomainCheck.psm1'
    ModuleVersion     = '1.0.0.0'
    GUID              = '8c9d2a14-7c8c-4c8f-bb6c-1b4e2a7c5a01'

    Author      = 'Uwe Markus Münch'
    CompanyName = 'GFN-Retrainee'
    Copyright   = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description = 'Prueft NS- und A-Records einer Domain gegen erwartete Werte. Geeignet fuer Monitoring und Aufgabenplanung.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('Test-DomainDns')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('tdd')

    PrivateData = @{
        PSData = @{
            Tags         = @('DNS', 'Domain', 'Monitoring', 'Networking', 'Utility')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure; PS 5.1-Kompatibilitaet hergestellt.'
        }
    }
}