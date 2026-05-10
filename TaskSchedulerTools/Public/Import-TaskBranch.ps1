function Import-TaskBranch {
    <#
    .SYNOPSIS
        Importiert exportierte Tasks aus XML-Dateien in den Task Scheduler.
    .DESCRIPTION
        Liest alle XML-Dateien rekursiv aus SourcePath ein und registriert jeden
        Task unter dem entsprechenden Unterordner in TaskPath. Die Verzeichnisstruktur
        aus dem Backup wird dabei im Task-Scheduler nachgebildet.
        Fehlende Task-Scheduler-Ordner werden automatisch erstellt.
        Unterstuetzt ShouldProcess (-WhatIf/-Confirm).
    .PARAMETER SourcePath
        Quellverzeichnis mit den exportierten XML-Dateien (Standard: 'C:\TaskBackup').
    .PARAMETER TaskPath
        Zielpfad im Task Scheduler (Standard: '\Eigene\').
    .PARAMETER Credential
        Optionales PSCredential-Objekt. Ohne Angabe wird der aktuelle Benutzer
        mit leerem Passwort verwendet (fuer S4U-Tasks geeignet).
    .EXAMPLE
        Import-TaskBranch
    .EXAMPLE
        Import-TaskBranch -SourcePath 'D:\Backup\Tasks' -TaskPath '\Eigene\System\'
    .EXAMPLE
        $cred = Get-Credential
        Import-TaskBranch -Credential $cred
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [string]$SourcePath = 'C:\TaskBackup',
        [string]$TaskPath   = '\Eigene\',
        [System.Management.Automation.PSCredential]$Credential
    )

    $TaskPath = Format-TaskPath -Path $TaskPath -EnsureTrailing

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
        throw "SourcePath '$SourcePath' existiert nicht oder ist kein Verzeichnis."
    }

    if (-not $Credential) {
        $Credential = Get-CurrentUserCredential
        Write-Host "Nutze Current User: $($Credential.UserName)" -ForegroundColor Yellow
    }

    $sourceRoot = (Resolve-Path -LiteralPath $SourcePath).Path.TrimEnd('\')
    $files      = @(Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Filter '*.xml')

    if ($files.Count -eq 0) {
        Write-Warning "Keine XML-Dateien unter '$sourceRoot' gefunden."
        Write-Host 'Import abgeschlossen.' -ForegroundColor Green
        return
    }

    foreach ($file in $files) {
        if (-not $file -or -not $file.Directory -or [string]::IsNullOrWhiteSpace($file.FullName)) { continue }

        $directoryFullName = $file.Directory.FullName.TrimEnd('\')
        $relative          = ''

        if ($directoryFullName.StartsWith($sourceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relative = $directoryFullName.Substring($sourceRoot.Length).TrimStart('\')
        }

        $targetPath = if ([string]::IsNullOrWhiteSpace($relative)) {
            $TaskPath
        } else {
            (($TaskPath.TrimEnd('\')) + '\' + $relative + '\') -replace '\\{2,}', '\'
        }

        $name         = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $taskIdentity = "$targetPath$name"

        if (-not $PSCmdlet.ShouldProcess($taskIdentity, "Task aus '$($file.FullName)' registrieren")) {
            continue
        }

        try {
            New-TaskFolder $targetPath
        }
        catch {
            Write-Warning "Fehler beim Erstellen des Ordners '$targetPath': $_"
            continue
        }

        try {
            $xml = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
        }
        catch {
            Write-Warning "Fehler beim Lesen von '$($file.FullName)': $_"
            continue
        }

        try {
            Register-ScheduledTask `
                -TaskName $name `
                -TaskPath $targetPath `
                -Xml      $xml `
                -User     $Credential.UserName `
                -Password ($Credential.GetNetworkCredential().Password) `
                -ErrorAction Stop

            Write-Host "[OK] Importiert: $taskIdentity"
        }
        catch {
            Write-Warning "Fehler bei Import $name : $_"
        }
    }

    Write-Host 'Import abgeschlossen.' -ForegroundColor Green
}
