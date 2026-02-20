function Get-WinPwd {
    param(
        [int]$PwLength = 32,
        [int]$PwCount = 1,
        [string]$AllowedChars = "hetzner",
        [int]$Select
    )

    $chars = Read-CharSet $AllowedChars

    $result = 1..$PwCount | ForEach-Object {
        [PSCustomObject]@{
            Index    = $_
            Password = New-SecurePassword -Length $PwLength -Chars $chars
        }
    }

    if ($Select) {
        return $result | Where-Object Index -eq $Select
    }

    return $result
}
