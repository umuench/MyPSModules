function Convert-ToUtf8 {
    <#
    .SYNOPSIS
        Konvertiert Textdateien von ANSI-Kodierung nach UTF-8.
    .DESCRIPTION
        Liest Dateien im ANSI-Format (System.Text.Encoding.Default) ein und schreibt sie
        als UTF-8 zurueck. Unterstuetzt optionales BOM, Backup, rekursive Suche und Logging.
        Unterstuetzt -WhatIf.
    .PARAMETER Path
        Pfad zu einer einzelnen Datei oder einem Verzeichnis.
    .PARAMETER Filter
        Dateifilter fuer die Verzeichnissuche. Standard: *.txt
    .PARAMETER Recurse
        Durchsucht Unterverzeichnisse rekursiv.
    .PARAMETER NoBOM
        Schreibt UTF-8 ohne BOM. Standard: mit BOM.
    .PARAMETER Backup
        Erstellt vor der Konvertierung eine .bak-Sicherungskopie.
    .PARAMETER LogPath
        Pfad zur Logdatei. Jede Aktion wird dort protokolliert.
    .EXAMPLE
        Convert-ToUtf8 -Path 'C:\Daten' -Filter '*.txt' -Recurse
        Konvertiert alle .txt-Dateien in C:\Daten und Unterordnern nach UTF-8.
    .EXAMPLE
        Convert-ToUtf8 -Path 'C:\Daten\datei.txt' -Backup -WhatIf
        Zeigt, was passieren wuerde, ohne Aenderungen vorzunehmen.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Path,

        [string]$Filter = "*.txt",

        [switch]$Recurse,

        [switch]$NoBOM,

        [switch]$Backup,

        [string]$LogPath
    )

    begin {
        $ansiEncoding = [System.Text.Encoding]::Default
        $utf8Encoding = if ($NoBOM) {
            New-Object System.Text.UTF8Encoding($false)
        } else {
            New-Object System.Text.UTF8Encoding($true)
        }
    }

    process {
        if (-not (Test-Path $Path)) {
            throw "Pfad existiert nicht: $Path"
        }

        $files = if (Test-Path $Path -PathType Leaf) {
            Get-Item $Path
        } else {
            Get-ChildItem -Path $Path -Filter $Filter -File -Recurse:$Recurse
        }

        foreach ($file in $files) {
            try {
                if ($PSCmdlet.ShouldProcess($file.FullName, "Konvertiere nach UTF-8")) {
                    Write-Log -Message "Verarbeite: $($file.FullName)" -LogPath $LogPath

                    if ($Backup) {
                        $backupPath = "$($file.FullName).bak"
                        Copy-Item $file.FullName $backupPath -Force
                        Write-Log -Message "Backup erstellt: $backupPath" -LogPath $LogPath
                    }

                    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
                    $text  = $ansiEncoding.GetString($bytes)
                    [System.IO.File]::WriteAllText($file.FullName, $text, $utf8Encoding)

                    Write-Log -Message "Erfolgreich konvertiert." -LogPath $LogPath
                }
            }
            catch {
                Write-Warning "Fehler bei $($file.FullName): $_"
            }
        }
    }
}