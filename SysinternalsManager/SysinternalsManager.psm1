# ============================================================================
# Modul: SysinternalsManager.psm1
# Beschreibung: Installation, Update und Wartung der Sysinternals Suite
# Version: 1.1.1
# Kompatibilität: Windows 11 25H2, PowerShell 7+
# ============================================================================

#region Private Hilfsfunktionen

function Get-SysinternalsDownloadInfo {
    <#
    .SYNOPSIS
        Ermittelt Metadaten der aktuellen Sysinternals Suite.
    #>
    [CmdletBinding()]
    param(
        [string]$Proxy
    )
    
    $url = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    
    try {
        if ($Proxy) {
            $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -Proxy $Proxy
        }
        else {
            $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing
        }
        
        # PowerShell 7 gibt Headers als Array zurück - ersten Wert nehmen
        $lastModified = $response.Headers["Last-Modified"]
        if ($lastModified -is [array]) { $lastModified = $lastModified[0] }
        
        $contentLength = $response.Headers["Content-Length"]
        if ($contentLength -is [array]) { $contentLength = $contentLength[0] }
        
        return @{
            Url           = $url
            LastModified  = [DateTime]$lastModified
            ContentLength = [int64]$contentLength
        }
    }
    catch {
        throw "Fehler beim Abrufen der Download-Informationen: $_"
    }
}

function Get-LocalVersionInfo {
    <#
    .SYNOPSIS
        Liest lokale Versionsinformationen aus der Marker-Datei.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    $markerFile = Join-Path $Path ".sysinternals-version"
    
    if (Test-Path $markerFile) {
        $content = Get-Content $markerFile | ConvertFrom-Json
        return @{
            InstalledAt  = [DateTime]$content.InstalledAt
            LastModified = [DateTime]$content.LastModified
            ToolCount    = $content.ToolCount
        }
    }
    return $null
}

function Set-LocalVersionInfo {
    <#
    .SYNOPSIS
        Speichert Versionsinformationen in Marker-Datei.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [DateTime]$LastModified,
        
        [Parameter(Mandatory)]
        [int]$ToolCount
    )
    
    $markerFile = Join-Path $Path ".sysinternals-version"
    
    @{
        InstalledAt  = (Get-Date).ToString("o")
        LastModified = $LastModified.ToString("o")
        ToolCount    = $ToolCount
    } | ConvertTo-Json | Set-Content $markerFile -Force
}

