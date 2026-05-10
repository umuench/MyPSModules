Set-StrictMode -Version Latest

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

$aliasesToExport = @()
Set-ModuleAlias -Name 'gcsc' -Value 'Get-CodeSigningCertificate' -ExportList ([ref]$aliasesToExport)
Set-ModuleAlias -Name 'scs' -Value 'Set-PowerShellCodeSignature' -ExportList ([ref]$aliasesToExport)

Export-ModuleMember -Function $Public.BaseName -Alias $aliasesToExport