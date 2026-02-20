# ============================================
# Module: TaskSchedulerTools
# ============================================

#region Helper: Current User Credential
function Get-CurrentUserCredential {

    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    # Empty secure strings must be created without -AsPlainText in newer PowerShell versions.
    $emptyPassword = New-Object System.Security.SecureString

    return New-Object System.Management.Automation.PSCredential(
        $user,
        $emptyPassword
    )
}
#endregion

#region Helper: Normalize Task Path
function Normalize-TaskPath {

    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$EnsureTrailing
    )

    $normalized = ($Path -replace "/", "\").Trim()
    $normalized = $normalized -replace "\\+", "\"

    if ([string]::IsNullOrWhiteSpace($normalized) -or $normalized -eq "\") {
        return "\"
    }

    if (-not $normalized.StartsWith("\")) {
        $normalized = "\" + $normalized
    }

    $normalized = $normalized.TrimEnd("\")

    if ($EnsureTrailing) {
        return $normalized + "\"
    }

    return $normalized
}
#endregion

#region Helper: Create Task Folder (recursive)
function New-TaskFolder {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $service = New-Object -ComObject "Schedule.Service"
    $service.Connect()

    $normalizedPath = Normalize-TaskPath -Path $Path
    if ($normalizedPath -eq "\") { return }

    $parts = $normalizedPath.Trim("\").Split("\")
    $current = ""

    foreach ($part in $parts) {

        if (-not $part) { continue }
        if ([string]::IsNullOrWhiteSpace($current)) {
            $current = "\" + $part
        }
        else {
            $current = $current + "\" + $part
        }

        try {
            $service.GetFolder($current) | Out-Null
        }
        catch {
            $parent = Split-Path $current -Parent
            if ([string]::IsNullOrWhiteSpace($parent)) {
                $parent = "\"
            }
            $folder = Split-Path $current -Leaf
            $service.GetFolder($parent).CreateFolder($folder) | Out-Null
        }
    }
}
#endregion

#region Helper: Recursive Task Enumeration
function Get-TaskFolderTasks {

    param(
        [string]$TaskPath = "\"
    )

    $normalizedTaskPath = Normalize-TaskPath -Path $TaskPath -EnsureTrailing

    try {
        $allTasks = @(Get-ScheduledTask -ErrorAction Stop)
    }
    catch {
        Write-Warning "Tasks konnten nicht gelesen werden: $($_.Exception.Message)"
        return
    }

    foreach ($task in $allTasks) {

        if (-not $task -or -not $task.TaskPath -or -not $task.TaskName) { continue }

        if ($normalizedTaskPath -eq "\" -or $task.TaskPath.StartsWith($normalizedTaskPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            [PSCustomObject]@{
                TaskName = $task.TaskName
                TaskPath = $task.TaskPath
            }
        }
    }
}
#endregion

# ============================================
# EXPORT
# ============================================
function Export-TaskBranch {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param(
        [string]$TaskPath   = "\Eigene\",
        [string]$BackupPath = "C:\TaskBackup",
        [string[]]$NameFilter
    )

    $TaskPath = Normalize-TaskPath -Path $TaskPath -EnsureTrailing

    Write-Host "Exportiere Tasks aus $TaskPath ..." -ForegroundColor Cyan

    if ($PSCmdlet.ShouldProcess($BackupPath, "Backup-Ordner erstellen/aktualisieren")) {
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
        Write-Host "Export abgeschlossen." -ForegroundColor Green
        return
    }

    foreach ($task in $tasks) {

        if (-not $task -or -not $task.TaskPath -or -not $task.TaskName) { continue }

        if ($task.TaskPath.StartsWith($TaskPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $task.TaskPath.Substring($TaskPath.Length)
        }
        else {
            $relativePath = $task.TaskPath.Trim("\")
        }

        if ([string]::IsNullOrWhiteSpace($relativePath)) {
            $targetFolder = $BackupPath
        }
        else {
            $targetFolder = Join-Path $BackupPath $relativePath
        }

        $safeTaskName = $task.TaskName
        foreach ($invalidChar in [System.IO.Path]::GetInvalidFileNameChars()) {
            $safeTaskName = $safeTaskName.Replace($invalidChar, "_")
        }
        if ([string]::IsNullOrWhiteSpace($safeTaskName)) {
            $safeTaskName = "task"
        }

        $file = Join-Path $targetFolder ($safeTaskName + ".xml")
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

            Write-Host "✔ Exportiert:" $taskIdentity
        }
        catch {
            Write-Warning "Fehler bei $($task.TaskName): $_"
        }
    }

    Write-Host "Export abgeschlossen." -ForegroundColor Green
}

# ============================================
# IMPORT
# ============================================
function Import-TaskBranch {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [string]$SourcePath = "C:\TaskBackup",
        [string]$TaskPath   = "\Eigene\",
        [System.Management.Automation.PSCredential]$Credential
    )

    $TaskPath = Normalize-TaskPath -Path $TaskPath -EnsureTrailing

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
        throw "SourcePath '$SourcePath' existiert nicht oder ist kein Verzeichnis."
    }

    if (-not $Credential) {

        $Credential = Get-CurrentUserCredential
        Write-Host "Nutze Current User:" $Credential.UserName -ForegroundColor Yellow
    }

    $sourceRoot = (Resolve-Path -LiteralPath $SourcePath).Path.TrimEnd("\")
    $files = @(Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Filter *.xml)

    if ($files.Count -eq 0) {
        Write-Warning "Keine XML-Dateien unter '$sourceRoot' gefunden."
        Write-Host "Import abgeschlossen." -ForegroundColor Green
        return
    }

    foreach ($file in $files) {

        if (-not $file -or -not $file.Directory -or [string]::IsNullOrWhiteSpace($file.FullName)) { continue }

        $directoryFullName = $file.Directory.FullName.TrimEnd("\")
        $relative = ""
        if ($directoryFullName.StartsWith($sourceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relative = $directoryFullName.Substring($sourceRoot.Length).TrimStart("\")
        }

        $targetPath = if ([string]::IsNullOrWhiteSpace($relative)) {
            $TaskPath
        }
        else {
            (($TaskPath.TrimEnd("\")) + "\" + $relative + "\").Replace("\\", "\")
        }

        $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
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
                -Xml $xml `
                -User $Credential.UserName `
                -Password ($Credential.GetNetworkCredential().Password) `
                -ErrorAction Stop

            Write-Host "✔ Importiert:" $taskIdentity
        }
        catch {
            Write-Warning "Fehler bei Import $name : $_"
        }
    }

    Write-Host "Import abgeschlossen." -ForegroundColor Green
}

# ============================================
# EXPORT MEMBERS
# ============================================
Export-ModuleMember -Function `
    Export-TaskBranch,
    Import-TaskBranch


