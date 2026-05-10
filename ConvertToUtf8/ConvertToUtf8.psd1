@{
    RootModule        = 'ConvertToUtf8.psm1'
    ModuleVersion     = '1.0.0.0'
    GUID              = 'e3c7f8e4-1c9a-4c6b-9b51-6a7b12345678'

    Author            = 'Uwe Markus Münch'
    CompanyName       = 'GFN-Retrainee'
    Copyright         = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description       = 'Konvertiert ANSI-Textdateien nach UTF-8 (mit oder ohne BOM).'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('Convert-ToUtf8')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}