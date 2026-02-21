# =============================================================================
# MODUL: GitInit
# AUTHOR: Gemini AI
# DATE: 2023-10-27 (Updated: Auto-Detection added)
# DESCRIPTION: Helper functions for Git repository initialization.
# =============================================================================

# Define standard template paths
$DefaultTemplatePaths = @(
    $env:GITIGNORE_TEMPLATES,
    "C:\ProgramData\Git\Templates",
    (Join-Path $PSScriptRoot "Templates")
) | Where-Object { $_ -and $_.Trim() -ne "" }

function New-GitIgnore {
    <#
    .SYNOPSIS
    Creates or updates a .gitignore file from templates with deduplication and auto-detection.

    .PARAMETER Type
    The type(s) of templates to include (e.g., 'Node', 'Python').
    If omitted, attempts to auto-detect based on files in the current directory.

    .PARAMETER Append
    If set, appends to an existing .gitignore instead of overwriting it.
    #>
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [string[]]$Type = @(),

        [Parameter(Mandatory=$false)]
        [switch]$Append,

        [Parameter(Mandatory=$false)]
        [string]$TemplatePath
    )

    # --- Auto-Detection Logic ---
    if ($Type.Count -eq 0) {
        Write-Host "No type specified. Attempting auto-detection..." -ForegroundColor Gray
        $DetectedTypes = @()

        # Node.js indicators
        if ((Test-Path "package.json") -or (Test-Path "node_modules") -or (Get-ChildItem -Filter "*.js" -Recurse -Depth 1 -ErrorAction SilentlyContinue) -or (Get-ChildItem -Filter "*.ts" -Recurse -Depth 1 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Node"
        }
        # Python indicators
        if ((Test-Path "requirements.txt") -or (Test-Path "setup.py") -or (Test-Path "Pipfile") -or (Test-Path ".venv") -or (Get-ChildItem -Filter "*.py" -Recurse -Depth 1 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Python"
        }
        # Java indicators
        if ((Test-Path "pom.xml") -or (Test-Path "build.gradle") -or (Test-Path "src/main/java") -or (Get-ChildItem -Filter "*.java" -Recurse -Depth 1 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Java"
        }
        # .NET indicators
        if ((Get-ChildItem -Filter "*.sln" -Depth 1 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter "*.csproj" -Depth 2 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter "*.fsproj" -Depth 2 -ErrorAction SilentlyContinue) -or
            (Get-ChildItem -Filter "*.vbproj" -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Dotnet"
        }
        # Go indicators
        if ((Test-Path "go.mod") -or (Get-ChildItem -Filter "*.go" -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Go"
        }
        # Rust indicators
        if ((Test-Path "Cargo.toml") -or (Get-ChildItem -Filter "*.rs" -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Rust"
        }
        # PHP indicators
        if ((Test-Path "composer.json") -or (Get-ChildItem -Filter "*.php" -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Php"
        }
        # Ruby indicators
        if ((Test-Path "Gemfile") -or (Test-Path ".ruby-version") -or (Get-ChildItem -Filter "*.rb" -Recurse -Depth 2 -ErrorAction SilentlyContinue)) {
            $DetectedTypes += "Ruby"
        }
        # Kotlin indicators (uses java_kotlin template)
        if ((Get-ChildItem -Filter "*.kt" -Recurse -Depth 2 -ErrorAction SilentlyContinue) -or (Test-Path "settings.gradle.kts")) {
            $DetectedTypes += "Java_Kotlin"
        }
        # Frontend indicators
        if ((Test-Path "vite.config.js") -or (Test-Path "vite.config.ts") -or (Test-Path "webpack.config.js") -or (Test-Path "astro.config.mjs") -or (Test-Path "svelte.config.js")) {
            $DetectedTypes += "Frontend"
        }
        # IDE indicators
        if (Test-Path ".vscode") { $DetectedTypes += "Vscode" }
        if (Test-Path ".idea") { $DetectedTypes += "Jetbrains" }

        if ($DetectedTypes.Count -gt 0) {
            $Type = $DetectedTypes
            Write-Host "  [i] Auto-detected: $($Type -join ', ')" -ForegroundColor Yellow
        } else {
            Write-Host "  [i] No specific language detected. Using only base template." -ForegroundColor Gray
        }
    }

    $resolvedTemplatePath = $null
    if ($TemplatePath -and (Test-Path -Path $TemplatePath)) {
        $resolvedTemplatePath = $TemplatePath
    }
    else {
        foreach ($p in $DefaultTemplatePaths) {
            if (Test-Path -Path $p) { $resolvedTemplatePath = $p; break }
        }
    }

    if (-not $resolvedTemplatePath) {
        Write-Error "Template path not found. Set -TemplatePath or GITIGNORE_TEMPLATES."
        return
    }

    $OutputFile = Join-Path -Path (Get-Location) -ChildPath ".gitignore"
    $BaseTemplate = Join-Path -Path $resolvedTemplatePath -ChildPath ".gitignore_base"

    if (-not (Test-Path -Path $BaseTemplate)) {
        Write-Error "Base template not found at: $BaseTemplate"
        return
    }

    $SeenRules = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
    $FinalContent = New-Object System.Collections.Generic.List[string]

    function Process-Lines {
        param($Lines, $SourceName, $IsExistingFile = $false)
        foreach ($Line in $Lines) {
            $Trimmed = $Line.Trim()
            if ($Trimmed.Length -gt 0 -and -not $Trimmed.StartsWith("#")) {
                if (-not $SeenRules.Contains($Trimmed)) {
                    [void]$SeenRules.Add($Trimmed)
                    [void]$FinalContent.Add($Line)
                }
            }
            else {
                [void]$FinalContent.Add($Line)
            }
        }
        if ($Lines) { Write-Host "  [+] Processed $SourceName" -ForegroundColor Green }
    }

    if ($Append -and (Test-Path -Path $OutputFile)) {
        Write-Host "Appending to existing .gitignore..." -ForegroundColor Cyan
        try { Process-Lines -Lines (Get-Content -Path $OutputFile) -SourceName "Existing .gitignore" -IsExistingFile $true }
        catch { Write-Error "Failed to read existing .gitignore: $_"; return }
    }
    elseif ($Append) {
         Write-Warning "Append switch used, but no .gitignore found. Creating new one."
         Write-Host "Creating .gitignore..." -ForegroundColor Cyan
    }
    else {
        Write-Host "Creating/Overwriting .gitignore..." -ForegroundColor Cyan
    }

    try {
        if ($Append -and (Test-Path -Path $OutputFile)) {
             [void]$FinalContent.Add("")
             [void]$FinalContent.Add("# --- Missing Base Rules ---")
        }
        Process-Lines -Lines (Get-Content -Path $BaseTemplate) -SourceName "Base Template"
    }
    catch { Write-Error "Failed to read base template: $_"; return }

    foreach ($T in $Type) {
        $TemplateName = ".gitignore_" + $T.ToLower()
        $TemplateFile = Join-Path -Path $resolvedTemplatePath -ChildPath $TemplateName

        if (Test-Path -Path $TemplateFile) {
            [void]$FinalContent.Add("")
            [void]$FinalContent.Add("# --- $T Template ---")
            try { Process-Lines -Lines (Get-Content -Path $TemplateFile) -SourceName "$T Template" }
            catch { Write-Error "Failed to read $T template: $_" }
        }
        else { Write-Warning "Template not found: $TemplateName (skipping)" }
    }

    try {
        $FinalContent | Set-Content -Path $OutputFile -Encoding UTF8 -Force
        Write-Host "Done! Updated .gitignore at: $OutputFile" -ForegroundColor Cyan
    }
    catch { Write-Error "Failed to write output file: $_" }
}

Export-ModuleMember -Function New-GitIgnore

Set-Alias -Name ngi -Value New-GitIgnore
Export-ModuleMember -Alias ngi
