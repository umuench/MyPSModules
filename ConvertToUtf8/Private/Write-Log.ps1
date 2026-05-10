function Write-Log {
    <#
    .SYNOPSIS
        Schreibt eine zeitgestempelte Meldung nach Verbose und optional in eine Logdatei.
    .PARAMETER Message
        Die zu protokollierende Nachricht.
    .PARAMETER LogPath
        Optionaler Pfad zur Logdatei. Ohne Angabe erfolgt nur Verbose-Ausgabe.
    .EXAMPLE
        Write-Log -Message "Verarbeitung gestartet." -LogPath "C:\Logs\convert.log"
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [string]$LogPath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $Message"
    Write-Verbose $entry

    if ($LogPath) {
        Add-Content -Path $LogPath -Value $entry
    }
}