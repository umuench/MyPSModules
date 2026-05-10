@{
    RootModule           = 'SysinternalsManager.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')

    GUID                 = 'f7e8d9c0-b1a2-4c3d-8e5f-6a7b8c9d0e1f'

    Author               = 'Uwe Markus Münch'
    CompanyName          = 'GFN-Retrainee'
    Copyright            = '(c) 2026 Uwe Markus Münch. All rights reserved.'

    Description          = 'Installation, Update und automatische Wartung der Microsoft Sysinternals Suite. Unterstuetzt User- und Machine-Scope, Task-Scheduler-Integration und Proxy-Konfiguration.'

    PowerShellVersion    = '5.1'

    FunctionsToExport = @(
        'Install-SysinternalsSuite',
        'Update-SysinternalsSuite',
        'Register-SysinternalsUpdateTask',
        'Unregister-SysinternalsUpdateTask',
        'Get-SysinternalsStatus'
    )

    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('ism', 'usm', 'rsm', 'urm', 'ssm')

    PrivateData = @{
        PSData = @{
            Tags         = @('Sysinternals', 'Windows', 'Administration', 'Tools', 'TaskScheduler', 'Automation')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored zu Public/Private-Struktur; PS5.1-kompatibel; StrictMode-Fixes.'
        }
    }
}
