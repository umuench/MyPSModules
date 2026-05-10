Set-StrictMode -Version Latest

$script:ModuleBase  = $PSScriptRoot
$script:DefaultUser = 'dbuser'
$script:DefaultPass = 'dbpass'
$script:EnvConfig   = $null

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

Set-Alias -Name 'nedb' -Value 'New-EnvDB'
Export-ModuleMember -Function $Public.BaseName -Alias 'nedb'