function Write-Log {
    <#
    .SYNOPSIS
        Schreibt Log-Einträge für Task Scheduler-Ausführung.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info",
        
        [string]$LogPath
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Konsole (falls interaktiv)
    $color = switch ($Level) {
        "Info"    { "Gray" }
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        "Success" { "Green" }
    }
    
    if ($Host.UI.RawUI.WindowTitle) {
        Write-Host $logEntry -ForegroundColor $color
    }
    
    # Datei (für Task Scheduler)
    if ($LogPath) {
        $logDir = Split-Path $LogPath -Parent
        if (!(Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        $logEntry | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
}

function Install-SysinternalsCore {
    <#
    .SYNOPSIS
        Kernlogik für Installation/Update (intern).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [ValidateSet("User", "Machine")]
        [string]$Scope,
        
        [string]$LogPath,

        [string]$Proxy,

        [string]$CachePath,

        [switch]$UseCache,

        [string]$ExpectedSha256
    )
    
    $registryRoot = switch ($Scope) {
        "User"    { "HKCU:\Software\Sysinternals" }
        "Machine" { "HKLM:\Software\Sysinternals" }
    }
    
    # Download-Info abrufen
    Write-Log "Prüfe Download-Quelle..." -LogPath $LogPath
    $downloadInfo = Get-SysinternalsDownloadInfo -Proxy $Proxy
    
    # Verzeichnis erstellen
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Log "Verzeichnis erstellt: $Path" -LogPath $LogPath
    }
    
    # Download
    $sizeMB = [math]::Round($downloadInfo.ContentLength / 1MB, 1)
    Write-Log "Lade Sysinternals Suite herunter (~$sizeMB MB)..." -LogPath $LogPath
    if ($CachePath) {
        if (!(Test-Path $CachePath)) {
            New-Item -Path $CachePath -ItemType Directory -Force | Out-Null
        }
        $zipPath = Join-Path $CachePath "SysinternalsSuite.zip"
    }
    else {
        $zipPath = Join-Path $env:TEMP "SysinternalsSuite_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    }

    $useCached = $UseCache -and (Test-Path $zipPath)
    if (-not $useCached) {
        if ($Proxy) {
            Invoke-WebRequest -Uri $downloadInfo.Url -OutFile $zipPath -UseBasicParsing -Proxy $Proxy
        }
        else {
            Invoke-WebRequest -Uri $downloadInfo.Url -OutFile $zipPath -UseBasicParsing
        }
    }
    else {
        Write-Log "Nutze Cache: $zipPath" -LogPath $LogPath
    }

    if ($ExpectedSha256) {
        $hash = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash
        if ($hash -ne $ExpectedSha256) {
            throw "SHA256 stimmt nicht ueberein. Erwartet: $ExpectedSha256, Ist: $hash"
        }
        Write-Log "SHA256 validiert: $hash" -LogPath $LogPath
    }
    
    # Entpacken
    Write-Log "Entpacke Archiv..." -LogPath $LogPath
    Expand-Archive -Path $zipPath -DestinationPath $Path -Force
    if (-not $CachePath) {
        Remove-Item $zipPath -Force
    }
    
    # Tool-Anzahl ermitteln
    $tools = Get-ChildItem $Path -Filter "*.exe"
    $toolCount = $tools.Count
    
    # PATH setzen
    $currentPath = [Environment]::GetEnvironmentVariable("Path", $Scope)
    if ($currentPath -notlike "*$Path*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", $Scope)
        Write-Log "PATH aktualisiert ($Scope)" -Level Success -LogPath $LogPath
    }
    else {
        Write-Log "PATH bereits konfiguriert" -LogPath $LogPath
    }
    
    # EULA akzeptieren
    $tools | ForEach-Object {
        $regPath = Join-Path $registryRoot $_.BaseName
        if (!(Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "EulaAccepted" -Value 1 -Type DWord
    }
    Write-Log "EULA für $toolCount Tools akzeptiert" -Level Success -LogPath $LogPath
    
    # Versionsinformation speichern
    Set-LocalVersionInfo -Path $Path -LastModified $downloadInfo.LastModified -ToolCount $toolCount
    
    return @{
        Path         = $Path
        ToolCount    = $toolCount
        LastModified = $downloadInfo.LastModified
    }
}

#endregion

#region Öffentliche Funktionen

function Install-SysinternalsSuite {
    <#
    .SYNOPSIS
        Installiert die Sysinternals Suite lokal.
    
    .DESCRIPTION
        Lädt die aktuelle Sysinternals Suite herunter, entpackt sie,
        konfiguriert PATH und akzeptiert die EULA für alle Tools.
    
    .PARAMETER Path
        Installationspfad. Standard je nach Scope:
        - User: C:\Tools\SysInternals
        - Machine: C:\Program Files\SysInternals
    
    .PARAMETER Scope
        'User' = nur aktueller Benutzer (Standard, kein Admin erforderlich)
        'Machine' = systemweit für alle Benutzer (Admin erforderlich)
    
    .PARAMETER Force
        Überschreibt vorhandene Installation ohne Rückfrage.
    
    .PARAMETER LogPath
        Pfad zur Log-Datei (optional, für Task Scheduler).
    
    .EXAMPLE
        Install-SysinternalsSuite
        # Installiert für aktuellen User nach C:\Tools\SysInternals
    
    .EXAMPLE
        Install-SysinternalsSuite -Scope Machine
        # Systemweite Installation nach C:\Program Files\SysInternals
    
    .EXAMPLE
        Install-SysinternalsSuite -Path "D:\DevTools\SysInternals" -Scope User
        # Benutzerdefinierter Pfad
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$Path,
        
        [Parameter()]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User",
        
        [Parameter()]
        [switch]$Force,
        
        [Parameter()]
        [string]$LogPath,

        [Parameter()]
        [string]$Proxy,

        [Parameter()]
        [string]$CachePath,

        [Parameter()]
        [switch]$UseCache,

        [Parameter()]
        [string]$ExpectedSha256
    )
    
    # Standardpfad
    if (-not $Path) {
        $Path = switch ($Scope) {
            "User"    { "C:\Tools\SysInternals" }
            "Machine" { "C:\Program Files\SysInternals" }
        }
    }
    
    # Admin-Check
    if ($Scope -eq "Machine") {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                   ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            throw "Machine-Scope erfordert Administrator-Rechte. Bitte Terminal als Admin starten."
        }
    }
    
    # Prüfen ob bereits installiert
    $existingVersion = Get-LocalVersionInfo -Path $Path
    if ($existingVersion -and -not $Force) {
        Write-Log "Sysinternals bereits installiert ($(Get-Date $existingVersion.InstalledAt -Format 'dd.MM.yyyy'))" -Level Warning -LogPath $LogPath
        Write-Log "Verwende -Force zum Überschreiben oder Update-SysinternalsSuite für Updates." -Level Warning -LogPath $LogPath
        return
    }
    
    Write-Log "══════════════════════════════════════════════════════════" -LogPath $LogPath
    Write-Log " SYSINTERNALS SUITE - INSTALLATION" -LogPath $LogPath
    Write-Log " Pfad:  $Path" -LogPath $LogPath
    Write-Log " Scope: $Scope" -LogPath $LogPath
    Write-Log "══════════════════════════════════════════════════════════" -LogPath $LogPath
    
    if ($PSCmdlet.ShouldProcess($Path, "Sysinternals Suite installieren")) {
        $result = Install-SysinternalsCore -Path $Path -Scope $Scope -LogPath $LogPath -Proxy $Proxy -CachePath $CachePath -UseCache:$UseCache -ExpectedSha256 $ExpectedSha256
        
        Write-Log "══════════════════════════════════════════════════════════" -Level Success -LogPath $LogPath
        Write-Log " ✓ Installation abgeschlossen!" -Level Success -LogPath $LogPath
        Write-Log "   $($result.ToolCount) Tools installiert" -Level Success -LogPath $LogPath
        Write-Log "   Stand: $(Get-Date $result.LastModified -Format 'dd.MM.yyyy HH:mm')" -Level Success -LogPath $LogPath
        Write-Log "══════════════════════════════════════════════════════════" -Level Success -LogPath $LogPath
        Write-Log " Hinweis: Terminal neu starten für PATH-Änderungen!" -Level Warning -LogPath $LogPath
        
        return $result
    }
}

function Update-SysinternalsSuite {
    <#
    .SYNOPSIS
        Aktualisiert die Sysinternals Suite falls eine neue Version verfügbar ist.
    
    .DESCRIPTION
        Prüft anhand des Last-Modified-Headers ob eine neue Version verfügbar ist
        und führt bei Bedarf ein Update durch. Ideal für Task Scheduler.
    
    .PARAMETER Path
        Installationspfad. Standard je nach Scope.
    
    .PARAMETER Scope
        'User' = nur aktueller Benutzer (Standard)
        'Machine' = systemweit (Admin erforderlich)
    
    .PARAMETER Force
        Update erzwingen, auch wenn keine neue Version erkannt wurde.
    
    .PARAMETER LogPath
        Pfad zur Log-Datei (empfohlen für Task Scheduler).
    
    .EXAMPLE
        Update-SysinternalsSuite
        # Prüft und aktualisiert bei Bedarf
    
    .EXAMPLE
        Update-SysinternalsSuite -Force
        # Erzwingt Update unabhängig von Version
    
    .EXAMPLE
        Update-SysinternalsSuite -LogPath "C:\Logs\sysinternals-update.log"
        # Mit Logging für Task Scheduler
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$Path,
        
        [Parameter()]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User",
        
        [Parameter()]
        [switch]$Force,
        
        [Parameter()]
        [string]$LogPath,

        [Parameter()]
        [string]$Proxy,

        [Parameter()]
        [string]$CachePath,

        [Parameter()]
        [switch]$UseCache,

        [Parameter()]
        [string]$ExpectedSha256
    )
    
    # Standardpfad
    if (-not $Path) {
        $Path = switch ($Scope) {
            "User"    { "C:\Tools\SysInternals" }
            "Machine" { "C:\Program Files\SysInternals" }
        }
    }
    
    Write-Log "══════════════════════════════════════════════════════════" -LogPath $LogPath
    Write-Log " SYSINTERNALS SUITE - UPDATE CHECK" -LogPath $LogPath
    Write-Log " Pfad:  $Path" -LogPath $LogPath
    Write-Log " Scope: $Scope" -LogPath $LogPath
    Write-Log "══════════════════════════════════════════════════════════" -LogPath $LogPath
    
    # Lokale Version prüfen
    $localVersion = Get-LocalVersionInfo -Path $Path
    if (-not $localVersion) {
        Write-Log "Keine Installation gefunden. Führe Install-SysinternalsSuite aus." -Level Warning -LogPath $LogPath
        return
    }
    
    Write-Log "Lokale Version:  $(Get-Date $localVersion.LastModified -Format 'dd.MM.yyyy HH:mm')" -LogPath $LogPath
    
    # Remote-Version prüfen
    try {
    $remoteInfo = Get-SysinternalsDownloadInfo -Proxy $Proxy
        Write-Log "Remote Version:  $(Get-Date $remoteInfo.LastModified -Format 'dd.MM.yyyy HH:mm')" -LogPath $LogPath
    }
    catch {
        Write-Log "Fehler beim Prüfen der Remote-Version: $_" -Level Error -LogPath $LogPath
        return
    }
    
    # Vergleich
    $updateAvailable = $remoteInfo.LastModified -gt $localVersion.LastModified
    
    if ($updateAvailable -or $Force) {
        if ($Force -and -not $updateAvailable) {
            Write-Log "Update erzwungen (keine neue Version erkannt)" -Level Warning -LogPath $LogPath
        }
        else {
            Write-Log "Neue Version verfügbar!" -Level Success -LogPath $LogPath
        }
        
        # Admin-Check für Machine-Scope
        if ($Scope -eq "Machine") {
            $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                       ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            if (-not $isAdmin) {
                Write-Log "Machine-Scope erfordert Administrator-Rechte." -Level Error -LogPath $LogPath
                throw "Machine-Scope erfordert Administrator-Rechte."
            }
        }
        
        if ($PSCmdlet.ShouldProcess($Path, "Sysinternals Suite aktualisieren")) {
            $result = Install-SysinternalsCore -Path $Path -Scope $Scope -LogPath $LogPath -Proxy $Proxy -CachePath $CachePath -UseCache:$UseCache -ExpectedSha256 $ExpectedSha256
            
            Write-Log "══════════════════════════════════════════════════════════" -Level Success -LogPath $LogPath
            Write-Log " ✓ Update abgeschlossen!" -Level Success -LogPath $LogPath
            Write-Log "   $($result.ToolCount) Tools aktualisiert" -Level Success -LogPath $LogPath
            Write-Log "   Neuer Stand: $(Get-Date $result.LastModified -Format 'dd.MM.yyyy HH:mm')" -Level Success -LogPath $LogPath
            Write-Log "══════════════════════════════════════════════════════════" -Level Success -LogPath $LogPath
            
            return $result
        }
    }
    else {
        Write-Log "══════════════════════════════════════════════════════════" -Level Success -LogPath $LogPath
        Write-Log " ✓ Bereits auf dem neuesten Stand" -Level Success -LogPath $LogPath
        Write-Log "══════════════════════════════════════════════════════════" -Level Success -LogPath $LogPath
    }
}

