# WinPwd module loader
Get-ChildItem $PSScriptRoot\Public\*.ps1 | ForEach-Object { . $_ }
Get-ChildItem $PSScriptRoot\Private\*.ps1 | ForEach-Object { . $_ }

Set-Alias -Name gwp -Value Get-WinPwd
Export-ModuleMember -Function Get-WinPwd -Alias gwp
