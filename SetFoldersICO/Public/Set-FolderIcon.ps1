function Set-FolderIcon {
    <#
    .SYNOPSIS
        Wendet ein ICO-Icon auf einen Ordner an via desktop.ini.
    .DESCRIPTION
        Erstellt oder ersetzt die desktop.ini im Zielordner, setzt IconResource,
        und versieht desktop.ini sowie ICO-Datei mit Hidden+System-Attributen.
        Der Ordner selbst erhaelt das System-Attribut, damit Windows das Icon anzeigt.
    .PARAMETER FolderPath
        Pfad zum Zielordner.
    .PARAMETER IconPath
        Pfad zur ICO-Datei (muss bereits existieren).
    .PARAMETER Force
        Ueberschreibt eine vorhandene desktop.ini.
    .EXAMPLE
        Set-FolderIcon -FolderPath 'C:\Dev\Java' -IconPath 'C:\Dev\Java\Java.ico'
    .EXAMPLE
        Set-FolderIcon -FolderPath 'C:\Dev\Python' -IconPath 'C:\Dev\Python\Python.ico' -Force
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$FolderPath,

        [Parameter(Mandatory, Position = 1)]
        [string]$IconPath,

        [switch]$Force
    )

    if (-not (Test-Path $FolderPath -PathType Container)) {
        Write-Warning "Ordner existiert nicht: $FolderPath"
        return $false
    }

    if (-not (Test-Path $IconPath)) {
        Write-Warning "Icon existiert nicht: $IconPath"
        return $false
    }

    $desktopIniPath = Join-Path $FolderPath 'desktop.ini'

    if ((Test-Path $desktopIniPath) -and -not $Force) {
        Write-Verbose "desktop.ini existiert bereits in: $FolderPath"
        return $false
    }

    try {
        if (Test-Path $desktopIniPath) {
            $existingFile = Get-Item $desktopIniPath -Force
            $existingFile.Attributes = 'Normal'
        }

        $iconFileName = Split-Path $IconPath -Leaf
        $iniContent   = @"
[.ShellClassInfo]
IconResource=$iconFileName,0
[ViewState]
Mode=
Vid=
FolderType=Generic
"@
        $iniContent | Out-File -FilePath $desktopIniPath -Encoding Unicode -Force

        $iniFile = Get-Item $desktopIniPath -Force
        $iniFile.Attributes = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System

        $iconFile = Get-Item $IconPath -Force
        $iconFile.Attributes = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System

        $folder = Get-Item $FolderPath -Force
        $folder.Attributes = $folder.Attributes -bor [System.IO.FileAttributes]::System

        return $true
    }
    catch {
        Write-Warning "Fehler beim Setzen des Ordner-Icons: $_"
        return $false
    }
}
