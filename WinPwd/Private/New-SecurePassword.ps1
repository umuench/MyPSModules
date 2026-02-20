function New-SecurePassword {
    param(
        [int]$Length,
        [char[]]$Chars
    )

    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $bytes = New-Object byte[] $Length
    $rng.GetBytes($bytes)

    -join ($bytes | ForEach-Object {
        $Chars[$_ % $Chars.Length]
    })
}
