function Remove-FolderIcon {
    <#
    .SYNOPSIS
        Entfernt ein benutzerdefiniertes Icon von einem Ordner.
    .DESCRIPTION
        Loescht die desktop.ini und setzt das System-Attribut des Ordners zurueck.
        Mit -RemoveIconFile wird auch die versteckte ICO-Datei geloescht.
    .PARAMETER FolderPath
        Pfad zum Ordner, dessen Icon entfernt werden soll.
    .PARAMETER RemoveIconFile
        Loescht zusaetzlich die ICO-Datei im Ordner (gleicher Name wie Ordner).
    .EXAMPLE
        Remove-FolderIcon -FolderPath 'C:\Dev\Java'
    .EXAMPLE
        Remove-FolderIcon -FolderPath 'C:\Dev\Java' -RemoveIconFile
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$FolderPath,

        [switch]$RemoveIconFile
    )

    $desktopIniPath = Join-Path $FolderPath 'desktop.ini'

    try {
        if (Test-Path $desktopIniPath) {
            $file = Get-Item $desktopIniPath -Force
            $file.Attributes = 'Normal'
            Remove-Item $desktopIniPath -Force
        }

        if ($RemoveIconFile) {
            $folderName = Split-Path $FolderPath -Leaf
            $icoPath    = Join-Path $FolderPath "$folderName.ico"
            if (Test-Path $icoPath) {
                $icoFile = Get-Item $icoPath -Force
                $icoFile.Attributes = 'Normal'
                Remove-Item $icoPath -Force
            }
        }

        $folder = Get-Item $FolderPath -Force
        $folder.Attributes = $folder.Attributes -band (-bnot [System.IO.FileAttributes]::System)

        return $true
    }
    catch {
        Write-Warning "Fehler beim Entfernen des Ordner-Icons: $_"
        return $false
    }
}
