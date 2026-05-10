@{
    RootModule        = 'CodeSigningTools.psm1'
    ModuleVersion     = '1.0.0.0'

    GUID              = 'b8c5b8c7-3e2f-4a4a-9c55-2d4a8c5e9f01'

    Author            = 'Uwe Markus Münch'
    CompanyName       = 'GFN-Retrainee'
    Copyright         = '(c) 2026 Uwe Markus Münch. All rights reserved.'

    Description       = 'Reusable utilities for signing PowerShell scripts and modules using Authenticode.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Get-CodeSigningCertificate',
        'Set-PowerShellCodeSignature'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('gcsc', 'scs')

    PrivateData = @{
        PSData = @{
            Tags         = @('CodeSigning', 'Authenticode', 'Security', 'PowerShell')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure; Comment-Based Help ergaenzt.'
        }
    }
}