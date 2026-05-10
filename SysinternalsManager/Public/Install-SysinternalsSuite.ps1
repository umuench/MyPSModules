function Install-SysinternalsSuite {
    <#
    .SYNOPSIS
        Installiert die Sysinternals Suite lokal.
    .DESCRIPTION
        Laedt die aktuelle Sysinternals Suite herunter, entpackt sie in den
        angegebenen Pfad, konfiguriert die PATH-Variable und akzeptiert die EULA
        fuer alle enthaltenen Tools via Registry-Eintraege.
    .PARAMETER Path
        Installationspfad.
        Standard: C:\Tools\SysInternals (User) oder C:\Program Files\SysInternals (Machine).
    .PARAMETER Scope
        'User' = nur aktueller Benutzer, kein Admin erforderlich (Standard).
        'Machine' = systemweit fuer alle Benutzer, Admin erforderlich.
    .PARAMETER Force
        Ueberschreibt eine vorhandene Installation ohne Rueckfrage.
    .PARAMETER LogPath
        Pfad zur Log-Datei (optional, empfohlen fuer Task-Scheduler-Nutzung).
    .PARAMETER Proxy
        Optionale Proxy-URL.
    .PARAMETER CachePath
        Verzeichnis zum Cachen der heruntergeladenen ZIP-Datei.
    .PARAMETER UseCache
        Verwendet eine vorhandene ZIP im CachePath.
    .PARAMETER ExpectedSha256
        Optionaler SHA256-Hash zur Integritaetspruefung.
    .EXAMPLE
        Install-SysinternalsSuite
    .EXAMPLE
        Install-SysinternalsSuite -Scope Machine
    .EXAMPLE
        Install-SysinternalsSuite -Path 'D:\DevTools\SysInternals' -Scope User
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

    if ($Scope -eq 'Machine') {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                   ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            throw 'Machine-Scope erfordert Administrator-Rechte. Bitte Terminal als Admin starten.'
        }
    }

    $existingVersion = Get-LocalVersionInfo -Path $Path
    if ($existingVersion -and -not $Force) {
        Write-Log "Sysinternals bereits installiert ($(Get-Date $existingVersion.InstalledAt -Format 'dd.MM.yyyy'))" -Level Warning -LogPath $LogPath
        Write-Log 'Verwende -Force zum Ueberschreiben oder Update-SysinternalsSuite fuer Updates.' -Level Warning -LogPath $LogPath
        return
    }

    Write-Log '==========================================================' -LogPath $LogPath
    Write-Log ' SYSINTERNALS SUITE - INSTALLATION'                          -LogPath $LogPath
    Write-Log " Pfad:  $Path"                                               -LogPath $LogPath
    Write-Log " Scope: $Scope"                                              -LogPath $LogPath
    Write-Log '==========================================================' -LogPath $LogPath

    if ($PSCmdlet.ShouldProcess($Path, 'Sysinternals Suite installieren')) {
        $result = Install-SysinternalsCore -Path $Path -Scope $Scope -LogPath $LogPath `
                      -Proxy $Proxy -CachePath $CachePath -UseCache:$UseCache -ExpectedSha256 $ExpectedSha256

        Write-Log '==========================================================' -Level Success -LogPath $LogPath
        Write-Log ' [OK] Installation abgeschlossen!'                          -Level Success -LogPath $LogPath
        Write-Log "      $($result.ToolCount) Tools installiert"              -Level Success -LogPath $LogPath
        Write-Log "      Stand: $(Get-Date $result.LastModified -Format 'dd.MM.yyyy HH:mm')" -Level Success -LogPath $LogPath
        Write-Log '==========================================================' -Level Success -LogPath $LogPath
        Write-Log ' Hinweis: Terminal neu starten fuer PATH-Aenderungen!'     -Level Warning -LogPath $LogPath

        return $result
    }
}
