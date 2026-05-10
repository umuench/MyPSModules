function Convert-SecureStringToString {
    <#
    .SYNOPSIS
        Wandelt einen SecureString in Klartext um (fuer .env-Dateiausgabe).
    .DESCRIPTION
        Verwendet Marshal-Methoden, um den SecureString sicher zu lesen und den Speicher
        anschliessend zu nullen (ZeroFreeGlobalAllocUnicode).
    .PARAMETER SecureString
        Der zu konvertierende SecureString.
    .EXAMPLE
        $plain = Convert-SecureStringToString -SecureString $secureInput
    #>
    param(
        [Parameter(Mandatory)]
        [System.Security.SecureString]$SecureString
    )

    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($SecureString)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($ptr)
    }
}