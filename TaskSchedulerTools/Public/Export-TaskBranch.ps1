function Export-TaskBranch {
    <#
    .SYNOPSIS
        Exportiert einen Task-Scheduler-Ordner und alle Unterordner als XML-Dateien.
    .DESCRIPTION
        Liest alle geplanten Tasks unterhalb von TaskPath und speichert jeden Task
        als separate XML-Datei in BackupPath. Die Ordnerstruktur des Task-Schedulers
        wird im Backup-Verzeichnis nachgebildet.
        Unterstuetzt optionale Namensfilter und ShouldProcess (-WhatIf/-Confirm).
    .PARAMETER TaskPath
        Task-Scheduler-Ausgangspfad (Standard: '\Eigene\').
    .PARAMETER BackupPath
        Zielverzeichnis fuer die exportierten XML-Dateien (Standard: 'C:\TaskBackup').
    .PARAMETER NameFilter
        Optionale Wildcard-Filter fuer Task-Namen (z.B. @('Sysinternals*', 'Backup*')).
    .EXAMPLE
        Export-TaskBranch
    .EXAMPLE
        Export-TaskBranch -TaskPath '\Eigene\System\' -BackupPath 'D:\Backup\Tasks'
    .EXAMPLE
        Export-TaskBranch -NameFilter 'Sysinternals*' -BackupPath 'D:\Backup'
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        [string]$TaskPath   = '\Eigene\',
        [string]$BackupPath = 'C:\TaskBackup',
        [string[]]$NameFilter
    )

    $TaskPath = Format-TaskPath -Path $TaskPath -EnsureTrailing

    Write-Host "Exportiere Tasks aus $TaskPath ..." -ForegroundColor Cyan

    if ($PSCmdlet.ShouldProcess($BackupPath, 'Backup-Ordner erstellen/aktualisieren')) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    }

    $tasks = @(Get-TaskFolderTasks $TaskPath)

    if ($NameFilter -and $NameFilter.Count -gt 0) {
        $tasks = $tasks | Where-Object {
            $name = $_.TaskName
            $NameFilter | Where-Object { $name -like $_ }
        }
    }

    if ($tasks.Count -eq 0) {
        Write-Warning "Keine Tasks unter '$TaskPath' gefunden oder Ordner nicht lesbar."
        Write-Host 'Export abgeschlossen.' -ForegroundColor Green
        return
    }

    foreach ($task in $tasks) {
        if (-not $task -or -not $task.TaskPath -or -not $task.TaskName) { continue }

        if ($task.TaskPath.StartsWith($TaskPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $task.TaskPath.Substring($TaskPath.Length)
        } else {
            $relativePath = $task.TaskPath.Trim('\')
        }

        if ([string]::IsNullOrWhiteSpace($relativePath)) {
            $targetFolder = $BackupPath
        } else {
            $targetFolder = Join-Path $BackupPath $relativePath
        }

        $safeTaskName = $task.TaskName
        foreach ($invalidChar in [System.IO.Path]::GetInvalidFileNameChars()) {
            $safeTaskName = $safeTaskName.Replace($invalidChar, '_')
        }
        if ([string]::IsNullOrWhiteSpace($safeTaskName)) { $safeTaskName = 'task' }

        $file         = Join-Path $targetFolder ($safeTaskName + '.xml')
        $taskIdentity = "$($task.TaskPath)$($task.TaskName)"

        if (-not $PSCmdlet.ShouldProcess($taskIdentity, "Export nach '$file'")) {
            continue
        }

        try {
            New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null

            Export-ScheduledTask `
                -TaskName $task.TaskName `
                -TaskPath $task.TaskPath |
                Out-File -FilePath $file -Encoding utf8 -ErrorAction Stop

            Write-Host "[OK] Exportiert: $taskIdentity"
        }
        catch {
            Write-Warning "Fehler bei $($task.TaskName): $_"
        }
    }

    Write-Host 'Export abgeschlossen.' -ForegroundColor Green
}
