Set-StrictMode -Version Latest

$script:DefaultTemplatePaths = @(
    $env:GITIGNORE_TEMPLATES,
    'C:\ProgramData\Git\Templates',
    (Join-Path $PSScriptRoot 'Templates')
) | Where-Object { $_ -and $_.Trim() -ne '' }

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

Set-Alias -Name 'ngi' -Value 'New-GitIgnore'
Export-ModuleMember -Function $Public.BaseName -Alias 'ngi'