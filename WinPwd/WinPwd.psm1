Set-StrictMode -Version Latest

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

$aliasesToExport = @()
$existing = Get-Alias -Name 'gwp' -ErrorAction SilentlyContinue
if (-not $existing -or $existing.Options -notmatch 'ReadOnly|Constant') {
    Set-Alias -Name 'gwp' -Value 'Get-WinPwd' -Scope Script -Force
    $aliasesToExport += 'gwp'
}

Export-ModuleMember -Function $Public.BaseName -Alias $aliasesToExport
