@{
    RootModule = 'WinPwd.psm1'
    ModuleVersion = '1.2.0'
    GUID = 'e3b6b3c2-1d4f-4d8c-9f42-123456789abc'
    Author = 'WinPwd'
    Description = 'Enterprise-grade password generator with policy separation and indexed output'
    PowerShellVersion = '5.1'
    PrivateData = @{
        PSData = @{
            ReleaseNotes = @'
Version 1.2.0
- Default AllowedChars to hetzner
- Case-insensitive charset resolution
'@
        }
    }
}
