function Sync-SSHKeyStore {
    <#
    .SYNOPSIS
        Synchronisiert SSH-KeyStore-Verzeichnisse zwischen zwei Dual-Boot-Windows-Installationen.
    .DESCRIPTION
        Kopiert fehlende SSH-Key-Ordner aus einem Quellpfad in einen Zielpfad.
        Uebernimmt bei Bedarf temporaer den Besitz am Zielverzeichnis via takeown/icacls
        und stellt die urspruenglichen Berechtigungen anschliessend wieder her.
        Unterstuetzt -WhatIf fuer alle destruktiven Aktionen.
    .PARAMETER Source
        Pfad zum Quell-SSH-KeyStore (z.B. Verzeichnis der anderen Windows-Installation).
    .PARAMETER Target
        Pfad zum Ziel-SSH-KeyStore der aktuellen Installation.
    .PARAMETER Force
        Ueberschreibt vorhandene SSH-Key-Ordner im Ziel.
    .PARAMETER SkipAcl
        Ueberspringt die ACL-Anpassung (takeown/icacls). Sinnvoll wenn der aufrufende
        Benutzer bereits Vollzugriff auf das Zielverzeichnis hat.
    .EXAMPLE
        Sync-SSHKeyStore -Source 'D:\Users\umuench\.ssh' -Target 'C:\Users\umuench\.ssh'
        Kopiert fehlende SSH-Ordner von Laufwerk D nach C.
    .EXAMPLE
        Sync-SSHKeyStore -Source 'D:\Users\umuench\.ssh' -Target 'C:\Users\umuench\.ssh' -Force -WhatIf
        Zeigt, welche Ordner ueberschrieben wuerden, ohne Aenderungen vorzunehmen.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Target,

        [switch]$Force,

        [switch]$SkipAcl
    )

    Write-Verbose "Source: $Source"
    Write-Verbose "Target: $Target"

    if (-not (Test-Path $Source)) {
        throw "Quellpfad existiert nicht: $Source"
    }

    if ($PSCmdlet.ShouldProcess($Target, "Zielverzeichnis vorbereiten")) {
        if (-not (Test-Path $Target)) {
            New-Item -ItemType Directory -Path $Target -Force | Out-Null
        }
    }

    $targetOwner = (Get-Acl $Target).Owner
    Write-Verbose "Ziel-Eigentuemer: $targetOwner"

    if (-not $SkipAcl -and $PSCmdlet.ShouldProcess($Target, "ACLs temporaer anpassen")) {
        Write-Verbose "Uebernehme temporaer Besitz am Zielverzeichnis."
        takeown /F $Target /R /D J | Out-Null
        icacls $Target /grant "${env:USERNAME}:(OI)(CI)F" /T | Out-Null
    }

    Get-ChildItem $Source -Directory | ForEach-Object {
        $destinationPath = Join-Path $Target $_.Name

        if (-not (Test-Path $destinationPath)) {
            if ($PSCmdlet.ShouldProcess($_.Name, "SSH-KeyStore kopieren")) {
                Write-Host "[+] Sync: $($_.Name)"
                Copy-Item $_.FullName $destinationPath -Recurse -Force
            }
        }
        elseif ($Force) {
            if ($PSCmdlet.ShouldProcess($_.Name, "SSH-KeyStore ueberschreiben")) {
                Write-Host "[>] Overwrite: $($_.Name)"
                Remove-Item $destinationPath -Recurse -Force
                Copy-Item $_.FullName $destinationPath -Recurse -Force
            }
        }
        else {
            Write-Verbose "Bereits vorhanden, uebersprungen: $($_.Name)"
        }
    }

    if (-not $SkipAcl -and $PSCmdlet.ShouldProcess($Target, "ACLs wiederherstellen")) {
        Write-Verbose "Stelle sichere SSH-Berechtigungen wieder her."
        icacls $Target /inheritance:r | Out-Null
        icacls $Target /grant "${targetOwner}:(OI)(CI)F" "SYSTEM:(OI)(CI)F" /T | Out-Null
        icacls $Target /remove "${env:USERNAME}" /T | Out-Null
    }

    Write-Host "[OK] SSH KeyStore-Synchronisierung abgeschlossen."
}