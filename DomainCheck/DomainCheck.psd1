@{
    RootModule        = 'DomainCheck.psm1'
    ModuleVersion     = '1.0.1'
    GUID              = '8c9d2a14-7c8c-4c8f-bb6c-1b4e2a7c5a01'
    Author            = 'Uwe Markus Münch'
    CompanyName       = 'Private'
    PowerShellVersion = '7.0'
    Description       = 'Domain DNS Check (NS / A) für Monitoring & Aufgabenplanung'
    FunctionsToExport = @('Test-DomainDns')
    AliasesToExport   = @('tdd')
    PrivateData = @{
        PSData = @{
            ReleaseNotes = @'
Version 1.0.1
- Retry parameters for DNS queries
- Optional object output switch
'@
        }
    }
}
