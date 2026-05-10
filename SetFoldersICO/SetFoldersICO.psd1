@{
    RootModule        = 'SetFoldersICO.psm1'
    ModuleVersion     = '1.0.0.0'

    GUID              = 'a3b7c9d1-e5f7-4a2b-8c6d-0e1f2a3b4c5d'

    Author            = 'Uwe Markus Münch'
    CompanyName       = 'GFN-Retrainee'
    Copyright         = '(c) 2026 Uwe Markus Münch. All rights reserved.'

    Description       = 'Generiert und wendet individuelle ICO-Icons fuer Entwicklungsordner an. Unterstuetzt 280+ Technologien mit offiziellen Markenfarben. Erfordert Inkscape fuer SVG-zu-ICO-Konvertierung.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Set-DevFolderIcons',
        'Set-FolderIcon',
        'Remove-FolderIcon',
        'Update-ExplorerIconCache',
        'Get-TechDefinitions',
        'Add-TechDefinition',
        'New-FolderIcon'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('sfdi', 'sfi', 'rfi', 'gtd', 'nfi')

    PrivateData = @{
        PSData = @{
            Tags         = @('Icons', 'Folders', 'Development', 'Inkscape', 'SVG', 'ICO', 'Windows')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored zu Public/Private-Struktur; 280+ Technologien; PS5.1-kompatibel.'
        }
    }
}
