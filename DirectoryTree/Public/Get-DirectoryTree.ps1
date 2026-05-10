function Get-DirectoryTree {
    <#
    .SYNOPSIS
        Erstellt eine hierarchische Baumstruktur eines Verzeichnisses.
    .DESCRIPTION
        Durchlaeuft rekursiv ein Verzeichnis und gibt ein strukturiertes PSCustomObject
        zurueck, das Name, Typ, Dateien und Unterverzeichnisse enthaelt.
        Optional kann das Ergebnis direkt als JSON-Datei exportiert werden.
    .PARAMETER Path
        Pfad zum zu analysierenden Verzeichnis.
    .PARAMETER OutPath
        Optionaler Pfad zur JSON-Ausgabedatei. Wenn angegeben, wird das Ergebnis exportiert.
    .PARAMETER Depth
        Tiefe fuer die JSON-Konvertierung beim Export. Standard: 50.
    .PARAMETER IncludeExtension
        Wenn angegeben, werden nur Dateien mit diesen Endungen aufgenommen (z.B. '.ps1', '.json').
    .PARAMETER ExcludePattern
        Wildcard-Muster zum Ausschliessen von Pfaden oder Dateien.
    .EXAMPLE
        $tree = Get-DirectoryTree -Path 'C:\Projekte'
        Gibt den Verzeichnisbaum als Objekt zurueck.
    .EXAMPLE
        Get-DirectoryTree -Path 'C:\Projekte' -OutPath 'C:\tree.json'
        Exportiert den Baum direkt als JSON-Datei.
    .EXAMPLE
        Get-DirectoryTree -Path 'C:\Projekte' -IncludeExtension '.ps1','.psm1' -ExcludePattern '*\.git*'
        Gibt nur PowerShell-Dateien zurueck und schliesst .git-Verzeichnisse aus.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path,

        [string]$OutPath,

        [int]$Depth = 50,

        [string[]]$IncludeExtension,

        [string[]]$ExcludePattern
    )

    $currentDir = Get-Item -Path $Path

    $files = Get-ChildItem -Path $Path -File
    if ($IncludeExtension) {
        $files = $files | Where-Object { $IncludeExtension -contains $_.Extension }
    }
    if ($ExcludePattern) {
        $files = $files | Where-Object {
            $full = $_.FullName
            -not ($ExcludePattern | Where-Object { $full -like $_ })
        }
    }
    $files = $files | Select-Object Name, Length, LastWriteTime

    $subDirs = Get-ChildItem -Path $Path -Directory
    if ($ExcludePattern) {
        $subDirs = $subDirs | Where-Object {
            $full = $_.FullName
            -not ($ExcludePattern | Where-Object { $full -like $_ })
        }
    }

    $childDirectories = foreach ($dir in $subDirs) {
        Get-DirectoryTree -Path $dir.FullName -IncludeExtension $IncludeExtension -ExcludePattern $ExcludePattern
    }

    $output = [PSCustomObject]@{
        Name          = $currentDir.Name
        Type          = 'Directory'
        LastWriteTime = $currentDir.LastWriteTime
        Files         = $files
        Directories   = $childDirectories
    }

    if ($OutPath) {
        try {
            $output | ConvertTo-Json -Depth $Depth | Out-File -FilePath $OutPath -Encoding UTF8
            Write-Verbose "Verzeichnisbaum exportiert nach: $OutPath"
            Write-Host "OK: Verzeichnisbaum nach '$OutPath' exportiert." -ForegroundColor Green
        }
        catch {
            Write-Error "Fehler beim Exportieren: $($_.Exception.Message)"
        }
    }

    return $output
}