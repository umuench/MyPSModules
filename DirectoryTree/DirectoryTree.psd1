@{
    RootModule           = 'DirectoryTree.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID                 = '9f8a5c2d-4b3e-4f1a-8d7c-5e9b2a1f6c3d'

    Author      = 'Uwe Markus Münch'
    CompanyName = 'GFN-Retrainee'
    Copyright   = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description = 'Erstellt eine hierarchische Baumstruktur von Verzeichnissen mit optionalem JSON-Export.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('Get-DirectoryTree')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('gdt')

    PrivateData = @{
        PSData = @{
            Tags         = @('Directory', 'Tree', 'FileSystem', 'JSON', 'Export', 'Utility')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure.'
        }
    }
}