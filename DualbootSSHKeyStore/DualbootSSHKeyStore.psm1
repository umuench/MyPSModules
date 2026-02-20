function Sync-SSHKeyStore {
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
        throw "Source path does not exist: $Source"
    }

    if ($PSCmdlet.ShouldProcess($Target, "Sync SSH KeyStore vorbereiten")) {
        if (-not (Test-Path $Target)) {
            New-Item -ItemType Directory -Path $Target -Force | Out-Null
        }
    }

    # 🔐 Ziel-SID ermitteln (dualboot-sicher)
    $TargetSid = (Get-Acl $Target).Owner
    Write-Verbose "Detected target SID: $TargetSid"

    if (-not $SkipAcl -and $PSCmdlet.ShouldProcess($Target, "ACLs temporär anpassen")) {
        # Temporär Besitz übernehmen
        Write-Verbose "Taking temporary ownership"
        takeown /F $Target /R /D J | Out-Null
        icacls $Target /grant "${env:USERNAME}:(OI)(CI)F" /T | Out-Null
    }

    # Nur fehlende Ordner kopieren
    Get-ChildItem $Source -Directory | ForEach-Object {

        $destinationPath = Join-Path $Target $_.Name

        if (-not (Test-Path $destinationPath)) {
            if ($PSCmdlet.ShouldProcess($_.Name, "Copy SSH KeyStore")) {
                Write-Host "➕ Sync: $($_.Name)"
                Copy-Item $_.FullName $destinationPath -Recurse -Force
            }
        }
        else {
            if ($Force -and $PSCmdlet.ShouldProcess($_.Name, "Overwrite SSH KeyStore")) {
                Write-Host "🔁 Overwrite: $($_.Name)"
                Remove-Item $destinationPath -Recurse -Force
                Copy-Item $_.FullName $destinationPath -Recurse -Force
            }
            else {
                Write-Verbose "Already exists: $($_.Name)"
            }
        }
    }

    if (-not $SkipAcl -and $PSCmdlet.ShouldProcess($Target, "ACLs zuruecksetzen")) {
        # 🔒 Rechte sauber zurücksetzen (SID-basiert)
        Write-Verbose "Restoring secure SSH permissions"
        icacls $Target /inheritance:r | Out-Null
        icacls $Target /grant "${TargetSid}:(OI)(CI)F" "SYSTEM:(OI)(CI)F" /T | Out-Null
        icacls $Target /remove "${env:USERNAME}" /T | Out-Null
    }

    Write-Host "✅ SSH KeyStore sync completed successfully."
}

Export-ModuleMember -Function Sync-SSHKeyStore

