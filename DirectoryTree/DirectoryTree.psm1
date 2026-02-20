function Get-DirectoryTree {
    <#
    .SYNOPSIS
        Erstellt eine hierarchische Baumstruktur eines Verzeichnisses.

    .DESCRIPTION
        Diese Funktion durchläuft rekursiv ein Verzeichnis und erstellt eine
        strukturierte Baumdarstellung mit allen Dateien und Unterverzeichnissen.
        Optional kann das Ergebnis direkt als JSON-Datei exportiert werden.

    .PARAMETER Path
        Der Pfad zum Verzeichnis, das analysiert werden soll.

    .PARAMETER OutPath
        Optionaler Pfad zur JSON-Ausgabedatei. Wenn angegeben, wird das Ergebnis
        automatisch als JSON exportiert.

    .PARAMETER Depth
        Die Tiefe für die JSON-Konvertierung. Standard: 50
    .PARAMETER IncludeExtension
        Optional: Nur Dateien mit diesen Endungen aufnehmen (z. B. ".ps1", ".json").
    .PARAMETER ExcludePattern
        Optional: Wildcard-Patterns zum Ausschliessen von Pfaden/Dateien.

    .EXAMPLE
        $tree = Get-DirectoryTree -Path C:\Users\Student\Development\

    .EXAMPLE
        Get-DirectoryTree -Path C:\Users\Student\Development\ -OutPath "C:\meinVerzeichnis.json"

    .EXAMPLE
        $tree = Get-DirectoryTree -Path C:\Projekte
        $tree | ConvertTo-Json -Depth 50 | Out-File "output.json"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$OutPath,

        [Parameter(Mandatory = $false)]
        [int]$Depth = 50,

        [Parameter(Mandatory = $false)]
        [string[]]$IncludeExtension,

        [Parameter(Mandatory = $false)]
        [string[]]$ExcludePattern
    )

    # Hole das aktuelle Verzeichnis-Objekt selbst
    $currentDir = Get-Item -Path $Path

    # 1. Hole alle Dateien im aktuellen Verzeichnis
    #    Wir wählen die von dir gewünschten Eigenschaften aus
    $files = Get-ChildItem -Path $Path -File
    if ($IncludeExtension -and $IncludeExtension.Count -gt 0) {
        $files = $files | Where-Object { $IncludeExtension -contains $_.Extension }
    }
    if ($ExcludePattern -and $ExcludePattern.Count -gt 0) {
        $files = $files | Where-Object {
            $full = $_.FullName
            -not ($ExcludePattern | Where-Object { $full -like $_ })
        }
    }
    $files = $files | Select-Object Name, Length, LastWriteTime

    # 2. Hole alle Unterverzeichnisse
    $subDirs = Get-ChildItem -Path $Path -Directory
    if ($ExcludePattern -and $ExcludePattern.Count -gt 0) {
        $subDirs = $subDirs | Where-Object {
            $full = $_.FullName
            -not ($ExcludePattern | Where-Object { $full -like $_ })
        }
    }

    # 3. Rufe diese Funktion für jedes Unterverzeichnis erneut auf (Rekursion)
    $childDirectories = foreach ($dir in $subDirs) {
        # Rekursiver Aufruf ohne OutPath, da wir nur am Ende exportieren
        Get-DirectoryTree -Path $dir.FullName -IncludeExtension $IncludeExtension -ExcludePattern $ExcludePattern
    }

    # 4. Baue das finale Objekt für DIESES Verzeichnis zusammen
    $output = [PSCustomObject]@{
        Name          = $currentDir.Name
        Type          = "Directory"
        LastWriteTime = $currentDir.LastWriteTime
        Files         = $files
        Directories   = $childDirectories
    }

    # Wenn OutPath angegeben wurde und wir im obersten Level sind, exportiere als JSON
    if ($OutPath -and $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('OutPath')) {
        Write-Verbose "Exportiere Verzeichnisbaum nach: $OutPath"
        $output | ConvertTo-Json -Depth $Depth | Out-File -FilePath $OutPath -Encoding UTF8
        Write-Host "Verzeichnisbaum wurde erfolgreich nach '$OutPath' exportiert." -ForegroundColor Green
    }

    return $output
}

# Exportiere die Funktion, damit sie verfügbar ist
Export-ModuleMember -Function Get-DirectoryTree
