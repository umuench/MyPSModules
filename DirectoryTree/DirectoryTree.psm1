Set-StrictMode -Version Latest

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

Set-Alias -Name 'gdt' -Value 'Get-DirectoryTree'
Export-ModuleMember -Function $Public.BaseName -Alias 'gdt'