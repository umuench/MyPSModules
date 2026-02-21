@{
    RootModule        = 'CodeSigningTools.psm1'
    ModuleVersion     = '1.0.1'

    GUID              = 'b8c5b8c7-3e2f-4a4a-9c55-2d4a8c5e9f01'

    Author            = 'Uwe Markus Münch'
    CompanyName       = 'Private'
    Copyright         = '(c) 2026 Uwe Markus Münch. All rights reserved.'

    Description       = 'Reusable utilities for signing PowerShell scripts and modules using Authenticode.'

    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        'Get-CodeSigningCertificate',
        'Set-PowerShellCodeSignature'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('gcs','scs')

    PrivateData = @{
        PSData = @{
            Tags       = @('CodeSigning', 'Authenticode', 'Security', 'PowerShell')
            ProjectUri = 'local'
            ReleaseNotes = @'
Version 1.0.1
- Added thumbprint-based certificate selection.
- SubjectMatch can be passed through Set-PowerShellCodeSignature.
'@
        }
    }
}
