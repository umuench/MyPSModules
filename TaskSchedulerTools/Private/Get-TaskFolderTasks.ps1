function Get-TaskFolderTasks {
    <#
    .SYNOPSIS
        Listet alle Tasks in einem Task-Scheduler-Ordner und seinen Unterordnern auf.
    .DESCRIPTION
        Liest alle geplanten Tasks via Get-ScheduledTask und filtert nach dem
        angegebenen Ordnerpfad (inklusive Unterordner). Gibt fuer jeden Task
        ein Objekt mit TaskName und TaskPath zurueck.
    .PARAMETER TaskPath
        Task-Scheduler-Pfad als Startpunkt (Standard: '\'  = alle Tasks).
    .EXAMPLE
        Get-TaskFolderTasks -TaskPath '\Eigene\'
    #>
    param(
        [string]$TaskPath = '\'
    )

    $normalizedTaskPath = Format-TaskPath -Path $TaskPath -EnsureTrailing

    try {
        $allTasks = @(Get-ScheduledTask -ErrorAction Stop)
    }
    catch {
        Write-Warning "Tasks konnten nicht gelesen werden: $($_.Exception.Message)"
        return
    }

    foreach ($task in $allTasks) {
        if (-not $task -or -not $task.TaskPath -or -not $task.TaskName) { continue }

        if ($normalizedTaskPath -eq '\' -or
            $task.TaskPath.StartsWith($normalizedTaskPath, [System.StringComparison]::OrdinalIgnoreCase)) {

            [PSCustomObject]@{
                TaskName = $task.TaskName
                TaskPath = $task.TaskPath
            }
        }
    }
}
