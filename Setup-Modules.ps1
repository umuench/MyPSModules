<#
.SYNOPSIS
    Erstellt benoetigte Zusatzdateien und prueft Abhaengigkeiten fuer die Module.

.DESCRIPTION
    Legt GitIgnore-Templates an (Base/Node/Python/Java) und prueft u. a. Inkscape.
    Wenn keine Adminrechte fuer C:\ProgramData vorhanden sind, wird in ein User-Template
    Verzeichnis geschrieben und ein Hinweis ausgegeben, wie der Pfad zu konfigurieren ist.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$TemplatePath,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$systemTemplatePath = "C:\ProgramData\Git\Templates"
$userTemplatePath = Join-Path $env:LOCALAPPDATA "Git\Templates"

$targetTemplatePath = if ($TemplatePath) { $TemplatePath } else { $systemTemplatePath }
$usedFallback = $false

function Write-Info {
    param([string]$Text)
    Write-Host $Text -ForegroundColor Cyan
}

function Write-Warn {
    param([string]$Text)
    Write-Host $Text -ForegroundColor Yellow
}

function Ensure-TemplateFolder {
    param([string]$Path)
    try {
        if (-not (Test-Path $Path)) {
            if ($PSCmdlet.ShouldProcess($Path, "Template-Ordner erstellen")) {
                New-Item -Path $Path -ItemType Directory -Force | Out-Null
            }
        }
        return $true
    }
    catch {
        return $false
    }
}

$templates = @{
    ".gitignore_base" = @"
# General
Thumbs.db
Desktop.ini
.DS_Store
*.log
*.tmp
*.bak
.env
.env.*
"@
    ".gitignore_node" = @"
# Node
node_modules/
dist/
build/
.next/
.turbo/
"@
    ".gitignore_python" = @"
# Python
__pycache__/
*.py[cod]
*.pyo
.venv/
venv/
.mypy_cache/
.pytest_cache/
"@
    ".gitignore_java" = @"
# Java
target/
.gradle/
*.class
*.jar
*.war
*.ear
"@
}

Write-Info "=== Setup: GitIgnore Templates ==="

if (-not (Ensure-TemplateFolder -Path $targetTemplatePath)) {
    Write-Warn "Kein Zugriff auf $targetTemplatePath. Weiche aus auf User-Pfad."
    $targetTemplatePath = $userTemplatePath
    $usedFallback = $true
    if (-not (Ensure-TemplateFolder -Path $targetTemplatePath)) {
        throw "Konnte Template-Verzeichnis nicht erstellen: $targetTemplatePath"
    }
}

foreach ($name in $templates.Keys) {
    $filePath = Join-Path $targetTemplatePath $name
    if ((Test-Path $filePath) -and -not $Force) {
        Write-Host "Vorhanden: $filePath" -ForegroundColor Gray
        continue
    }
    if ($PSCmdlet.ShouldProcess($filePath, "Template schreiben")) {
        $templates[$name] | Out-File -FilePath $filePath -Encoding UTF8 -Force
        Write-Host "Erstellt:  $filePath" -ForegroundColor Green
    }
}

if ($usedFallback) {
    Write-Warn "Hinweis: Templates wurden im User-Pfad angelegt."
    Write-Warn "Setze fuer GitIgnore `-TemplatePath` oder `GITIGNORE_TEMPLATES=$targetTemplatePath`."
}

Write-Info ""
Write-Info "=== Setup: Abhaengigkeiten ==="

# Inkscape
$inkscapePaths = @(
    $env:INKSCAPE_PATH,
    "C:\Program Files\Inkscape\bin\inkscape.exe",
    "C:\Program Files (x86)\Inkscape\bin\inkscape.exe",
    "$env:LOCALAPPDATA\Programs\Inkscape\bin\inkscape.exe"
) | Where-Object { $_ -and (Test-Path $_ -ErrorAction SilentlyContinue) }

if ($inkscapePaths.Count -gt 0) {
    Write-Host "Inkscape: OK ($($inkscapePaths[0]))" -ForegroundColor Green
}
else {
    Write-Warn "Inkscape: NICHT GEFUNDEN (SetFoldersICO)"
}

# Task Scheduler Service
try {
    $svc = Get-Service -Name Schedule -ErrorAction Stop
    if ($svc.Status -eq "Running") {
        Write-Host "Task Scheduler: OK (Running)" -ForegroundColor Green
    }
    else {
        Write-Warn "Task Scheduler: $($svc.Status)"
    }
}
catch {
    Write-Warn "Task Scheduler: Dienst nicht gefunden"
}

Write-Info ""
Write-Host "Setup abgeschlossen." -ForegroundColor Green
