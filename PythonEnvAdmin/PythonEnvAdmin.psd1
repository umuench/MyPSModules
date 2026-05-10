@{
    RootModule           = 'PythonEnvAdmin.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID                 = '2e4dc376-7ad7-4cd0-9d60-0b18c0bd8f8e'

    Author      = 'Uwe Markus Münch'
    CompanyName = 'GFN-Retrainee'
    Copyright   = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description = 'Verwaltung und Update-Automatisierung fuer Python Virtual Environments inklusive requirements.txt, constraints.txt und Ausschlusslisten.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @(
        'Get-Venv',
        'Add-Venv',
        'Set-VenvConfig',
        'Remove-VenvEntry',
        'Enter-Venv',
        'Invoke-VenvPython',
        'Install-VenvRequirements',
        'Export-VenvRequirements',
        'Update-VenvPip',
        'Update-AllVenvs',
        'Test-Venv',
        'Find-Venvs'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Python', 'venv', 'pip', 'requirements', 'constraints', 'DevOps')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure (12+12 Funktionen); Comment-Based Help ergaenzt.'
        }
    }
}