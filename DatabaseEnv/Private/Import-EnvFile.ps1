function Import-EnvFile {
    <#
    .SYNOPSIS
        Laedt eine .env-Vorlagendatei in den Modul-Cache ($script:EnvConfig).
    .DESCRIPTION
        Sucht im Modulverzeichnis nach config.env oder .env (oder einem expliziten Pfad)
        und parst Key=Value-Paare in $script:EnvConfig. Wird beim zweiten Aufruf uebersprungen
        (einmaliger Ladevorgang pro Sitzung).
    .PARAMETER TemplatePath
        Optionaler expliziter Pfad zu einer Vorlagendatei.
    .EXAMPLE
        Import-EnvFile -TemplatePath 'C:\Vorlagen\db.env'
    #>
    param([string]$TemplatePath)

    if ($null -ne $script:EnvConfig) { return }

    Write-Verbose "Initialisiere Master-Vorlagen-Cache..."
    $script:EnvConfig = @{}

    $resolvedPath = $null
    $envNames     = 'config.env', '.env'

    if ($TemplatePath -and (Test-Path -Path $TemplatePath -PathType Leaf)) {
        $resolvedPath = $TemplatePath
    }
    else {
        foreach ($name in $envNames) {
            $candidate = Join-Path -Path $script:ModuleBase -ChildPath $name
            if (Test-Path -Path $candidate -PathType Leaf) {
                $resolvedPath = $candidate
                break
            }
        }
    }

    if (-not $resolvedPath) {
        Write-Warning "Keine Vorlage im Modulverzeichnis ($script:ModuleBase) gefunden."
        return
    }

    try {
        Get-Content -Path $resolvedPath | ForEach-Object {
            $line = $_.Trim()
            if ($line -and $line -notmatch '^\s*#') {
                $parts = $line.Split('=', 2)
                if ($parts.Count -eq 2) {
                    $key   = $parts[0].Trim()
                    $value = $parts[1].Trim() -replace '^["'']' -replace '["'']$'
                    $script:EnvConfig[$key] = $value
                }
            }
        }
    }
    catch {
        Write-Error "Fehler beim Lesen der Vorlage: $($_.Exception.Message)"
    }
}