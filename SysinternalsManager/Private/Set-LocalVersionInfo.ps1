function Set-LocalVersionInfo {
    <#
    .SYNOPSIS
        Speichert Versionsinformationen der Sysinternals-Installation in einer Marker-Datei.
    .DESCRIPTION
        Schreibt InstalledAt (aktueller Zeitstempel), LastModified und ToolCount
        als JSON in die Datei '.sysinternals-version' im Installationsverzeichnis.
    .PARAMETER Path
        Installationspfad der Sysinternals Suite.
    .PARAMETER LastModified
        Zeitstempel der Remote-Version (aus HTTP Last-Modified Header).
    .PARAMETER ToolCount
        Anzahl der installierten EXE-Dateien.
    .EXAMPLE
        Set-LocalVersionInfo -Path 'C:\Tools\SysInternals' -LastModified $remoteDate -ToolCount 75
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [DateTime]$LastModified,

        [Parameter(Mandatory)]
        [int]$ToolCount
    )

    $markerFile = Join-Path $Path '.sysinternals-version'

    @{
        InstalledAt  = (Get-Date).ToString('o')
        LastModified = $LastModified.ToString('o')
        ToolCount    = $ToolCount
    } | ConvertTo-Json | Set-Content $markerFile -Force
}