function Register-SysinternalsUpdateTask {
    <#
    .SYNOPSIS
        Registriert einen Task Scheduler-Job für automatische Updates.
    
    .DESCRIPTION
        Erstellt einen geplanten Task der regelmäßig auf Updates prüft.
        Optimiert für Windows 11 25H2.
    
    .PARAMETER Path
        Installationspfad der Sysinternals Suite.
    
    .PARAMETER Scope
        'User' oder 'Machine'
    
    .PARAMETER TaskPath
        Ordnerpfad in der Aufgabenplanung. Standard: \Eigene\System\
        Der Ordner wird automatisch erstellt falls nicht vorhanden.
    
    .PARAMETER Schedule
        'Daily', 'Weekly' (Standard), 'Monthly'
    
    .PARAMETER Time
        Ausführungszeit im Format HH:mm. Standard: 03:00
    
    .PARAMETER DayOfWeek
        Wochentag für Weekly-Schedule. Standard: Sunday
    
    .PARAMETER LogPath
        Pfad für Log-Dateien.
        Standard: %LOCALAPPDATA%\SysinternalsManager\update.log
    
    .EXAMPLE
        Register-SysinternalsUpdateTask
        # Wöchentlich Sonntag 03:00 Uhr in \Eigene\System\
    
    .EXAMPLE
        Register-SysinternalsUpdateTask -TaskPath "\Wartung\Updates\"
        # In benutzerdefiniertem Ordner
    
    .EXAMPLE
        Register-SysinternalsUpdateTask -Schedule Daily -Time "05:00"
        # Täglich um 05:00 Uhr
    
    .EXAMPLE
        Register-SysinternalsUpdateTask -Schedule Weekly -DayOfWeek Monday -Time "06:30"
        # Wöchentlich Montag 06:30 Uhr
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [string]$Path,
        
        [Parameter()]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User",
        
        [Parameter()]
        [string]$TaskPath = "\Eigene\System\",
        
        [Parameter()]
        [ValidateSet("Daily", "Weekly", "Monthly")]
        [string]$Schedule = "Weekly",
        
        [Parameter()]
        [ValidatePattern("^\d{2}:\d{2}$")]
        [string]$Time = "03:00",
        
        [Parameter()]
        [ValidateSet("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")]
        [string]$DayOfWeek = "Sunday",
        
        [Parameter()]
        [string]$LogPath
        ,
        [Parameter()]
        [string]$Proxy,

        [Parameter()]
        [string]$CachePath,

        [Parameter()]
        [switch]$UseCache,

        [Parameter()]
        [string]$ExpectedSha256
    )
    
    # TaskPath normalisieren (muss mit \ beginnen und enden)
    if (-not $TaskPath.StartsWith("\")) { $TaskPath = "\$TaskPath" }
    if (-not $TaskPath.EndsWith("\")) { $TaskPath = "$TaskPath\" }
    
    # Standardpfade
    if (-not $Path) {
        $Path = switch ($Scope) {
            "User"    { "C:\Tools\SysInternals" }
            "Machine" { "C:\Program Files\SysInternals" }
        }
    }
    
    if (-not $LogPath) {
        $logDir = Join-Path $env:LOCALAPPDATA "SysinternalsManager"
        if (!(Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        $LogPath = Join-Path $logDir "update.log"
    }
    
    # Admin-Check für Machine-Scope
    if ($Scope -eq "Machine") {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                   ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            throw "Machine-Scope erfordert Administrator-Rechte. Bitte Terminal als Admin starten."
        }
    }
    
    $taskName = "SysinternalsUpdate_$Scope"
    
    # Modul-Pfad ermitteln (für den Task)
    $modulePath = $PSScriptRoot
    if (-not $modulePath) {
        $modulePath = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    
    # PowerShell-Befehl für den Task
    $command = @"
`$ErrorActionPreference = 'Stop'
try {
    Import-Module '$modulePath\SysinternalsManager.psm1' -Force
    Update-SysinternalsSuite -Path '$Path' -Scope $Scope -LogPath '$LogPath'$(if ($Proxy) { " -Proxy '$Proxy'" } else { "" })$(if ($CachePath) { " -CachePath '$CachePath'" } else { "" })$(if ($UseCache) { " -UseCache" } else { "" })$(if ($ExpectedSha256) { " -ExpectedSha256 '$ExpectedSha256'" } else { "" })
}
catch {
    `$_ | Out-File -FilePath '$LogPath' -Append
    exit 1
}
"@
    
    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    
    # Task-Action
    $action = New-ScheduledTaskAction `
        -Execute "pwsh.exe" `
        -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $encodedCommand"
    
    # Trigger je nach Schedule
    $trigger = switch ($Schedule) {
        "Daily" {
            New-ScheduledTaskTrigger -Daily -At $Time
        }
        "Weekly" {
            New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DayOfWeek -At $Time
        }
        "Monthly" {
            New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek $DayOfWeek -At $Time
        }
    }
    
    # Principal (Ausführungskontext)
    $principal = switch ($Scope) {
        "User" {
            New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Limited
        }
        "Machine" {
            New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        }
    }
    
    # Task-Einstellungen (Windows 11 25H2 optimiert)
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 30) `
        -MultipleInstances IgnoreNew
    
    if ($PSCmdlet.ShouldProcess("$TaskPath$taskName", "Scheduled Task registrieren")) {
        # Existierenden Task entfernen (in allen möglichen Pfaden)
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            Write-Host "Bestehender Task entfernt" -ForegroundColor Yellow
        }
        
        # Neuen Task registrieren (Ordner wird automatisch erstellt)
        Register-ScheduledTask `
            -TaskName $taskName `
            -TaskPath $TaskPath `
            -Action $action `
            -Trigger $trigger `
            -Principal $principal `
            -Settings $settings `
            -Description "Automatisches Update der Sysinternals Suite ($Scope-Level). Erstellt mit SysinternalsManager." `
            -Force | Out-Null
        
        # Schedule-Beschreibung
        $scheduleDesc = switch ($Schedule) {
            "Daily"   { "Täglich um $Time" }
            "Weekly"  { "Wöchentlich $DayOfWeek um $Time" }
            "Monthly" { "Monatlich (alle 4 Wochen) $DayOfWeek um $Time" }
        }
        
        Write-Host ""
        Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host " ✓ Scheduled Task registriert" -ForegroundColor Green
        Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "   Name:      $taskName" -ForegroundColor Gray
        Write-Host "   Ordner:    $TaskPath" -ForegroundColor Gray
        Write-Host "   Schedule:  $scheduleDesc" -ForegroundColor Gray
        Write-Host "   Scope:     $Scope" -ForegroundColor Gray
        Write-Host "   Log:       $LogPath" -ForegroundColor Gray
        Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host " Nützliche Befehle:" -ForegroundColor Cyan
        Write-Host "   Get-ScheduledTask -TaskPath '$TaskPath' -TaskName '$taskName' | fl *" -ForegroundColor Gray
        Write-Host "   Start-ScheduledTask -TaskPath '$TaskPath' -TaskName '$taskName'" -ForegroundColor Gray
        Write-Host ""
        
        return Get-ScheduledTask -TaskPath $TaskPath -TaskName $taskName
    }
}

function Unregister-SysinternalsUpdateTask {
    <#
    .SYNOPSIS
        Entfernt den Scheduled Task für Sysinternals-Updates.
    
    .PARAMETER Scope
        'User' oder 'Machine' - bestimmt welcher Task entfernt wird.
    
    .PARAMETER TaskPath
        Ordnerpfad in der Aufgabenplanung. Standard: \Eigene\System\
    
    .EXAMPLE
        Unregister-SysinternalsUpdateTask
        # Entfernt User-Task aus \Eigene\System\
    
    .EXAMPLE
        Unregister-SysinternalsUpdateTask -Scope Machine -TaskPath "\Wartung\"
        # Entfernt Machine-Task aus benutzerdefiniertem Ordner
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter()]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User",
        
        [Parameter()]
        [string]$TaskPath = "\Eigene\System\"
    )
    
    # TaskPath normalisieren
    if (-not $TaskPath.StartsWith("\")) { $TaskPath = "\$TaskPath" }
    if (-not $TaskPath.EndsWith("\")) { $TaskPath = "$TaskPath\" }
    
    $taskName = "SysinternalsUpdate_$Scope"
    
    if ($PSCmdlet.ShouldProcess("$TaskPath$taskName", "Scheduled Task entfernen")) {
        $existingTask = Get-ScheduledTask -TaskPath $TaskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskPath $TaskPath -TaskName $taskName -Confirm:$false
            Write-Host "✓ Task '$TaskPath$taskName' erfolgreich entfernt" -ForegroundColor Green
        }
        else {
            Write-Host "Task '$TaskPath$taskName' nicht gefunden" -ForegroundColor Yellow
        }
    }
}

function Get-SysinternalsStatus {
    <#
    .SYNOPSIS
        Zeigt den aktuellen Status der Sysinternals-Installation.
    
    .PARAMETER Path
        Installationspfad. Standard je nach Scope.
    
    .PARAMETER Scope
        'User' oder 'Machine'
    
    .PARAMETER TaskPath
        Ordnerpfad in der Aufgabenplanung. Standard: \Eigene\System\
    
    .EXAMPLE
        Get-SysinternalsStatus
    #>
    
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Path,
        
        [Parameter()]
        [ValidateSet("User", "Machine")]
        [string]$Scope = "User",
        
        [Parameter()]
        [string]$TaskPath = "\Eigene\System\",

        [Parameter()]
        [string]$Proxy
    )
    
    # TaskPath normalisieren
    if (-not $TaskPath.StartsWith("\")) { $TaskPath = "\$TaskPath" }
    if (-not $TaskPath.EndsWith("\")) { $TaskPath = "$TaskPath\" }
    
    # Standardpfad
    if (-not $Path) {
        $Path = switch ($Scope) {
            "User"    { "C:\Tools\SysInternals" }
            "Machine" { "C:\Program Files\SysInternals" }
        }
    }
    
    $taskName = "SysinternalsUpdate_$Scope"
    
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " SYSINTERNALS SUITE - STATUS" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    # Installation prüfen
    $localVersion = Get-LocalVersionInfo -Path $Path
    if ($localVersion) {
        Write-Host ""
        Write-Host " Installation:" -ForegroundColor White
        Write-Host "   Pfad:         $Path" -ForegroundColor Gray
        Write-Host "   Installiert:  $(Get-Date $localVersion.InstalledAt -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        Write-Host "   Suite-Stand:  $(Get-Date $localVersion.LastModified -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        Write-Host "   Tools:        $($localVersion.ToolCount)" -ForegroundColor Gray
        
        # Auf Updates prüfen
        try {
            $remoteInfo = Get-SysinternalsDownloadInfo -Proxy $Proxy
            $updateAvailable = $remoteInfo.LastModified -gt $localVersion.LastModified
            
            Write-Host ""
            Write-Host " Update-Status:" -ForegroundColor White
            Write-Host "   Remote-Stand: $(Get-Date $remoteInfo.LastModified -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
            
            if ($updateAvailable) {
                Write-Host "   Status:       UPDATE VERFÜGBAR" -ForegroundColor Yellow
            }
            else {
                Write-Host "   Status:       Aktuell" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "   Status:       Konnte nicht geprüft werden" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host ""
        Write-Host " Installation:   NICHT INSTALLIERT" -ForegroundColor Yellow
        Write-Host "   Erwarteter Pfad: $Path" -ForegroundColor Gray
    }
    
    # Task-Status
    $task = Get-ScheduledTask -TaskPath $TaskPath -TaskName $taskName -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host " Scheduled Task:" -ForegroundColor White
    if ($task) {
        $taskInfo = Get-ScheduledTaskInfo -TaskPath $TaskPath -TaskName $taskName
        Write-Host "   Name:         $taskName" -ForegroundColor Gray
        Write-Host "   Ordner:       $TaskPath" -ForegroundColor Gray
        Write-Host "   Status:       $($task.State)" -ForegroundColor Gray
        if ($taskInfo.LastRunTime -and $taskInfo.LastRunTime -ne [DateTime]::MinValue) {
            Write-Host "   Letzte Ausf.: $(Get-Date $taskInfo.LastRunTime -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        }
        if ($taskInfo.NextRunTime) {
            Write-Host "   Nächste Ausf.: $(Get-Date $taskInfo.NextRunTime -Format 'dd.MM.yyyy HH:mm')" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "   Status:       Nicht konfiguriert" -ForegroundColor Yellow
        Write-Host "   Erwarteter Ordner: $TaskPath" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

#endregion

# Modul-Export
Export-ModuleMember -Function @(
    'Install-SysinternalsSuite',
    'Update-SysinternalsSuite',
    'Register-SysinternalsUpdateTask',
    'Unregister-SysinternalsUpdateTask',
    'Get-SysinternalsStatus'
)
