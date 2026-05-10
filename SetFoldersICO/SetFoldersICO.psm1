Set-StrictMode -Version Latest

$inkscapeCmd = Get-Command inkscape -ErrorAction SilentlyContinue
$script:DefaultInkscapePaths = @(
    $env:INKSCAPE_PATH,
    'C:\Program Files\Inkscape\bin\inkscape.exe',
    'C:\Program Files (x86)\Inkscape\bin\inkscape.exe',
    "$env:LOCALAPPDATA\Programs\Inkscape\bin\inkscape.exe",
    $(if ($inkscapeCmd) { $inkscapeCmd.Source } else { $null })
) | Where-Object { $_ -and (Test-Path $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1

Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue

$Private = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
$Public  = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1"  -ErrorAction SilentlyContinue

foreach ($import in (@($Private) + @($Public))) {
    . $import.FullName
}

Initialize-TechData

$aliasesToExport = @()
$aliasMap = @(
    @{ Name = 'sfdi'; Value = 'Set-DevFolderIcons' }
    @{ Name = 'sfi';  Value = 'Set-FolderIcon' }
    @{ Name = 'rfi';  Value = 'Remove-FolderIcon' }
    @{ Name = 'gtd';  Value = 'Get-TechDefinitions' }
    @{ Name = 'nfi';  Value = 'New-FolderIcon' }
)
foreach ($a in $aliasMap) {
    $existing = Get-Alias -Name $a.Name -ErrorAction SilentlyContinue
    if (-not $existing -or $existing.Options -notmatch 'ReadOnly|Constant') {
        Set-Alias -Name $a.Name -Value $a.Value -Scope Script -Force
        $aliasesToExport += $a.Name
    }
}

Export-ModuleMember -Function $Public.BaseName -Alias $aliasesToExport
