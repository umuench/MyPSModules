Set-StrictMode -Version Latest

$script:ModuleBase           = $PSScriptRoot
$script:RegistryPath         = Join-Path -Path $PSScriptRoot -ChildPath 'venvs.json'
$script:GlobalConstraintsPath = Join-Path -Path $PSScriptRoot -ChildPath 'constraints.global.txt'

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

Export-ModuleMember -Function $Public.BaseName