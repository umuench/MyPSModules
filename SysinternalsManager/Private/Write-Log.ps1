function Write-Log {
    <#
    .SYNOPSIS
        Schreibt Log-Eintraege fuer interaktive und Task-Scheduler-Ausfuehrungen.
    .DESCRIPTION
        Gibt den Log-Eintrag mit Zeitstempel und Level auf der Konsole aus (falls interaktiv)
        und haengt ihn an eine optionale Log-Datei an (noetig fuer Task-Scheduler-Ausfuehrungen).
    .PARAMETER Message
        Die zu protokollierende Nachricht.
    .PARAMETER Level
        Protokollierungsebene: Info (Standard), Warning, Error oder Success.
    .PARAMETER LogPath
        Optionaler Pfad zur Log-Datei. Das Verzeichnis wird automatisch erstellt.
    .EXAMPLE
        Write-Log 'Download gestartet' -Level Info -LogPath 'C:\Logs\update.log'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info',

        [string]$LogPath
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry  = "[$timestamp] [$Level] $Message"

    $color = switch ($Level) {
        'Info'    { 'Gray' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Success' { 'Green' }
    }

    try {
        if ($Host.UI.RawUI -and $Host.UI.RawUI.WindowTitle) {
            Write-Host $logEntry -ForegroundColor $color
        }
    }
    catch { }

    if ($LogPath) {
        $logDir = Split-Path $LogPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        $logEntry | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
}
