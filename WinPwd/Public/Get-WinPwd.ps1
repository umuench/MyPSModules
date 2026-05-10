function Get-WinPwd {
    <#
    .SYNOPSIS
        Generiert ein oder mehrere kryptografisch sichere Passwoerter.
    .DESCRIPTION
        Erstellt Passwoerter der angegebenen Laenge aus einem definierten Zeichensatz
        (CharSet). Der Zeichensatz wird als .txt-Datei aus dem CharSets-Verzeichnis
        des Moduls geladen. Die Ausgabe ist ein Array von PSCustomObjects mit den
        Feldern Index und Password, was die Auswahl per -Select erleichtert.
    .PARAMETER PwLength
        Laenge jedes generierten Passworts in Zeichen (Standard: 32).
    .PARAMETER PwCount
        Anzahl der zu generierenden Passwoerter (Standard: 1).
    .PARAMETER AllowedChars
        Name des Zeichensatzes (ohne .txt-Erweiterung). Standard: 'hetzner'.
        Die Datei muss in CharSets\ des Moduls liegen.
    .PARAMETER Select
        Gibt nur das Passwort mit dem angegebenen Index zurueck (1-basiert).
    .EXAMPLE
        Get-WinPwd
        # Generiert 1 Passwort mit 32 Zeichen aus dem hetzner-Zeichensatz.
    .EXAMPLE
        Get-WinPwd -PwLength 24 -PwCount 5
        # Generiert 5 Passwoerter mit je 24 Zeichen.
    .EXAMPLE
        Get-WinPwd -PwCount 10 -Select 3
        # Generiert 10 Passwoerter und gibt nur das dritte zurueck.
    .EXAMPLE
        gwp -PwLength 16 -AllowedChars ascii
        # Kurzes Passwort aus einem benutzerdefinierten Zeichensatz.
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(8, 256)]
        [int]$PwLength = 32,

        [ValidateRange(1, 1000)]
        [int]$PwCount = 1,

        [string]$AllowedChars = 'hetzner',

        [ValidateRange(1, [int]::MaxValue)]
        [int]$Select = 0
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
