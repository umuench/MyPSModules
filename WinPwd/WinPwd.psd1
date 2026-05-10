@{
    RootModule        = 'WinPwd.psm1'
    ModuleVersion     = '1.0.0.0'

    GUID              = 'e3b6b3c2-1d4f-4d8c-9f42-123456789abc'

    Author            = 'Uwe Markus Münch'
    CompanyName       = 'GFN-Retrainee'
    Copyright         = '(c) 2026 Uwe Markus Münch. All rights reserved.'

    Description       = 'Kryptografisch sicherer Passwortgenerator mit konfigurierbaren Zeichensaetzen (CharSets) und indizierter Ausgabe.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('Get-WinPwd')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('gwp')

    PrivateData = @{
        PSData = @{
            Tags         = @('Password', 'Security', 'Generator', 'Cryptography', 'CharSet')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - StrictMode, CBH, RNG-Dispose, Standard-Loader-Muster.'
        }
    }
}
