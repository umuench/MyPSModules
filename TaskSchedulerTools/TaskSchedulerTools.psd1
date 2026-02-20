@{

RootModule        = 'TaskSchedulerTools.psm1'
ModuleVersion     = '1.1.0'
GUID              = '9d7a6c4e-3c5f-4f2a-b8b3-6e2f9a1c7d55'

Author            = 'Alwi'
CompanyName       = 'Private'
Copyright         = '(c) 2026 Alwi'
Description       = 'Export and Import Scheduled Task branches recursively including folder structure and credentials.'

PowerShellVersion = '5.1'
CompatiblePSEditions = @('Desktop','Core')

FunctionsToExport = @(
    'Export-TaskBranch',
    'Import-TaskBranch'
)

CmdletsToExport   = @()
VariablesToExport = '*'
AliasesToExport   = @()

FileList = @(
    'TaskSchedulerTools.psm1',
    'TaskSchedulerTools.psd1'
)

PrivateData = @{

    PSData = @{

        Tags = @(
            'TaskScheduler',
            'ScheduledTasks',
            'Export',
            'Import',
            'Automation',
            'Migration'
        )

        ReleaseNotes = '1.1.0: Added NameFilter for Export-TaskBranch. 1.0.1: Hardened export/import path handling, task enumeration, and credential compatibility.'
    }
}

}

