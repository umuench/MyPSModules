function New-SecurePassword {
    <#
    .SYNOPSIS
        Generiert ein einzelnes kryptografisch sicheres Passwort.
    .DESCRIPTION
        Verwendet System.Security.Cryptography.RandomNumberGenerator fuer
        kryptografisch starke Zufallsbytes. Jedes Byte wird modulo der Zeichensatz-
        Laenge auf einen Zeichensatz-Index abgebildet. Der RNG wird nach Verwendung
        korrekt freigegeben.
    .PARAMETER Length
        Laenge des zu generierenden Passworts.
    .PARAMETER Chars
        Zeichensatz als char[]-Array.
    .EXAMPLE
        New-SecurePassword -Length 32 -Chars 'ABCabc123'.ToCharArray()
    #>
    param(
        [Parameter(Mandatory)]
        [int]$Length,

        [Parameter(Mandatory)]
        [char[]]$Chars
    )

    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $bytes = New-Object byte[] $Length
        $rng.GetBytes($bytes)
        -join ($bytes | ForEach-Object { $Chars[$_ % $Chars.Length] })
    }
    finally {
        $rng.Dispose()
    }
}
