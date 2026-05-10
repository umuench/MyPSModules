@{
    RootModule           = 'TaskSchedulerTools.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')

    GUID                 = '9d7a6c4e-3c5f-4f2a-b8b3-6e2f9a1c7d55'

    Author               = 'Uwe Markus Münch'
    CompanyName          = 'GFN-Retrainee'
    Copyright            = '(c) 2026 Uwe Markus Münch. All rights reserved.'

    Description          = 'Export und Import geplanter Tasks (Scheduled Tasks) als XML-Dateien inklusive rekursiver Ordnerstruktur und Credential-Unterstuetzung.'

    PowerShellVersion    = '5.1'

    FunctionsToExport = @(
        'Export-TaskBranch',
        'Import-TaskBranch'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('etb', 'itb')

    PrivateData = @{
        PSData = @{
            Tags         = @('TaskScheduler', 'ScheduledTasks', 'Export', 'Import', 'Automation', 'Migration')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored zu Public/Private-Struktur; StrictMode; unapproved Verb behoben (Format-TaskPath).'
        }
    }
}
