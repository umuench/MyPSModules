function Get-CodeSigningCertificate {
    <#
    .SYNOPSIS
        Ruft ein Code-Signing-Zertifikat aus dem Zertifikatspeicher des aktuellen Benutzers ab.
    .DESCRIPTION
        Durchsucht den Speicher CurrentUser\My nach einem gueltigen Code-Signing-Zertifikat
        mit privatem Schluessel. Auswahl erfolgt per Betreffname oder Thumbprint; bei mehreren
        Treffern wird das zuletzt ablaufende Zertifikat zurueckgegeben.
    .PARAMETER SubjectMatch
        Teilstring fuer den Abgleich mit dem Subject-Feld des Zertifikats.
        Standard: "Uwe Markus Muench - PowerShell Code Signing".
    .PARAMETER Thumbprint
        Exakter Thumbprint des Zertifikats. Hat Vorrang vor SubjectMatch.
    .EXAMPLE
        Get-CodeSigningCertificate
        Gibt das Standard-Code-Signing-Zertifikat anhand des Betreffnamens zurueck.
    .EXAMPLE
        Get-CodeSigningCertificate -Thumbprint 'ABCDEF1234567890'
        Gibt das Zertifikat mit dem angegebenen Thumbprint zurueck.
    #>
    [CmdletBinding()]
    param(
        [string]$SubjectMatch = "Uwe Markus Münch - PowerShell Code Signing",
        [string]$Thumbprint
    )

    if ($Thumbprint) {
        $cert = Get-ChildItem Cert:\CurrentUser\My |
            Where-Object { $_.Thumbprint -eq $Thumbprint -and $_.HasPrivateKey } |
            Select-Object -First 1
    }
    else {
        $cert = Get-ChildItem Cert:\CurrentUser\My |
            Where-Object {
                $_.Subject -like "*$SubjectMatch*" -and
                $_.HasPrivateKey
            } |
            Sort-Object NotAfter -Descending |
            Select-Object -First 1
    }

    if (-not $cert) {
        if ($Thumbprint) {
            throw "Kein Code-Signing-Zertifikat mit Thumbprint '$Thumbprint' gefunden."
        }
        throw "Kein Code-Signing-Zertifikat mit Subject '$SubjectMatch' gefunden."
    }

    return $cert
}