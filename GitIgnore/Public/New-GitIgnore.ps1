function New-GitIgnore {
    <#
    .SYNOPSIS
        Erstellt oder aktualisiert eine .gitignore-Datei aus Vorlagen mit Auto-Erkennung und Deduplizierung.
    .DESCRIPTION
        Liest Vorlagendateien (.gitignore_base, .gitignore_node usw.) aus einem konfigurierten
        Vorlagenpfad und erzeugt eine deduplizierte .gitignore im aktuellen Verzeichnis.
        Wird kein Typ angegeben, erkennt die Funktion den Projekttyp automatisch anhand
        vorhandener Dateien und Verzeichnisse.
    .PARAMETER Type
        Typ(en) der einzubindenden Vorlagen (z.B. 'Node', 'Python', 'Java').
        Mehrere Typen koennen als Array uebergeben werden.
        Wird nichts angegeben, erfolgt Auto-Erkennung.
    .PARAMETER Append
        Fuegt die Vorlagen an eine bestehende .gitignore an, statt sie zu ueberschreiben.
    .PARAMETER TemplatePath
        Optionaler expliziter Pfad zum Vorlagenverzeichnis.
        Fallback: Umgebungsvariable GITIGNORE_TEMPLATES, dann C:\ProgramData\Git\Templates.
    .EXAMPLE
        New-GitIgnore
        Erkennt den Projekttyp automatisch und erstellt eine passende .gitignore.
    .EXAMPLE
        New-GitIgnore -Type 'Python', 'Vscode'
        Erstellt eine .gitignore fuer Python-Projekte mit VS-Code-Eintraegen.
    .EXAMPLE
        New-GitIgnore -Type 'Node' -Append
        Fuegt die Node.js-Vorlage an eine bestehende .gitignore an.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string[]]$Type = @(),

        [switch]$Append,

        [string]$TemplatePath
    )

    if ($Type.Count -eq 0) {
        Write-Host "Kein Typ angegeben. Versuche Auto-Erkennung..." -ForegroundColor Gray
        $DetectedTypes = @()

        if ((Test-Path 'package.json') -or (Test-Path 'node_modules') -or
            (Get-ChildItem -Filter '*.js' -Recurse -Depth 1 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter '*.ts' -Recurse -Depth 1 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Node'
        }
        if ((Test-Path 'requirements.txt') -or (Test-Path 'setup.py') -or
            (Test-Path 'Pipfile') -or (Test-Path '.venv') -or
            (Get-ChildItem -Filter '*.py' -Recurse -Depth 1 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Python'
        }
        if ((Test-Path 'pom.xml') -or (Test-Path 'build.gradle') -or
            (Test-Path 'src/main/java') -or
            (Get-ChildItem -Filter '*.java' -Recurse -Depth 1 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Java'
        }
        if ((Get-ChildItem -Filter '*.sln'    -Depth 1 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter '*.csproj' -Depth 2 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter '*.fsproj' -Depth 2 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter '*.vbproj' -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Dotnet'
        }
        if ((Test-Path 'go.mod') -or
            (Get-ChildItem -Filter '*.go' -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Go'
        }
        if ((Test-Path 'Cargo.toml') -or
            (Get-ChildItem -Filter '*.rs' -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Rust'
        }
        if ((Test-Path 'composer.json') -or
            (Get-ChildItem -Filter '*.php' -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Php'
        }
        if ((Test-Path 'Gemfile') -or (Test-Path '.ruby-version') -or
            (Get-ChildItem -Filter '*.rb' -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += 'Ruby'
        }
        if ((Get-ChildItem -Filter '*.kt' -Recurse -Depth 2 -ErrorAction SilentlyContinue) -or
            (Test-Path 'settings.gradle.kts')) {
            $DetectedTypes += 'Java_Kotlin'
        }
        if ((Test-Path 'vite.config.js') -or (Test-Path 'vite.config.ts') -or
            (Test-Path 'webpack.config.js') -or (Test-Path 'astro.config.mjs') -or
            (Test-Path 'svelte.config.js')) {
            $DetectedTypes += 'Frontend'
        }
        if (Test-Path '.vscode') { $DetectedTypes += 'Vscode'    }
        if (Test-Path '.idea')   { $DetectedTypes += 'Jetbrains' }

        if ($DetectedTypes.Count -gt 0) {
            $Type = $DetectedTypes
            Write-Host "  [i] Auto-erkannt: $($Type -join ', ')" -ForegroundColor Yellow
        }
        else {
            Write-Host "  [i] Kein spezifischer Typ erkannt. Nur Base-Vorlage wird verwendet." -ForegroundColor Gray
        }
    }

    $resolvedTemplatePath = $null
    if ($TemplatePath -and (Test-Path -Path $TemplatePath)) {
        $resolvedTemplatePath = $TemplatePath
    }
    else {
        foreach ($p in $script:DefaultTemplatePaths) {
            if (Test-Path -Path $p) { $resolvedTemplatePath = $p; break }
        }
    }

    if (-not $resolvedTemplatePath) {
        Write-Error "Vorlagenpfad nicht gefunden. Bitte -TemplatePath angeben oder GITIGNORE_TEMPLATES setzen."
        return
    }

    $OutputFile   = Join-Path -Path (Get-Location) -ChildPath '.gitignore'
    $BaseTemplate = Join-Path -Path $resolvedTemplatePath -ChildPath '.gitignore_base'

    if (-not (Test-Path -Path $BaseTemplate)) {
        Write-Error "Base-Vorlage nicht gefunden: $BaseTemplate"
        return
    }

    $SeenRules   = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    $FinalContent = New-Object System.Collections.Generic.List[string]

    $params = @{ SeenRules = $SeenRules; FinalContent = $FinalContent }

    if ($Append -and (Test-Path -Path $OutputFile)) {
        Write-Host "Fuege an bestehende .gitignore an..." -ForegroundColor Cyan
        try {
            Invoke-GitIgnoreLineProcessing -Lines (Get-Content -Path $OutputFile) -SourceName 'Existing .gitignore' @params
        }
        catch {
            Write-Error "Fehler beim Lesen der vorhandenen .gitignore: $_"
            return
        }
        [void]$FinalContent.Add('')
        [void]$FinalContent.Add('# --- Fehlende Base-Regeln ---')
    }
    elseif ($Append) {
        Write-Warning "Append angegeben, aber keine .gitignore gefunden. Erstelle neue Datei."
        Write-Host "Erstelle .gitignore..." -ForegroundColor Cyan
    }
    else {
        Write-Host "Erstelle/Ueberschreibe .gitignore..." -ForegroundColor Cyan
    }

    try {
        Invoke-GitIgnoreLineProcessing -Lines (Get-Content -Path $BaseTemplate) -SourceName 'Base Template' @params
    }
    catch {
        Write-Error "Fehler beim Lesen der Base-Vorlage: $_"
        return
    }

    foreach ($T in $Type) {
        $TemplateName = '.gitignore_' + $T.ToLower()
        $TemplateFile = Join-Path -Path $resolvedTemplatePath -ChildPath $TemplateName

        if (Test-Path -Path $TemplateFile) {
            [void]$FinalContent.Add('')
            [void]$FinalContent.Add("# --- $T Template ---")
            try {
                Invoke-GitIgnoreLineProcessing -Lines (Get-Content -Path $TemplateFile) -SourceName "$T Template" @params
            }
            catch {
                Write-Error "Fehler beim Lesen der Vorlage '$T': $_"
            }
        }
        else {
            Write-Warning "Vorlage nicht gefunden: $TemplateName (uebersprungen)"
        }
    }

    try {
        $FinalContent | Set-Content -Path $OutputFile -Encoding UTF8 -Force
        Write-Host "Fertig! .gitignore erstellt unter: $OutputFile" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Fehler beim Schreiben der Ausgabedatei: $_"
    }
}