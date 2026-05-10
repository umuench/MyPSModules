function Update-SysinternalsSuite {
    <#
    .SYNOPSIS
        Aktualisiert die Sysinternals Suite, falls eine neue Version verfuegbar ist.
    .DESCRIPTION
        Prueft anhand des HTTP-Last-Modified-Headers, ob eine neue Version auf dem
        Microsoft-Server bereitsteht, und fuehrt bei Bedarf ein Update durch.
        Ideal fuer den Einsatz im Task Scheduler.
    .PARAMETER Path
        Installationspfad.
        Standard: C:\Tools\SysInternals (User) oder C:\Program Files\SysInternals (Machine).
    .PARAMETER Scope
        'User' = nur aktueller Benutzer (Standard). 'Machine' = systemweit (Admin noetig).
    .PARAMETER Force
        Update erzwingen, auch wenn keine neue Version erkannt wurde.
    .PARAMETER LogPath
        Pfad zur Log-Datei (empfohlen fuer Task-Scheduler-Ausfuehrung).
    .PARAMETER Proxy
        Optionale Proxy-URL.
    .PARAMETER CachePath
        Verzeichnis zum Cachen der heruntergeladenen ZIP-Datei.
    .PARAMETER UseCache
        Verwendet eine vorhandene ZIP im CachePath.
    .PARAMETER ExpectedSha256
        Optionaler SHA256-Hash zur Integritaetspruefung.
    .EXAMPLE
        Update-SysinternalsSuite
    .EXAMPLE
        Update-SysinternalsSuite -Force
    .EXAMPLE
        Update-SysinternalsSuite -LogPath 'C:\Logs\sysinternals-update.log'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path,

        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User',

        [switch]$Force,
        [string]$LogPath,
        [string]$Proxy,
        [string]$CachePath,
        [switch]$UseCache,
        [string]$ExpectedSha256
    )

    if (-not $Path) {
        $Path = switch ($Scope) {
            'User'    { 'C:\Tools\SysInternals' }
            'Machine' { 'C:\Program Files\SysInternals' }
        }
    }

    Write-Log '==========================================================' -LogPath $LogPath
    Write-Log ' SYSINTERNALS SUITE - UPDATE CHECK'                          -LogPath $LogPath
    Write-Log " Pfad:  $Path"                                               -LogPath $LogPath
    Write-Log " Scope: $Scope"                                              -LogPath $LogPath
    Write-Log '==========================================================' -LogPath $LogPath

    $localVersion = Get-LocalVersionInfo -Path $Path
    if (-not $localVersion) {
        Write-Log 'Keine Installation gefunden. Fuehre Install-SysinternalsSuite aus.' -Level Warning -LogPath $LogPath
        return
    }

    Write-Log "Lokale Version:  $(Get-Date $localVersion.LastModified -Format 'dd.MM.yyyy HH:mm')" -LogPath $LogPath

    try {
        $remoteInfo = Get-SysinternalsDownloadInfo -Proxy $Proxy
        Write-Log "Remote Version:  $(Get-Date $remoteInfo.LastModified -Format 'dd.MM.yyyy HH:mm')" -LogPath $LogPath
    }
    catch {
        Write-Log "Fehler beim Pruefen der Remote-Version: $_" -Level Error -LogPath $LogPath
        return
    }

    $updateAvailable = $remoteInfo.LastModified -gt $localVersion.LastModified

    if ($updateAvailable -or $Force) {
        if ($Force -and -not $updateAvailable) {
            Write-Log 'Update erzwungen (keine neue Version erkannt)' -Level Warning -LogPath $LogPath
        } else {
            Write-Log 'Neue Version verfuegbar!' -Level Success -LogPath $LogPath
        }

        if ($Scope -eq 'Machine') {
            $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                       ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            if (-not $isAdmin) {
                Write-Log 'Machine-Scope erfordert Administrator-Rechte.' -Level Error -LogPath $LogPath
                throw 'Machine-Scope erfordert Administrator-Rechte.'
            }
        }

        if ($PSCmdlet.ShouldProcess($Path, 'Sysinternals Suite aktualisieren')) {
            $result = Install-SysinternalsCore -Path $Path -Scope $Scope -LogPath $LogPath `
                          -Proxy $Proxy -CachePath $CachePath -UseCache:$UseCache -ExpectedSha256 $ExpectedSha256

            Write-Log '==========================================================' -Level Success -LogPath $LogPath
            Write-Log ' [OK] Update abgeschlossen!'                                -Level Success -LogPath $LogPath
            Write-Log "      $($result.ToolCount) Tools aktualisiert"             -Level Success -LogPath $LogPath
            Write-Log "      Neuer Stand: $(Get-Date $result.LastModified -Format 'dd.MM.yyyy HH:mm')" -Level Success -LogPath $LogPath
            Write-Log '==========================================================' -Level Success -LogPath $LogPath

            return $result
        }
    } else {
        Write-Log '==========================================================' -Level Success -LogPath $LogPath
        Write-Log ' [OK] Bereits auf dem neuesten Stand'                       -Level Success -LogPath $LogPath
        Write-Log '==========================================================' -Level Success -LogPath $LogPath
    }
}
