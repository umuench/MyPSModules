function Set-PowerShellCodeSignature {
    <#
    .SYNOPSIS
        Signiert PowerShell-Skripte und -Module unter einem angegebenen Pfad mit einer Authenticode-Signatur.
    .DESCRIPTION
        Sucht rekursiv alle .ps1- und .psm1-Dateien unter Path und versieht sie mit einer
        Authenticode-Signatur aus dem Zertifikatspeicher CurrentUser\My. Unterstuetzt -WhatIf.
    .PARAMETER Path
        Stammverzeichnis oder Dateipfad, der signiert werden soll. Wird rekursiv durchsucht.
    .PARAMETER SubjectMatch
        Teilstring fuer den Abgleich mit dem Zertifikat-Subject. Wird an Get-CodeSigningCertificate weitergegeben.
    .PARAMETER Thumbprint
        Exakter Thumbprint des Zertifikats. Hat Vorrang vor SubjectMatch.
    .PARAMETER TimestampServer
        URL des RFC-3161-Zeitstempelservers. Standard: http://timestamp.digicert.com
    .EXAMPLE
        Set-PowerShellCodeSignature -Path 'C:\Modules\MyModule'
        Signiert alle .ps1/.psm1-Dateien unter MyModule mit dem Standardzertifikat.
    .EXAMPLE
        Set-PowerShellCodeSignature -Path 'C:\Modules\MyModule' -WhatIf
        Zeigt, welche Dateien signiert wuerden, ohne Aenderungen vorzunehmen.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$SubjectMatch = "Uwe Markus Münch - PowerShell Code Signing",

        [string]$Thumbprint,

        [string]$TimestampServer = "http://timestamp.digicert.com"
    )

    if (-not (Test-Path $Path)) {
        throw "Pfad existiert nicht: $Path"
    }

    try {
        $cert = Get-CodeSigningCertificate -SubjectMatch $SubjectMatch -Thumbprint $Thumbprint
    }
    catch {
        throw "Zertifikat konnte nicht abgerufen werden: $_"
    }

    $files = Get-ChildItem $Path -Recurse -File -Include *.ps1, *.psm1

    if (-not $files) {
        Write-Warning "Keine signierbaren Dateien gefunden unter: $Path"
        return
    }

    foreach ($file in $files) {
        if ($PSCmdlet.ShouldProcess($file.FullName, "Set Authenticode Signature")) {
            try {
                $result = Set-AuthenticodeSignature `
                    -FilePath $file.FullName `
                    -Certificate $cert `
                    -TimestampServer $TimestampServer

                [PSCustomObject]@{
                    File   = $file.FullName
                    Status = $result.Status
                }
            }
            catch {
                Write-Warning "Signierung fehlgeschlagen fuer '$($file.FullName)': $_"
            }
        }
    }
}