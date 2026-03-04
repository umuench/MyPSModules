#requires -Version 5.1

function Convert-ToUtf8 {

    [CmdletBinding(SupportsShouldProcess = $true)]
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

        function Write-Log {
            param([string]$Message)

            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $entry = "$timestamp - $Message"

            Write-Verbose $entry

            if ($LogPath) {
                Add-Content -Path $LogPath -Value $entry
            }
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

                    Write-Log "Verarbeite: $($file.FullName)"

                    if ($Backup) {
                        $backupPath = "$($file.FullName).bak"
                        Copy-Item $file.FullName $backupPath -Force
                        Write-Log "Backup erstellt: $backupPath"
                    }

                    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
                    $text  = $ansiEncoding.GetString($bytes)

                    [System.IO.File]::WriteAllText($file.FullName, $text, $utf8Encoding)

                    Write-Log "Erfolgreich konvertiert."
                }
            }
            catch {
                Write-Warning "Fehler bei $($file.FullName): $_"
            }
        }
    }
}

Export-ModuleMember -Function Convert-ToUtf8
