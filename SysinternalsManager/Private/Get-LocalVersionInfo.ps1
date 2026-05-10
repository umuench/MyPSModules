function Get-LocalVersionInfo {
    <#
    .SYNOPSIS
        Liest lokale Versionsinformationen aus der Marker-Datei einer Sysinternals-Installation.
    .DESCRIPTION
        Sucht im angegebenen Verzeichnis nach der Datei '.sysinternals-version' und
        gibt deren Inhalt als Hashtable zurueck. Gibt $null zurueck, wenn keine Datei gefunden wird.
    .PARAMETER Path
        Installationspfad der Sysinternals Suite.
    .EXAMPLE
        $ver = Get-LocalVersionInfo -Path 'C:\Tools\SysInternals'
        if ($ver) { Write-Host $ver.ToolCount }
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $markerFile = Join-Path $Path '.sysinternals-version'

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
