function Get-SysinternalsStatus {
    <#
    .SYNOPSIS
        Zeigt den aktuellen Status der Sysinternals-Installation und des Update-Tasks.
    .DESCRIPTION
        Prueft die lokale Installation (Pfad, Installationsdatum, Tool-Anzahl),
        vergleicht mit der Remote-Version und zeigt den Status des geplanten Tasks.
    .PARAMETER Path
        Installationspfad.
        Standard: C:\Tools\SysInternals (User) oder C:\Program Files\SysInternals (Machine).
    .PARAMETER Scope
        'User' oder 'Machine' (Standard: 'User').
    .PARAMETER TaskPath
        Ordnerpfad in der Aufgabenplanung (Standard: '\Eigene\System\').
    .PARAMETER Proxy
        Optionale Proxy-URL fuer die Remote-Versionspruefung.
    .EXAMPLE
        Get-SysinternalsStatus
    .EXAMPLE
        Get-SysinternalsStatus -Scope Machine -TaskPath '\Wartung\'
    #>
    [CmdletBinding()]
    param(
        [string]$Path,

        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User',

        [string]$TaskPath = '\Eigene\System\',

        [string]$Proxy
    )

    if (-not $TaskPath.StartsWith('\')) { $TaskPath = "\$TaskPath" }
    if (-not $TaskPath.EndsWith('\'))   { $TaskPath = "$TaskPath\" }

    if (-not $Path) {
        $Path = switch ($Scope) {
            'User'    { 'C:\Tools\SysInternals' }
            'Machine' { 'C:\Program Files\SysInternals' }
        }
    }

    $taskName = "SysinternalsUpdate_$Scope"

    Write-Host ''
    Write-Host '==========================================================' -ForegroundColor Cyan
    Write-Host ' SYSINTERNALS SUITE - STATUS'                               -ForegroundColor Cyan
    Write-Host '==========================================================' -ForegroundColor Cyan

    $localVersion = Get-LocalVersionInfo -Path $Path
    if ($localVersion) {
        Write-Host ''
        Write-Host ' Installation:' -ForegroundColor White
        Write-Host "   Pfad:         $Path"                                                            -ForegroundColor Gray
        Write-Host "   Installiert:  $(Get-Date $localVersion.InstalledAt -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        Write-Host "   Suite-Stand:  $(Get-Date $localVersion.LastModified -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        Write-Host "   Tools:        $($localVersion.ToolCount)"                                       -ForegroundColor Gray

        try {
            $remoteInfo      = Get-SysinternalsDownloadInfo -Proxy $Proxy
            $updateAvailable = $remoteInfo.LastModified -gt $localVersion.LastModified

            Write-Host ''
            Write-Host ' Update-Status:' -ForegroundColor White
            Write-Host "   Remote-Stand: $(Get-Date $remoteInfo.LastModified -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray

            if ($updateAvailable) {
                Write-Host '   Status:       UPDATE VERFUEGBAR' -ForegroundColor Yellow
            } else {
                Write-Host '   Status:       Aktuell'           -ForegroundColor Green
            }
        }
        catch {
            Write-Host '   Status:       Konnte nicht geprueft werden' -ForegroundColor Yellow
        }
    } else {
        Write-Host ''
        Write-Host ' Installation:   NICHT INSTALLIERT'        -ForegroundColor Yellow
        Write-Host "   Erwarteter Pfad: $Path"                 -ForegroundColor Gray
    }

    $task = Get-ScheduledTask -TaskPath $TaskPath -TaskName $taskName -ErrorAction SilentlyContinue
    Write-Host ''
    Write-Host ' Scheduled Task:' -ForegroundColor White
    if ($task) {
        $taskInfo = Get-ScheduledTaskInfo -TaskPath $TaskPath -TaskName $taskName
        Write-Host "   Name:          $taskName"               -ForegroundColor Gray
        Write-Host "   Ordner:        $TaskPath"               -ForegroundColor Gray
        Write-Host "   Status:        $($task.State)"          -ForegroundColor Gray
        if ($taskInfo.LastRunTime -and $taskInfo.LastRunTime -ne [DateTime]::MinValue) {
            Write-Host "   Letzte Ausf.:  $(Get-Date $taskInfo.LastRunTime  -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        }
        if ($taskInfo.NextRunTime) {
            Write-Host "   Naechste Ausf.: $(Get-Date $taskInfo.NextRunTime -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        }
    } else {
        Write-Host '   Status:        Nicht konfiguriert'       -ForegroundColor Yellow
        Write-Host "   Erwarteter Ordner: $TaskPath"            -ForegroundColor Gray
    }

    Write-Host ''
    Write-Host '==========================================================' -ForegroundColor Cyan
    Write-Host ''
}
