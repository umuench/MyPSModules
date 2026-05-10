Set-StrictMode -Version Latest

$script:ModuleBase = $PSScriptRoot

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

$aliasesToExport = @()
$aliasMap = @(
    @{ Name = 'ism'; Value = 'Install-SysinternalsSuite' }
    @{ Name = 'usm'; Value = 'Update-SysinternalsSuite' }
    @{ Name = 'rsm'; Value = 'Register-SysinternalsUpdateTask' }
    @{ Name = 'urm'; Value = 'Unregister-SysinternalsUpdateTask' }
    @{ Name = 'ssm'; Value = 'Get-SysinternalsStatus' }
)
foreach ($a in $aliasMap) {
    $existing = Get-Alias -Name $a.Name -ErrorAction SilentlyContinue
    if (-not $existing -or $existing.Options -notmatch 'ReadOnly|Constant') {
        Set-Alias -Name $a.Name -Value $a.Value -Scope Script -Force
        $aliasesToExport += $a.Name
    }
}

Export-ModuleMember -Function $Public.BaseName -Alias $aliasesToExport
