@{
    RootModule           = 'DualbootSSHKeyStore.psm1'
    ModuleVersion        = '1.0.0.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID                 = '1064a558-1bbe-48c6-94d7-dc1823dee4c4'

    Author      = 'Uwe Markus Münch'
    CompanyName = 'GFN-Retrainee'
    Copyright   = '(c) 2026 Uwe Markus Münch. All rights reserved.'
    Description = 'Synchronisiert SSH-KeyStore-Verzeichnisse sicher zwischen zwei Dual-Boot-Windows-Installationen.'

    PowerShellVersion = '5.1'

    FunctionsToExport = @('Sync-SSHKeyStore')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('ssk')

    PrivateData = @{
        PSData = @{
            Tags         = @('SSH', 'DualBoot', 'Security', 'KeyStore', 'ACL', 'Windows')
            ProjectUri   = 'local'
            ReleaseNotes = 'Version 1.0.0.0 - Refactored to Public/Private structure; Comment-Based Help ergaenzt; PS 5.1-Kompatibilitaet.'
        }
    }
}