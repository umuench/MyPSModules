Set-StrictMode -Version Latest

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

Set-Alias -Name 'ssk' -Value 'Sync-SSHKeyStore'
Export-ModuleMember -Function $Public.BaseName -Alias 'ssk'