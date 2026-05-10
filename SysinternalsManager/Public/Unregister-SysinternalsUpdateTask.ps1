function Unregister-SysinternalsUpdateTask {
    <#
    .SYNOPSIS
        Entfernt den Scheduled Task fuer Sysinternals-Updates.
    .DESCRIPTION
        Loescht den geplanten Task 'SysinternalsUpdate_<Scope>' aus dem angegebenen
        Task-Scheduler-Ordner. Gibt eine Warnung aus, wenn der Task nicht gefunden wird.
    .PARAMETER Scope
        'User' oder 'Machine' - bestimmt welcher Task entfernt wird (Standard: 'User').
    .PARAMETER TaskPath
        Ordnerpfad in der Aufgabenplanung (Standard: '\Eigene\System\').
    .EXAMPLE
        Unregister-SysinternalsUpdateTask
    .EXAMPLE
        Unregister-SysinternalsUpdateTask -Scope Machine -TaskPath '\Wartung\'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User',

        [string]$TaskPath = '\Eigene\System\'
    )

    if (-not $TaskPath.StartsWith('\')) { $TaskPath = "\$TaskPath" }
    if (-not $TaskPath.EndsWith('\'))   { $TaskPath = "$TaskPath\" }

    $taskName = "SysinternalsUpdate_$Scope"

    if ($PSCmdlet.ShouldProcess("$TaskPath$taskName", 'Scheduled Task entfernen')) {
        $existingTask = Get-ScheduledTask -TaskPath $TaskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $taskName -Confirm:$false
            Write-Host "[OK] Task '$TaskPath$taskName' erfolgreich entfernt" -ForegroundColor Green
        } else {
            Write-Host "Task '$TaskPath$taskName' nicht gefunden" -ForegroundColor Yellow
        }
    }
}
