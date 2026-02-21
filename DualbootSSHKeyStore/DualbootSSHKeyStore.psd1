@{
    RootModule        = 'DualbootSSHKeyStore.psm1'
    ModuleVersion     = '1.0.1'
    CompatiblePSEditions = @('Desktop','Core')
    Author            = 'Alwi'
    Description       = 'Safely sync SSH KeyStores between dual-boot Windows installations'
    PowerShellVersion = '7.0'
    FunctionsToExport = @('Sync-SSHKeyStore')
    AliasesToExport   = @('ssk')
    PrivateData = @{
        PSData = @{
            ReleaseNotes = @'
Version 1.0.1
- Added -Force and -SkipAcl for safer syncs
- Respects -WhatIf for directory preparation and ACL changes
'@
        }
    }
}
