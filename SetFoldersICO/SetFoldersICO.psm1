#Requires -Version 5.1
<#
.SYNOPSIS
    SetFoldersICO - PowerShell-Modul für individuelle Entwicklungsordner-Icons

.DESCRIPTION
    Generiert und wendet individuelle ICO-Dateien für Entwicklungsordner an.
    Unterstützt 280+ Technologien mit offiziellen Markenfarben.
    
    Hauptfunktionen:
    - Set-DevFolderIcons  : Generiert Icons für alle Unterordner (Alias: sfdi)
    - Set-FolderIcon      : Wendet ein Icon auf einen Ordner an (Alias: sfi)
    - Remove-FolderIcon   : Entfernt ein Ordner-Icon (Alias: rfi)
    - New-FolderIcon      : Erstellt ein einzelnes Icon (Alias: nfi)
    - Get-TechDefinitions : Zeigt verfügbare Technologien (Alias: gtd)
    - Add-TechDefinition  : Fügt neue Technologie hinzu

.NOTES
    Autor: Uwe
    Version: 1.2.0
    Erfordert: Inkscape (https://inkscape.org)
#>

#region ==================== MODUL-KONFIGURATION ====================

# Standard-Inkscape-Pfade
$script:DefaultInkscapePaths = @(
    $env:INKSCAPE_PATH,
    "C:\Program Files\Inkscape\bin\inkscape.exe",
    "C:\Program Files (x86)\Inkscape\bin\inkscape.exe",
    "$env:LOCALAPPDATA\Programs\Inkscape\bin\inkscape.exe",
    (Get-Command inkscape -ErrorAction SilentlyContinue).Source
) | Where-Object { $_ -and (Test-Path $_ -ErrorAction SilentlyContinue) } | Select-Object -First 1

#endregion

#region ==================== TECHNOLOGIE-DEFINITIONEN ====================

<#
    Umfassende Mapping-Tabelle für Entwicklungstechnologien.
    
    Struktur:
    - Key: Ordnername (case-insensitive matching)
    - Abbr: Kürzel für das Icon (1-3 Zeichen)
    - BgColor: Hintergrundfarbe (Hex) - Offizielle Markenfarben
    - FgColor: Textfarbe (Hex)
    - Category: Kategorisierung für Filterung/Logging
#>

$script:TechDefinitions = @{
    # ═══════════════════════════════════════════════════════════════════════
    # PROGRAMMIERSPRACHEN
    # ═══════════════════════════════════════════════════════════════════════
    
    "Java"          = @{ Abbr = "J";   BgColor = "#ED8B00"; FgColor = "#FFFFFF"; Category = "Language" }
    "Python"        = @{ Abbr = "Py";  BgColor = "#3776AB"; FgColor = "#FFD43B"; Category = "Language" }
    "JavaScript"    = @{ Abbr = "JS";  BgColor = "#F7DF1E"; FgColor = "#000000"; Category = "Language" }
    "TypeScript"    = @{ Abbr = "TS";  BgColor = "#3178C6"; FgColor = "#FFFFFF"; Category = "Language" }
    "CSharp"        = @{ Abbr = "C#";  BgColor = "#512BD4"; FgColor = "#FFFFFF"; Category = "Language" }
    "C#"            = @{ Abbr = "C#";  BgColor = "#512BD4"; FgColor = "#FFFFFF"; Category = "Language" }
    "CPP"           = @{ Abbr = "++";  BgColor = "#00599C"; FgColor = "#FFFFFF"; Category = "Language" }
    "C++"           = @{ Abbr = "++";  BgColor = "#00599C"; FgColor = "#FFFFFF"; Category = "Language" }
    "C"             = @{ Abbr = "C";   BgColor = "#A8B9CC"; FgColor = "#000000"; Category = "Language" }
    "Go"            = @{ Abbr = "Go";  BgColor = "#00ADD8"; FgColor = "#FFFFFF"; Category = "Language" }
    "Golang"        = @{ Abbr = "Go";  BgColor = "#00ADD8"; FgColor = "#FFFFFF"; Category = "Language" }
    "Rust"          = @{ Abbr = "Rs";  BgColor = "#000000"; FgColor = "#F74C00"; Category = "Language" }
    "Ruby"          = @{ Abbr = "Rb";  BgColor = "#CC342D"; FgColor = "#FFFFFF"; Category = "Language" }
    "PHP"           = @{ Abbr = "PHP"; BgColor = "#777BB4"; FgColor = "#FFFFFF"; Category = "Language" }
    "Perl"          = @{ Abbr = "Pl";  BgColor = "#39457E"; FgColor = "#FFFFFF"; Category = "Language" }
    "Scala"         = @{ Abbr = "Sc";  BgColor = "#DC322F"; FgColor = "#FFFFFF"; Category = "Language" }
    "Kotlin"        = @{ Abbr = "Kt";  BgColor = "#7F52FF"; FgColor = "#FFFFFF"; Category = "Language" }
    "Swift"         = @{ Abbr = "Sw";  BgColor = "#F05138"; FgColor = "#FFFFFF"; Category = "Language" }
    "Dart"          = @{ Abbr = "Da";  BgColor = "#0175C2"; FgColor = "#FFFFFF"; Category = "Language" }
    "Lua"           = @{ Abbr = "Lua"; BgColor = "#2C2D72"; FgColor = "#FFFFFF"; Category = "Language" }
    "R"             = @{ Abbr = "R";   BgColor = "#276DC3"; FgColor = "#FFFFFF"; Category = "Language" }
    "Julia"         = @{ Abbr = "Jl";  BgColor = "#9558B2"; FgColor = "#FFFFFF"; Category = "Language" }
    "Haskell"       = @{ Abbr = "Hs";  BgColor = "#5E5086"; FgColor = "#FFFFFF"; Category = "Language" }
    "Elixir"        = @{ Abbr = "Ex";  BgColor = "#4B275F"; FgColor = "#FFFFFF"; Category = "Language" }
    "Erlang"        = @{ Abbr = "Er";  BgColor = "#A90533"; FgColor = "#FFFFFF"; Category = "Language" }
    "Clojure"       = @{ Abbr = "Clj"; BgColor = "#5881D8"; FgColor = "#FFFFFF"; Category = "Language" }
    "FSharp"        = @{ Abbr = "F#";  BgColor = "#378BBA"; FgColor = "#FFFFFF"; Category = "Language" }
    "F#"            = @{ Abbr = "F#";  BgColor = "#378BBA"; FgColor = "#FFFFFF"; Category = "Language" }
    "OCaml"         = @{ Abbr = "ML";  BgColor = "#EC6813"; FgColor = "#FFFFFF"; Category = "Language" }
    "Groovy"        = @{ Abbr = "Gr";  BgColor = "#4298B8"; FgColor = "#FFFFFF"; Category = "Language" }
    "COBOL"         = @{ Abbr = "COB"; BgColor = "#005CA5"; FgColor = "#FFFFFF"; Category = "Language" }
    "Fortran"       = @{ Abbr = "F";   BgColor = "#734F96"; FgColor = "#FFFFFF"; Category = "Language" }
    "Pascal"        = @{ Abbr = "Pas"; BgColor = "#E3F171"; FgColor = "#000000"; Category = "Language" }
    "Delphi"        = @{ Abbr = "Del"; BgColor = "#EE1F35"; FgColor = "#FFFFFF"; Category = "Language" }
    "ObjectiveC"    = @{ Abbr = "OC";  BgColor = "#438EFF"; FgColor = "#FFFFFF"; Category = "Language" }
    "Objective-C"   = @{ Abbr = "OC";  BgColor = "#438EFF"; FgColor = "#FFFFFF"; Category = "Language" }
    "Assembly"      = @{ Abbr = "ASM"; BgColor = "#6E4C13"; FgColor = "#FFFFFF"; Category = "Language" }
    "ASM"           = @{ Abbr = "ASM"; BgColor = "#6E4C13"; FgColor = "#FFFFFF"; Category = "Language" }
    "VHDL"          = @{ Abbr = "VHD"; BgColor = "#543978"; FgColor = "#FFFFFF"; Category = "Language" }
    "Verilog"       = @{ Abbr = "Ver"; BgColor = "#848484"; FgColor = "#FFFFFF"; Category = "Language" }
    "Zig"           = @{ Abbr = "Zig"; BgColor = "#F7A41D"; FgColor = "#000000"; Category = "Language" }
    "Nim"           = @{ Abbr = "Nim"; BgColor = "#FFE953"; FgColor = "#000000"; Category = "Language" }
    "Crystal"       = @{ Abbr = "Cr";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Language" }
    "V"             = @{ Abbr = "V";   BgColor = "#5D87BF"; FgColor = "#FFFFFF"; Category = "Language" }
    "Vlang"         = @{ Abbr = "V";   BgColor = "#5D87BF"; FgColor = "#FFFFFF"; Category = "Language" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # WEB FRAMEWORKS & LIBRARIES
    # ═══════════════════════════════════════════════════════════════════════
    
    "React"         = @{ Abbr = "Re";  BgColor = "#61DAFB"; FgColor = "#000000"; Category = "Frontend" }
    "ReactJS"       = @{ Abbr = "Re";  BgColor = "#61DAFB"; FgColor = "#000000"; Category = "Frontend" }
    "Vue"           = @{ Abbr = "V";   BgColor = "#4FC08D"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "VueJS"         = @{ Abbr = "V";   BgColor = "#4FC08D"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Angular"       = @{ Abbr = "Ng";  BgColor = "#DD0031"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "AngularJS"     = @{ Abbr = "Ng";  BgColor = "#DD0031"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Svelte"        = @{ Abbr = "Sv";  BgColor = "#FF3E00"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "SvelteKit"     = @{ Abbr = "SK";  BgColor = "#FF3E00"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Solid"         = @{ Abbr = "So";  BgColor = "#2C4F7C"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "SolidJS"       = @{ Abbr = "So";  BgColor = "#2C4F7C"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Preact"        = @{ Abbr = "Pr";  BgColor = "#673AB8"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Ember"         = @{ Abbr = "Em";  BgColor = "#E04E39"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "EmberJS"       = @{ Abbr = "Em";  BgColor = "#E04E39"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Backbone"      = @{ Abbr = "BB";  BgColor = "#0071B5"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "jQuery"        = @{ Abbr = "jQ";  BgColor = "#0769AD"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Alpine"        = @{ Abbr = "Al";  BgColor = "#8BC0D0"; FgColor = "#000000"; Category = "Frontend" }
    "AlpineJS"      = @{ Abbr = "Al";  BgColor = "#8BC0D0"; FgColor = "#000000"; Category = "Frontend" }
    "HTMX"          = @{ Abbr = "HX";  BgColor = "#3366CC"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Stimulus"      = @{ Abbr = "St";  BgColor = "#77E8B9"; FgColor = "#000000"; Category = "Frontend" }
    "Lit"           = @{ Abbr = "Lit"; BgColor = "#325CFF"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Astro"         = @{ Abbr = "As";  BgColor = "#FF5D01"; FgColor = "#FFFFFF"; Category = "Frontend" }
    "Qwik"          = @{ Abbr = "Qw";  BgColor = "#18B6F6"; FgColor = "#000000"; Category = "Frontend" }
    
    # --- Meta-Frameworks ---
    "Next"          = @{ Abbr = "Nx";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "MetaFramework" }
    "NextJS"        = @{ Abbr = "Nx";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "MetaFramework" }
    "Nuxt"          = @{ Abbr = "Nu";  BgColor = "#00DC82"; FgColor = "#000000"; Category = "MetaFramework" }
    "NuxtJS"        = @{ Abbr = "Nu";  BgColor = "#00DC82"; FgColor = "#000000"; Category = "MetaFramework" }
    "Remix"         = @{ Abbr = "Rx";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "MetaFramework" }
    "Gatsby"        = @{ Abbr = "Ga";  BgColor = "#663399"; FgColor = "#FFFFFF"; Category = "MetaFramework" }
    
    # --- CSS Frameworks ---
    "Tailwind"      = @{ Abbr = "TW";  BgColor = "#06B6D4"; FgColor = "#FFFFFF"; Category = "CSS" }
    "TailwindCSS"   = @{ Abbr = "TW";  BgColor = "#06B6D4"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Bootstrap"     = @{ Abbr = "Bs";  BgColor = "#7952B3"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Bulma"         = @{ Abbr = "Bu";  BgColor = "#00D1B2"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Foundation"    = @{ Abbr = "Fo";  BgColor = "#14679E"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Materialize"   = @{ Abbr = "Mz";  BgColor = "#EB7077"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Sass"          = @{ Abbr = "Sa";  BgColor = "#CC6699"; FgColor = "#FFFFFF"; Category = "CSS" }
    "SCSS"          = @{ Abbr = "Sc";  BgColor = "#CC6699"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Less"          = @{ Abbr = "Le";  BgColor = "#1D365D"; FgColor = "#FFFFFF"; Category = "CSS" }
    "Stylus"        = @{ Abbr = "Sty"; BgColor = "#333333"; FgColor = "#FFFFFF"; Category = "CSS" }
    "PostCSS"       = @{ Abbr = "PC";  BgColor = "#DD3A0A"; FgColor = "#FFFFFF"; Category = "CSS" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # BACKEND FRAMEWORKS
    # ═══════════════════════════════════════════════════════════════════════
    
    "Node"          = @{ Abbr = "N";   BgColor = "#339933"; FgColor = "#FFFFFF"; Category = "Backend" }
    "NodeJS"        = @{ Abbr = "N";   BgColor = "#339933"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Express"       = @{ Abbr = "Ex";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "ExpressJS"     = @{ Abbr = "Ex";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Fastify"       = @{ Abbr = "Fy";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "NestJS"        = @{ Abbr = "Ne";  BgColor = "#E0234E"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Nest"          = @{ Abbr = "Ne";  BgColor = "#E0234E"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Koa"           = @{ Abbr = "Koa"; BgColor = "#33333D"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Hono"          = @{ Abbr = "Ho";  BgColor = "#E36002"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Deno"          = @{ Abbr = "De";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Bun"           = @{ Abbr = "Bun"; BgColor = "#FBF0DF"; FgColor = "#14151A"; Category = "Backend" }
    "Django"        = @{ Abbr = "Dj";  BgColor = "#092E20"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Flask"         = @{ Abbr = "Fl";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "FastAPI"       = @{ Abbr = "FA";  BgColor = "#009688"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Spring"        = @{ Abbr = "Sp";  BgColor = "#6DB33F"; FgColor = "#FFFFFF"; Category = "Backend" }
    "SpringBoot"    = @{ Abbr = "SB";  BgColor = "#6DB33F"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Quarkus"       = @{ Abbr = "Qu";  BgColor = "#4695EB"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Micronaut"     = @{ Abbr = "Mn";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Rails"         = @{ Abbr = "RoR"; BgColor = "#CC0000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "RubyOnRails"   = @{ Abbr = "RoR"; BgColor = "#CC0000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Sinatra"       = @{ Abbr = "Si";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Laravel"       = @{ Abbr = "La";  BgColor = "#FF2D20"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Symfony"       = @{ Abbr = "Sf";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Backend" }
    "CodeIgniter"   = @{ Abbr = "CI";  BgColor = "#EE4623"; FgColor = "#FFFFFF"; Category = "Backend" }
    "CakePHP"       = @{ Abbr = "Ca";  BgColor = "#D33C43"; FgColor = "#FFFFFF"; Category = "Backend" }
    "ASPNet"        = @{ Abbr = "ASP"; BgColor = "#512BD4"; FgColor = "#FFFFFF"; Category = "Backend" }
    "ASP.NET"       = @{ Abbr = "ASP"; BgColor = "#512BD4"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Blazor"        = @{ Abbr = "Bz";  BgColor = "#512BD4"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Gin"           = @{ Abbr = "Gin"; BgColor = "#00ADD8"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Echo"          = @{ Abbr = "Ec";  BgColor = "#00ADD8"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Fiber"         = @{ Abbr = "Fi";  BgColor = "#00ADD8"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Actix"         = @{ Abbr = "Ax";  BgColor = "#000000"; FgColor = "#F74C00"; Category = "Backend" }
    "Rocket"        = @{ Abbr = "Ro";  BgColor = "#D33847"; FgColor = "#FFFFFF"; Category = "Backend" }
    "Phoenix"       = @{ Abbr = "Ph";  BgColor = "#FD4F00"; FgColor = "#FFFFFF"; Category = "Backend" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # MOBILE & CROSS-PLATFORM
    # ═══════════════════════════════════════════════════════════════════════
    
    "Flutter"       = @{ Abbr = "Fl";  BgColor = "#02569B"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "ReactNative"   = @{ Abbr = "RN";  BgColor = "#61DAFB"; FgColor = "#000000"; Category = "Mobile" }
    "Ionic"         = @{ Abbr = "Io";  BgColor = "#3880FF"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Xamarin"       = @{ Abbr = "Xa";  BgColor = "#3498DB"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "MAUI"          = @{ Abbr = "Ui";  BgColor = "#512BD4"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Cordova"       = @{ Abbr = "Co";  BgColor = "#E8E8E8"; FgColor = "#000000"; Category = "Mobile" }
    "Capacitor"     = @{ Abbr = "Cp";  BgColor = "#119EFF"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Electron"      = @{ Abbr = "El";  BgColor = "#47848F"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Tauri"         = @{ Abbr = "Ta";  BgColor = "#FFC131"; FgColor = "#000000"; Category = "Mobile" }
    "NativeScript"  = @{ Abbr = "NS";  BgColor = "#65ADF1"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Expo"          = @{ Abbr = "Xp";  BgColor = "#000020"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Android"       = @{ Abbr = "An";  BgColor = "#3DDC84"; FgColor = "#000000"; Category = "Mobile" }
    "iOS"           = @{ Abbr = "iOS"; BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "SwiftUI"       = @{ Abbr = "SU";  BgColor = "#F05138"; FgColor = "#FFFFFF"; Category = "Mobile" }
    "Jetpack"       = @{ Abbr = "Jp";  BgColor = "#4285F4"; FgColor = "#FFFFFF"; Category = "Mobile" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # DATENBANKEN
    # ═══════════════════════════════════════════════════════════════════════
    
    "MySQL"         = @{ Abbr = "My";  BgColor = "#4479A1"; FgColor = "#FFFFFF"; Category = "Database" }
    "PostgreSQL"    = @{ Abbr = "Pg";  BgColor = "#336791"; FgColor = "#FFFFFF"; Category = "Database" }
    "Postgres"      = @{ Abbr = "Pg";  BgColor = "#336791"; FgColor = "#FFFFFF"; Category = "Database" }
    "SQLite"        = @{ Abbr = "Sq";  BgColor = "#003B57"; FgColor = "#FFFFFF"; Category = "Database" }
    "MariaDB"       = @{ Abbr = "Ma";  BgColor = "#003545"; FgColor = "#FFFFFF"; Category = "Database" }
    "MongoDB"       = @{ Abbr = "Mo";  BgColor = "#47A248"; FgColor = "#FFFFFF"; Category = "Database" }
    "Redis"         = @{ Abbr = "Rd";  BgColor = "#DC382D"; FgColor = "#FFFFFF"; Category = "Database" }
    "Cassandra"     = @{ Abbr = "Ca";  BgColor = "#1287B1"; FgColor = "#FFFFFF"; Category = "Database" }
    "CouchDB"       = @{ Abbr = "CD";  BgColor = "#E42528"; FgColor = "#FFFFFF"; Category = "Database" }
    "Neo4j"         = @{ Abbr = "N4";  BgColor = "#008CC1"; FgColor = "#FFFFFF"; Category = "Database" }
    "Elasticsearch" = @{ Abbr = "Es";  BgColor = "#005571"; FgColor = "#FFFFFF"; Category = "Database" }
    "Oracle"        = @{ Abbr = "Or";  BgColor = "#F80000"; FgColor = "#FFFFFF"; Category = "Database" }
    "SQLServer"     = @{ Abbr = "SQL"; BgColor = "#CC2927"; FgColor = "#FFFFFF"; Category = "Database" }
    "MSSQL"         = @{ Abbr = "SQL"; BgColor = "#CC2927"; FgColor = "#FFFFFF"; Category = "Database" }
    "Firebase"      = @{ Abbr = "Fb";  BgColor = "#FFCA28"; FgColor = "#000000"; Category = "Database" }
    "Supabase"      = @{ Abbr = "Su";  BgColor = "#3ECF8E"; FgColor = "#FFFFFF"; Category = "Database" }
    "PlanetScale"   = @{ Abbr = "PS";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Database" }
    "DynamoDB"      = @{ Abbr = "Dy";  BgColor = "#4053D6"; FgColor = "#FFFFFF"; Category = "Database" }
    "Prisma"        = @{ Abbr = "Pr";  BgColor = "#2D3748"; FgColor = "#FFFFFF"; Category = "Database" }
    "Drizzle"       = @{ Abbr = "Dr";  BgColor = "#C5F74F"; FgColor = "#000000"; Category = "Database" }
    "InfluxDB"      = @{ Abbr = "In";  BgColor = "#22ADF6"; FgColor = "#FFFFFF"; Category = "Database" }
    "TimescaleDB"   = @{ Abbr = "Ts";  BgColor = "#FDB515"; FgColor = "#000000"; Category = "Database" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # DEVOPS & CLOUD
    # ═══════════════════════════════════════════════════════════════════════
    
    "Docker"        = @{ Abbr = "D";   BgColor = "#2496ED"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Kubernetes"    = @{ Abbr = "K8";  BgColor = "#326CE5"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "K8s"           = @{ Abbr = "K8";  BgColor = "#326CE5"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Terraform"     = @{ Abbr = "Tf";  BgColor = "#7B42BC"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Ansible"       = @{ Abbr = "An";  BgColor = "#EE0000"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Puppet"        = @{ Abbr = "Pu";  BgColor = "#FFAE1A"; FgColor = "#000000"; Category = "DevOps" }
    "Chef"          = @{ Abbr = "Ch";  BgColor = "#F09820"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Jenkins"       = @{ Abbr = "Jn";  BgColor = "#D24939"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "GitLab"        = @{ Abbr = "GL";  BgColor = "#FC6D26"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "GitHub"        = @{ Abbr = "GH";  BgColor = "#181717"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Bitbucket"     = @{ Abbr = "Bb";  BgColor = "#0052CC"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "CircleCI"      = @{ Abbr = "CC";  BgColor = "#343434"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "TravisCI"      = @{ Abbr = "Tr";  BgColor = "#3EAAAF"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "ArgoCD"        = @{ Abbr = "Ar";  BgColor = "#EF7B4D"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Helm"          = @{ Abbr = "Hm";  BgColor = "#0F1689"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Prometheus"    = @{ Abbr = "Pm";  BgColor = "#E6522C"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Grafana"       = @{ Abbr = "Gf";  BgColor = "#F46800"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Datadog"       = @{ Abbr = "DD";  BgColor = "#632CA6"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "NewRelic"      = @{ Abbr = "NR";  BgColor = "#008C99"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Splunk"        = @{ Abbr = "Sp";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Vagrant"       = @{ Abbr = "Vg";  BgColor = "#1868F2"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Packer"        = @{ Abbr = "Pk";  BgColor = "#02A8EF"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Consul"        = @{ Abbr = "Co";  BgColor = "#F24C53"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Vault"         = @{ Abbr = "Vt";  BgColor = "#000000"; FgColor = "#FFEC6E"; Category = "DevOps" }
    "Nginx"         = @{ Abbr = "Nx";  BgColor = "#009639"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Apache"        = @{ Abbr = "Ap";  BgColor = "#D22128"; FgColor = "#FFFFFF"; Category = "DevOps" }
    "Caddy"         = @{ Abbr = "Cd";  BgColor = "#00ADD8"; FgColor = "#FFFFFF"; Category = "DevOps" }
    
    # --- Cloud Providers ---
    "AWS"           = @{ Abbr = "AWS"; BgColor = "#232F3E"; FgColor = "#FF9900"; Category = "Cloud" }
    "Azure"         = @{ Abbr = "Az";  BgColor = "#0078D4"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "GCP"           = @{ Abbr = "GC";  BgColor = "#4285F4"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "GoogleCloud"   = @{ Abbr = "GC";  BgColor = "#4285F4"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "DigitalOcean"  = @{ Abbr = "DO";  BgColor = "#0080FF"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Heroku"        = @{ Abbr = "He";  BgColor = "#430098"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Vercel"        = @{ Abbr = "Vc";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Netlify"       = @{ Abbr = "Nf";  BgColor = "#00C7B7"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Cloudflare"    = @{ Abbr = "CF";  BgColor = "#F38020"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Linode"        = @{ Abbr = "Li";  BgColor = "#00A95C"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Vultr"         = @{ Abbr = "Vu";  BgColor = "#007BFC"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Render"        = @{ Abbr = "Rn";  BgColor = "#46E3B7"; FgColor = "#000000"; Category = "Cloud" }
    "Railway"       = @{ Abbr = "Rw";  BgColor = "#0B0D0E"; FgColor = "#FFFFFF"; Category = "Cloud" }
    "Fly"           = @{ Abbr = "Fly"; BgColor = "#7C3AED"; FgColor = "#FFFFFF"; Category = "Cloud" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # VERSIONSKONTROLLE & BUILD TOOLS
    # ═══════════════════════════════════════════════════════════════════════
    
    "Git"           = @{ Abbr = "G";   BgColor = "#F05032"; FgColor = "#FFFFFF"; Category = "VCS" }
    "SVN"           = @{ Abbr = "SVN"; BgColor = "#809CC9"; FgColor = "#FFFFFF"; Category = "VCS" }
    "Subversion"    = @{ Abbr = "SVN"; BgColor = "#809CC9"; FgColor = "#FFFFFF"; Category = "VCS" }
    "Mercurial"     = @{ Abbr = "Hg";  BgColor = "#999999"; FgColor = "#FFFFFF"; Category = "VCS" }
    "Webpack"       = @{ Abbr = "Wp";  BgColor = "#8DD6F9"; FgColor = "#000000"; Category = "Build" }
    "Vite"          = @{ Abbr = "Vi";  BgColor = "#646CFF"; FgColor = "#FFFFFF"; Category = "Build" }
    "Rollup"        = @{ Abbr = "Ru";  BgColor = "#EC4A3F"; FgColor = "#FFFFFF"; Category = "Build" }
    "Parcel"        = @{ Abbr = "Pa";  BgColor = "#21374B"; FgColor = "#FFFFFF"; Category = "Build" }
    "ESBuild"       = @{ Abbr = "ES";  BgColor = "#FFCF00"; FgColor = "#000000"; Category = "Build" }
    "Turbopack"     = @{ Abbr = "Tb";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Build" }
    "Turborepo"     = @{ Abbr = "Tr";  BgColor = "#EF4444"; FgColor = "#FFFFFF"; Category = "Build" }
    "Lerna"         = @{ Abbr = "Le";  BgColor = "#9333EA"; FgColor = "#FFFFFF"; Category = "Build" }
    "Nx"            = @{ Abbr = "Nx";  BgColor = "#143055"; FgColor = "#FFFFFF"; Category = "Build" }
    "Gradle"        = @{ Abbr = "Gr";  BgColor = "#02303A"; FgColor = "#FFFFFF"; Category = "Build" }
    "Maven"         = @{ Abbr = "Mv";  BgColor = "#C71A36"; FgColor = "#FFFFFF"; Category = "Build" }
    "Ant"           = @{ Abbr = "Ant"; BgColor = "#A81C7D"; FgColor = "#FFFFFF"; Category = "Build" }
    "Make"          = @{ Abbr = "Mk";  BgColor = "#6D00CC"; FgColor = "#FFFFFF"; Category = "Build" }
    "CMake"         = @{ Abbr = "CM";  BgColor = "#064F8C"; FgColor = "#FFFFFF"; Category = "Build" }
    "Bazel"         = @{ Abbr = "Bz";  BgColor = "#43A047"; FgColor = "#FFFFFF"; Category = "Build" }
    "NPM"           = @{ Abbr = "npm"; BgColor = "#CB3837"; FgColor = "#FFFFFF"; Category = "Package" }
    "Yarn"          = @{ Abbr = "Yn";  BgColor = "#2C8EBB"; FgColor = "#FFFFFF"; Category = "Package" }
    "PNPM"          = @{ Abbr = "pn";  BgColor = "#F69220"; FgColor = "#FFFFFF"; Category = "Package" }
    "Pip"           = @{ Abbr = "pip"; BgColor = "#3776AB"; FgColor = "#FFFFFF"; Category = "Package" }
    "Poetry"        = @{ Abbr = "Po";  BgColor = "#60A5FA"; FgColor = "#000000"; Category = "Package" }
    "Conda"         = @{ Abbr = "Cn";  BgColor = "#44A833"; FgColor = "#FFFFFF"; Category = "Package" }
    "Cargo"         = @{ Abbr = "Cg";  BgColor = "#000000"; FgColor = "#F74C00"; Category = "Package" }
    "Composer"      = @{ Abbr = "Cp";  BgColor = "#885630"; FgColor = "#FFFFFF"; Category = "Package" }
    "NuGet"         = @{ Abbr = "Nu";  BgColor = "#004880"; FgColor = "#FFFFFF"; Category = "Package" }
    "Homebrew"      = @{ Abbr = "Hb";  BgColor = "#FBB040"; FgColor = "#000000"; Category = "Package" }
    "Chocolatey"    = @{ Abbr = "Ch";  BgColor = "#80B5E3"; FgColor = "#000000"; Category = "Package" }
    "Scoop"         = @{ Abbr = "Sc";  BgColor = "#5A5A5A"; FgColor = "#FFFFFF"; Category = "Package" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # TESTING & AI
    # ═══════════════════════════════════════════════════════════════════════
    
    "Jest"          = @{ Abbr = "Je";  BgColor = "#C21325"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Mocha"         = @{ Abbr = "Mo";  BgColor = "#8D6748"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Jasmine"       = @{ Abbr = "Ja";  BgColor = "#8A4182"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Cypress"       = @{ Abbr = "Cy";  BgColor = "#17202C"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Playwright"    = @{ Abbr = "Pw";  BgColor = "#2EAD33"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Puppeteer"     = @{ Abbr = "Pp";  BgColor = "#40B5A4"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Selenium"      = @{ Abbr = "Se";  BgColor = "#43B02A"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Vitest"        = @{ Abbr = "Vt";  BgColor = "#6E9F18"; FgColor = "#FFFFFF"; Category = "Testing" }
    "PyTest"        = @{ Abbr = "Pt";  BgColor = "#0A9EDC"; FgColor = "#FFFFFF"; Category = "Testing" }
    "JUnit"         = @{ Abbr = "JU";  BgColor = "#25A162"; FgColor = "#FFFFFF"; Category = "Testing" }
    "TestNG"        = @{ Abbr = "TN";  BgColor = "#E1261C"; FgColor = "#FFFFFF"; Category = "Testing" }
    "RSpec"         = @{ Abbr = "RS";  BgColor = "#CC342D"; FgColor = "#FFFFFF"; Category = "Testing" }
    "PHPUnit"       = @{ Abbr = "PU";  BgColor = "#3C9CD7"; FgColor = "#FFFFFF"; Category = "Testing" }
    "Storybook"     = @{ Abbr = "Sb";  BgColor = "#FF4785"; FgColor = "#FFFFFF"; Category = "Testing" }
    "TensorFlow"    = @{ Abbr = "TF";  BgColor = "#FF6F00"; FgColor = "#FFFFFF"; Category = "AI" }
    "PyTorch"       = @{ Abbr = "PT";  BgColor = "#EE4C2C"; FgColor = "#FFFFFF"; Category = "AI" }
    "Keras"         = @{ Abbr = "Ke";  BgColor = "#D00000"; FgColor = "#FFFFFF"; Category = "AI" }
    "Scikit"        = @{ Abbr = "Sk";  BgColor = "#F7931E"; FgColor = "#FFFFFF"; Category = "AI" }
    "ScikitLearn"   = @{ Abbr = "Sk";  BgColor = "#F7931E"; FgColor = "#FFFFFF"; Category = "AI" }
    "OpenCV"        = @{ Abbr = "CV";  BgColor = "#5C3EE8"; FgColor = "#FFFFFF"; Category = "AI" }
    "Pandas"        = @{ Abbr = "Pd";  BgColor = "#150458"; FgColor = "#FFFFFF"; Category = "AI" }
    "NumPy"         = @{ Abbr = "Np";  BgColor = "#013243"; FgColor = "#4DABCF"; Category = "AI" }
    "Jupyter"       = @{ Abbr = "Jp";  BgColor = "#F37626"; FgColor = "#FFFFFF"; Category = "AI" }
    "Huggingface"   = @{ Abbr = "HF";  BgColor = "#FFD21E"; FgColor = "#000000"; Category = "AI" }
    "LangChain"     = @{ Abbr = "LC";  BgColor = "#1C3C3C"; FgColor = "#FFFFFF"; Category = "AI" }
    "OpenAI"        = @{ Abbr = "AI";  BgColor = "#412991"; FgColor = "#FFFFFF"; Category = "AI" }
    "Anthropic"     = @{ Abbr = "An";  BgColor = "#D4A27F"; FgColor = "#000000"; Category = "AI" }
    "MLflow"        = @{ Abbr = "ML";  BgColor = "#0194E2"; FgColor = "#FFFFFF"; Category = "AI" }
    "Weights"       = @{ Abbr = "W&B"; BgColor = "#FFBE00"; FgColor = "#000000"; Category = "AI" }
    "CUDA"          = @{ Abbr = "CU";  BgColor = "#76B900"; FgColor = "#FFFFFF"; Category = "AI" }
    "JAX"           = @{ Abbr = "JAX"; BgColor = "#A8DADC"; FgColor = "#000000"; Category = "AI" }
    "Ollama"        = @{ Abbr = "Ol";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "AI" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # DATA, MESSAGING & GAMES
    # ═══════════════════════════════════════════════════════════════════════
    
    "Kafka"         = @{ Abbr = "Kf";  BgColor = "#231F20"; FgColor = "#FFFFFF"; Category = "Data" }
    "RabbitMQ"      = @{ Abbr = "RQ";  BgColor = "#FF6600"; FgColor = "#FFFFFF"; Category = "Data" }
    "GraphQL"       = @{ Abbr = "QL";  BgColor = "#E10098"; FgColor = "#FFFFFF"; Category = "Data" }
    "gRPC"          = @{ Abbr = "gR";  BgColor = "#244C5A"; FgColor = "#FFFFFF"; Category = "Data" }
    "REST"          = @{ Abbr = "RE";  BgColor = "#009688"; FgColor = "#FFFFFF"; Category = "Data" }
    "API"           = @{ Abbr = "API"; BgColor = "#6BA539"; FgColor = "#FFFFFF"; Category = "Data" }
    "WebSocket"     = @{ Abbr = "WS";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Data" }
    "MQTT"          = @{ Abbr = "MQ";  BgColor = "#660066"; FgColor = "#FFFFFF"; Category = "Data" }
    "ZeroMQ"        = @{ Abbr = "ZM";  BgColor = "#DF0000"; FgColor = "#FFFFFF"; Category = "Data" }
    "Protobuf"      = @{ Abbr = "Pb";  BgColor = "#4285F4"; FgColor = "#FFFFFF"; Category = "Data" }
    "Unity"         = @{ Abbr = "U";   BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Game" }
    "Unreal"        = @{ Abbr = "UE";  BgColor = "#0E1128"; FgColor = "#FFFFFF"; Category = "Game" }
    "Godot"         = @{ Abbr = "Go";  BgColor = "#478CBF"; FgColor = "#FFFFFF"; Category = "Game" }
    "Phaser"        = @{ Abbr = "Ph";  BgColor = "#8B00FF"; FgColor = "#FFFFFF"; Category = "Game" }
    "Bevy"          = @{ Abbr = "Bv";  BgColor = "#232326"; FgColor = "#FFFFFF"; Category = "Game" }
    "MonoGame"      = @{ Abbr = "MG";  BgColor = "#E73C00"; FgColor = "#FFFFFF"; Category = "Game" }
    "GameMaker"     = @{ Abbr = "GM";  BgColor = "#8BC24A"; FgColor = "#FFFFFF"; Category = "Game" }
    "Defold"        = @{ Abbr = "Df";  BgColor = "#008FDD"; FgColor = "#FFFFFF"; Category = "Game" }
    "Love2D"        = @{ Abbr = "L2";  BgColor = "#E74A99"; FgColor = "#FFFFFF"; Category = "Game" }
    "Pygame"        = @{ Abbr = "Py";  BgColor = "#30B149"; FgColor = "#FFFFFF"; Category = "Game" }
    
    # ═══════════════════════════════════════════════════════════════════════
    # SHELLS, OS & SONSTIGE
    # ═══════════════════════════════════════════════════════════════════════
    
    "PowerShell"    = @{ Abbr = "PS";  BgColor = "#5391FE"; FgColor = "#FFFFFF"; Category = "Shell" }
    "Bash"          = @{ Abbr = "Sh";  BgColor = "#4EAA25"; FgColor = "#FFFFFF"; Category = "Shell" }
    "Shell"         = @{ Abbr = "Sh";  BgColor = "#89E051"; FgColor = "#000000"; Category = "Shell" }
    "Zsh"           = @{ Abbr = "Zsh"; BgColor = "#F15A24"; FgColor = "#FFFFFF"; Category = "Shell" }
    "Fish"          = @{ Abbr = "Fi";  BgColor = "#4AAE46"; FgColor = "#FFFFFF"; Category = "Shell" }
    "Linux"         = @{ Abbr = "Lx";  BgColor = "#FCC624"; FgColor = "#000000"; Category = "OS" }
    "Ubuntu"        = @{ Abbr = "Ub";  BgColor = "#E95420"; FgColor = "#FFFFFF"; Category = "OS" }
    "Debian"        = @{ Abbr = "Db";  BgColor = "#A81D33"; FgColor = "#FFFFFF"; Category = "OS" }
    "Fedora"        = @{ Abbr = "Fe";  BgColor = "#51A2DA"; FgColor = "#FFFFFF"; Category = "OS" }
    "Arch"          = @{ Abbr = "Ar";  BgColor = "#1793D1"; FgColor = "#FFFFFF"; Category = "OS" }
    "CentOS"        = @{ Abbr = "Ce";  BgColor = "#262577"; FgColor = "#FFFFFF"; Category = "OS" }
    "AlpineLinux"   = @{ Abbr = "Alp"; BgColor = "#0D597F"; FgColor = "#FFFFFF"; Category = "OS" }
    "Windows"       = @{ Abbr = "W";   BgColor = "#0078D4"; FgColor = "#FFFFFF"; Category = "OS" }
    "MacOS"         = @{ Abbr = "Mac"; BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "OS" }
    "Markdown"      = @{ Abbr = "md";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Markup" }
    "HTML"          = @{ Abbr = "H";   BgColor = "#E34F26"; FgColor = "#FFFFFF"; Category = "Markup" }
    "CSS"           = @{ Abbr = "C";   BgColor = "#1572B6"; FgColor = "#FFFFFF"; Category = "Markup" }
    "XML"           = @{ Abbr = "XML"; BgColor = "#0060AC"; FgColor = "#FFFFFF"; Category = "Markup" }
    "JSON"          = @{ Abbr = "{}";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Data" }
    "YAML"          = @{ Abbr = "yml"; BgColor = "#CB171E"; FgColor = "#FFFFFF"; Category = "Data" }
    "TOML"          = @{ Abbr = "Tml"; BgColor = "#9C4221"; FgColor = "#FFFFFF"; Category = "Data" }
    "LaTeX"         = @{ Abbr = "TeX"; BgColor = "#008080"; FgColor = "#FFFFFF"; Category = "Markup" }
    "Regex"         = @{ Abbr = ".*";  BgColor = "#00897B"; FgColor = "#FFFFFF"; Category = "Other" }
    "WebAssembly"   = @{ Abbr = "Wa";  BgColor = "#654FF0"; FgColor = "#FFFFFF"; Category = "Other" }
    "WASM"          = @{ Abbr = "Wa";  BgColor = "#654FF0"; FgColor = "#FFFFFF"; Category = "Other" }
    "Blockchain"    = @{ Abbr = "BC";  BgColor = "#121D33"; FgColor = "#F7931A"; Category = "Other" }
    "Solidity"      = @{ Abbr = "Sol"; BgColor = "#363636"; FgColor = "#FFFFFF"; Category = "Other" }
    "Web3"          = @{ Abbr = "W3";  BgColor = "#F16822"; FgColor = "#FFFFFF"; Category = "Other" }
    "Ethereum"      = @{ Abbr = "ETH"; BgColor = "#3C3C3D"; FgColor = "#FFFFFF"; Category = "Other" }
    "Hardhat"       = @{ Abbr = "Hh";  BgColor = "#FFF100"; FgColor = "#000000"; Category = "Other" }
    "Foundry"       = @{ Abbr = "Fd";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Other" }
    "OpenGL"        = @{ Abbr = "GL";  BgColor = "#5586A4"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "Vulkan"        = @{ Abbr = "Vk";  BgColor = "#AC162C"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "DirectX"       = @{ Abbr = "DX";  BgColor = "#107C10"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "WebGL"         = @{ Abbr = "WG";  BgColor = "#990000"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "ThreeJS"       = @{ Abbr = "3D";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "Processing"    = @{ Abbr = "P5";  BgColor = "#006699"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "Blender"       = @{ Abbr = "Bl";  BgColor = "#E87D0D"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "CAD"           = @{ Abbr = "CAD"; BgColor = "#0696D7"; FgColor = "#FFFFFF"; Category = "Graphics" }
    "Figma"         = @{ Abbr = "Fg";  BgColor = "#F24E1E"; FgColor = "#FFFFFF"; Category = "Design" }
    "Sketch"        = @{ Abbr = "Sk";  BgColor = "#F7B500"; FgColor = "#000000"; Category = "Design" }
    "AdobeXD"       = @{ Abbr = "XD";  BgColor = "#FF61F6"; FgColor = "#000000"; Category = "Design" }
    "Photoshop"     = @{ Abbr = "Ps";  BgColor = "#31A8FF"; FgColor = "#FFFFFF"; Category = "Design" }
    "Illustrator"   = @{ Abbr = "Ai";  BgColor = "#FF9A00"; FgColor = "#FFFFFF"; Category = "Design" }
    "InDesign"      = @{ Abbr = "Id";  BgColor = "#FF3366"; FgColor = "#FFFFFF"; Category = "Design" }
    "AfterEffects"  = @{ Abbr = "Ae";  BgColor = "#9999FF"; FgColor = "#000000"; Category = "Design" }
    "Premiere"      = @{ Abbr = "Pr";  BgColor = "#9999FF"; FgColor = "#000000"; Category = "Design" }
    
    # --- IDEs & Tools ---
    "VSCode"        = @{ Abbr = "VS";  BgColor = "#007ACC"; FgColor = "#FFFFFF"; Category = "IDE" }
    "IntelliJ"      = @{ Abbr = "IJ";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "IDE" }
    "PyCharm"       = @{ Abbr = "PC";  BgColor = "#21D789"; FgColor = "#000000"; Category = "IDE" }
    "WebStorm"      = @{ Abbr = "WS";  BgColor = "#00CDD7"; FgColor = "#000000"; Category = "IDE" }
    "Rider"         = @{ Abbr = "Ri";  BgColor = "#DD1265"; FgColor = "#FFFFFF"; Category = "IDE" }
    "CLion"         = @{ Abbr = "CL";  BgColor = "#21D789"; FgColor = "#000000"; Category = "IDE" }
    "GoLand"        = @{ Abbr = "GL";  BgColor = "#00ACC1"; FgColor = "#000000"; Category = "IDE" }
    "RubyMine"      = @{ Abbr = "RM";  BgColor = "#E31B5F"; FgColor = "#FFFFFF"; Category = "IDE" }
    "DataGrip"      = @{ Abbr = "DG";  BgColor = "#22D88F"; FgColor = "#000000"; Category = "IDE" }
    "Eclipse"       = @{ Abbr = "Ec";  BgColor = "#2C2255"; FgColor = "#FFFFFF"; Category = "IDE" }
    "NetBeans"      = @{ Abbr = "NB";  BgColor = "#1B6AC6"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Xcode"         = @{ Abbr = "Xc";  BgColor = "#147EFB"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Vim"           = @{ Abbr = "Vi";  BgColor = "#019733"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Neovim"        = @{ Abbr = "Nv";  BgColor = "#57A143"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Emacs"         = @{ Abbr = "Em";  BgColor = "#7F5AB6"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Atom"          = @{ Abbr = "At";  BgColor = "#66595C"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Sublime"       = @{ Abbr = "Su";  BgColor = "#FF9800"; FgColor = "#000000"; Category = "IDE" }
    "Notepad++"     = @{ Abbr = "N+";  BgColor = "#90E59A"; FgColor = "#000000"; Category = "IDE" }
    "Cursor"        = @{ Abbr = "Cu";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "IDE" }
    "Windsurf"      = @{ Abbr = "Wf";  BgColor = "#0F172A"; FgColor = "#38BDF8"; Category = "IDE" }
    "Postman"       = @{ Abbr = "Pm";  BgColor = "#FF6C37"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Insomnia"      = @{ Abbr = "In";  BgColor = "#4000BF"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Bruno"         = @{ Abbr = "Br";  BgColor = "#F4B13E"; FgColor = "#000000"; Category = "Tool" }
    "Slack"         = @{ Abbr = "Sl";  BgColor = "#4A154B"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Discord"       = @{ Abbr = "Dc";  BgColor = "#5865F2"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Teams"         = @{ Abbr = "Ms";  BgColor = "#6264A7"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Zoom"          = @{ Abbr = "Zm";  BgColor = "#2D8CFF"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Notion"        = @{ Abbr = "No";  BgColor = "#000000"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Obsidian"      = @{ Abbr = "Ob";  BgColor = "#7C3AED"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Jira"          = @{ Abbr = "Ji";  BgColor = "#0052CC"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Confluence"    = @{ Abbr = "Cf";  BgColor = "#172B4D"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Trello"        = @{ Abbr = "Tr";  BgColor = "#0079BF"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Asana"         = @{ Abbr = "As";  BgColor = "#F06A6A"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Linear"        = @{ Abbr = "Ln";  BgColor = "#5E6AD2"; FgColor = "#FFFFFF"; Category = "Tool" }
    "Miro"          = @{ Abbr = "Mr";  BgColor = "#FFD02F"; FgColor = "#000000"; Category = "Tool" }
    "Arduino"       = @{ Abbr = "Ar";  BgColor = "#00979D"; FgColor = "#FFFFFF"; Category = "IoT" }
    "RaspberryPi"   = @{ Abbr = "Pi";  BgColor = "#A22846"; FgColor = "#FFFFFF"; Category = "IoT" }
    "ESP32"         = @{ Abbr = "ESP"; BgColor = "#E7352C"; FgColor = "#FFFFFF"; Category = "IoT" }
    "HomeAssistant" = @{ Abbr = "HA";  BgColor = "#18BCF2"; FgColor = "#FFFFFF"; Category = "IoT" }
    "Scratch"       = @{ Abbr = "Sc";  BgColor = "#4D97FF"; FgColor = "#FFFFFF"; Category = "Education" }
    
    # --- Generische Ordner ---
    "Sandbox"       = @{ Abbr = "SB";  BgColor = "#FF5722"; FgColor = "#FFFFFF"; Category = "Other" }
    "Temp"          = @{ Abbr = "~";   BgColor = "#9E9E9E"; FgColor = "#FFFFFF"; Category = "Other" }
    "Test"          = @{ Abbr = "T";   BgColor = "#4CAF50"; FgColor = "#FFFFFF"; Category = "Other" }
    "Demo"          = @{ Abbr = "D";   BgColor = "#2196F3"; FgColor = "#FFFFFF"; Category = "Other" }
    "Archive"       = @{ Abbr = "AR";  BgColor = "#795548"; FgColor = "#FFFFFF"; Category = "Other" }
    "Backup"        = @{ Abbr = "BK";  BgColor = "#607D8B"; FgColor = "#FFFFFF"; Category = "Other" }
    "Config"        = @{ Abbr = "Cf";  BgColor = "#455A64"; FgColor = "#FFFFFF"; Category = "Other" }
    "Docs"          = @{ Abbr = "Dc";  BgColor = "#4285F4"; FgColor = "#FFFFFF"; Category = "Other" }
    "Examples"      = @{ Abbr = "Ex";  BgColor = "#00BCD4"; FgColor = "#FFFFFF"; Category = "Other" }
    "Libraries"     = @{ Abbr = "Lib"; BgColor = "#673AB7"; FgColor = "#FFFFFF"; Category = "Other" }
    "Packages"      = @{ Abbr = "Pkg"; BgColor = "#009688"; FgColor = "#FFFFFF"; Category = "Other" }
    "Projects"      = @{ Abbr = "Prj"; BgColor = "#3F51B5"; FgColor = "#FFFFFF"; Category = "Other" }
    "Scripts"       = @{ Abbr = "Scr"; BgColor = "#8BC34A"; FgColor = "#000000"; Category = "Other" }
    "Tools"         = @{ Abbr = "Tls"; BgColor = "#FF9800"; FgColor = "#000000"; Category = "Other" }
    "Utils"         = @{ Abbr = "Utl"; BgColor = "#CDDC39"; FgColor = "#000000"; Category = "Other" }
    "Vendor"        = @{ Abbr = "Vnd"; BgColor = "#9C27B0"; FgColor = "#FFFFFF"; Category = "Other" }
    "Work"          = @{ Abbr = "W";   BgColor = "#FF5722"; FgColor = "#FFFFFF"; Category = "Other" }
}

# Benutzerdefinierte Technologien (werden zur Laufzeit hinzugefügt)
$script:CustomTechDefinitions = @{}

#endregion

#region ==================== PRIVATE HILFSFUNKTIONEN ====================

function Get-SvgTemplate {
    param(
        [string]$Abbreviation,
        [string]$BackgroundColor,
        [string]$ForegroundColor,
        [int]$Size = 256
    )
    
    $padding = [math]::Round($Size * 0.04)
    $rectSize = $Size - (2 * $padding)
    $cornerRadius = [math]::Round($rectSize * 0.18)
    $fontSize = switch ($Abbreviation.Length) {
        1 { [math]::Round($rectSize * 0.65) }
        2 { [math]::Round($rectSize * 0.50) }
        default { [math]::Round($rectSize * 0.38) }
    }
    
    return @"
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $Size $Size" width="$Size" height="$Size">
  <rect x="$padding" y="$padding" width="$rectSize" height="$rectSize" rx="$cornerRadius" ry="$cornerRadius" fill="$BackgroundColor"/>
  <text x="50%" y="50%" dominant-baseline="central" text-anchor="middle" font-family="Segoe UI, SF Pro Display, -apple-system, sans-serif" font-weight="700" font-size="${fontSize}px" fill="$ForegroundColor">$([System.Web.HttpUtility]::HtmlEncode($Abbreviation))</text>
</svg>
"@
}

function Convert-SvgToIco {
    param(
        [string]$SvgPath,
        [string]$IcoPath,
        [string]$InkscapePath,
        [int]$Size = 256
    )
    
    $pngPath = [System.IO.Path]::ChangeExtension($SvgPath, ".png")
    
    try {
        # SVG zu PNG via Inkscape
        $inkscapeArgs = @(
            "--export-filename=`"$pngPath`"",
            "--export-width=$Size",
            "--export-height=$Size",
            "`"$SvgPath`""
        )
        
        $process = Start-Process -FilePath $InkscapePath -ArgumentList $inkscapeArgs -Wait -NoNewWindow -PassThru
        
        if (-not (Test-Path $pngPath)) {
            return $false
        }
        
        # PNG zu ICO
        Add-Type -AssemblyName System.Drawing
        
        $sizes = @(256, 128, 64, 48, 32, 16) | Where-Object { $_ -le $Size }
        $originalBitmap = [System.Drawing.Bitmap]::FromFile($pngPath)
        
        $icons = foreach ($iconSize in $sizes) {
            $resized = New-Object System.Drawing.Bitmap($iconSize, $iconSize)
            $graphics = [System.Drawing.Graphics]::FromImage($resized)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($originalBitmap, 0, 0, $iconSize, $iconSize)
            $graphics.Dispose()
            $resized
        }
        
        # ICO-Datei erstellen
        $ms = New-Object System.IO.MemoryStream
        $bw = New-Object System.IO.BinaryWriter($ms)
        
        # ICO Header
        $bw.Write([int16]0)           # Reserved
        $bw.Write([int16]1)           # Type (1 = ICO)
        $bw.Write([int16]$icons.Count)
        
        $imageDataOffset = 6 + (16 * $icons.Count)
        $imageDataList = @()
        
        foreach ($icon in $icons) {
            $iconMs = New-Object System.IO.MemoryStream
            $icon.Save($iconMs, [System.Drawing.Imaging.ImageFormat]::Png)
            $imageData = $iconMs.ToArray()
            $iconMs.Dispose()
            
            $w = if ($icon.Width -ge 256) { 0 } else { $icon.Width }
            $h = if ($icon.Height -ge 256) { 0 } else { $icon.Height }
            
            $bw.Write([byte]$w)
            $bw.Write([byte]$h)
            $bw.Write([byte]0)
            $bw.Write([byte]0)
            $bw.Write([int16]1)
            $bw.Write([int16]32)
            $bw.Write([int32]$imageData.Length)
            $bw.Write([int32]$imageDataOffset)
            
            $imageDataOffset += $imageData.Length
            $imageDataList += ,$imageData
        }
        
        foreach ($imageData in $imageDataList) {
            $bw.Write($imageData)
        }
        
        $bw.Flush()
        [System.IO.File]::WriteAllBytes($IcoPath, $ms.ToArray())
        
        $bw.Dispose()
        $ms.Dispose()
        $originalBitmap.Dispose()
        foreach ($ico in $icons) { $ico.Dispose() }
        
        return $true
    }
    catch {
        Write-Warning "ICO-Konvertierung fehlgeschlagen: $_"
        return $false
    }
    finally {
        if (Test-Path $pngPath) {
            Remove-Item $pngPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-TechDefinition {
    param([string]$FolderName)
    
    # Erst in benutzerdefinierten Definitionen suchen
    foreach ($key in $script:CustomTechDefinitions.Keys) {
        if ($key -ieq $FolderName) {
            return @{ Name = $key; Definition = $script:CustomTechDefinitions[$key] }
        }
    }
    
    # Dann in Standard-Definitionen
    foreach ($key in $script:TechDefinitions.Keys) {
        if ($key -ieq $FolderName) {
            return @{ Name = $key; Definition = $script:TechDefinitions[$key] }
        }
    }
    
    # Partial Match
    foreach ($key in $script:TechDefinitions.Keys) {
        if ($FolderName -ilike "*$key*") {
            return @{ Name = $key; Definition = $script:TechDefinitions[$key] }
        }
    }
    
    return $null
}

function New-DynamicTechDefinition {
    param([string]$FolderName)
    
    $consonants = ($FolderName -replace '[aeiouAEIOU]', '')
    $abbr = if ($FolderName.Length -le 3) {
        $FolderName.ToUpper()
    } elseif ($consonants.Length -ge 2) {
        $consonants.Substring(0, [Math]::Min(3, $consonants.Length)).ToUpper()
    } else {
        $FolderName.Substring(0, [Math]::Min(3, $FolderName.Length)).ToUpper()
    }
    
    $hash = [System.Math]::Abs($FolderName.GetHashCode())
    $hue = $hash % 360
    $s = 0.65
    $l = 0.45
    
    $c = (1 - [Math]::Abs(2 * $l - 1)) * $s
    $x = $c * (1 - [Math]::Abs(($hue / 60) % 2 - 1))
    $m = $l - $c / 2
    
    $r1 = 0; $g1 = 0; $b1 = 0
    
    switch ([Math]::Floor($hue / 60)) {
        0 { $r1 = $c; $g1 = $x; $b1 = 0 }
        1 { $r1 = $x; $g1 = $c; $b1 = 0 }
        2 { $r1 = 0; $g1 = $c; $b1 = $x }
        3 { $r1 = 0; $g1 = $x; $b1 = $c }
        4 { $r1 = $x; $g1 = 0; $b1 = $c }
        5 { $r1 = $c; $g1 = 0; $b1 = $x }
        default { $r1 = $c; $g1 = 0; $b1 = $x }
    }
    
    $r = [Math]::Max(0, [Math]::Min(255, [int](($r1 + $m) * 255)))
    $g = [Math]::Max(0, [Math]::Min(255, [int](($g1 + $m) * 255)))
    $b = [Math]::Max(0, [Math]::Min(255, [int](($b1 + $m) * 255)))
    
    $bgColor = "#{0:X2}{1:X2}{2:X2}" -f $r, $g, $b
    $luminance = (0.299 * $r + 0.587 * $g + 0.114 * $b) / 255
    $fgColor = if ($luminance -gt 0.5) { "#000000" } else { "#FFFFFF" }
    
    return @{
        Abbr = $abbr
        BgColor = $bgColor
        FgColor = $fgColor
        Category = "Auto"
    }
}

#endregion

#region ==================== ÖFFENTLICHE FUNKTIONEN ====================

function Set-FolderIcon {
    <#
    .SYNOPSIS
        Wendet ein Icon auf einen Ordner an via desktop.ini.
    
    .PARAMETER FolderPath
        Pfad zum Zielordner.
    
    .PARAMETER IconPath
        Pfad zur ICO-Datei.
    
    .PARAMETER Force
        Überschreibt existierende desktop.ini.
    
    .EXAMPLE
        Set-FolderIcon -FolderPath "C:\Dev\Java" -IconPath "C:\Dev\Java\Java.ico"
    #>
    [CmdletBinding()]
    [Alias('sfi')]
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
    
    $desktopIniPath = Join-Path $FolderPath "desktop.ini"
    
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
        
        $iniContent = @"
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

function Remove-FolderIcon {
    <#
    .SYNOPSIS
        Entfernt ein benutzerdefiniertes Icon von einem Ordner.
    
    .PARAMETER FolderPath
        Pfad zum Ordner.
    
    .PARAMETER RemoveIconFile
        Entfernt auch die versteckte ICO-Datei.
    
    .EXAMPLE
        Remove-FolderIcon -FolderPath "C:\Dev\Java" -RemoveIconFile
    #>
    [CmdletBinding()]
    [Alias('rfi')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$FolderPath,
        
        [switch]$RemoveIconFile
    )
    
    $desktopIniPath = Join-Path $FolderPath "desktop.ini"
    
    try {
        if (Test-Path $desktopIniPath) {
            $file = Get-Item $desktopIniPath -Force
            $file.Attributes = 'Normal'
            Remove-Item $desktopIniPath -Force
        }
        
        if ($RemoveIconFile) {
            $folderName = Split-Path $FolderPath -Leaf
            $icoPath = Join-Path $FolderPath "$folderName.ico"
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

function Update-ExplorerIconCache {
    <#
    .SYNOPSIS
        Aktualisiert den Windows Explorer Icon-Cache.
    #>
    [CmdletBinding()]
    param()
    
    try {
        $ie4uinit = "$env:SystemRoot\System32\ie4uinit.exe"
        if (Test-Path $ie4uinit) {
            Start-Process -FilePath $ie4uinit -ArgumentList "-show" -Wait -NoNewWindow -ErrorAction SilentlyContinue
        }
        
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ShellNotify {
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
    public const int SHCNE_ASSOCCHANGED = 0x08000000;
    public const uint SHCNF_IDLIST = 0x0000;
    public static void RefreshIcons() {
        SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, IntPtr.Zero, IntPtr.Zero);
    }
}
"@ -ErrorAction SilentlyContinue
        
        [ShellNotify]::RefreshIcons()
        return $true
    }
    catch {
        Write-Verbose "Icon-Cache-Aktualisierung fehlgeschlagen: $_"
        return $false
    }
}

function Get-TechDefinitions {
    <#
    .SYNOPSIS
        Zeigt verfügbare Technologie-Definitionen an.
    
    .PARAMETER Category
        Filtert nach Kategorie.
    
    .PARAMETER Name
        Sucht nach Namen (Wildcard erlaubt).
    
    .EXAMPLE
        Get-TechDefinitions -Category Language
        
    .EXAMPLE
        Get-TechDefinitions -Name "*React*"
    #>
    [CmdletBinding()]
    [Alias('gtd')]
    param(
        [string]$Category,
        [string]$Name
    )
    
    $allDefs = $script:TechDefinitions + $script:CustomTechDefinitions
    
    $results = foreach ($key in $allDefs.Keys | Sort-Object) {
        $def = $allDefs[$key]
        
        if ($Category -and $def.Category -ne $Category) { continue }
        if ($Name -and $key -notlike $Name) { continue }
        
        [PSCustomObject]@{
            Name = $key
            Abbr = $def.Abbr
            BgColor = $def.BgColor
            FgColor = $def.FgColor
            Category = $def.Category
            Custom = $script:CustomTechDefinitions.ContainsKey($key)
        }
    }
    
    return $results
}

function Add-TechDefinition {
    <#
    .SYNOPSIS
        Fügt eine benutzerdefinierte Technologie-Definition hinzu.
    
    .EXAMPLE
        Add-TechDefinition -Name "MyTech" -Abbr "MT" -BgColor "#FF0000" -FgColor "#FFFFFF" -Category "Custom"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [ValidateLength(1, 3)]
        [string]$Abbr,
        
        [Parameter(Mandatory)]
        [ValidatePattern('^#[0-9A-Fa-f]{6}$')]
        [string]$BgColor,
        
        [string]$FgColor = "#FFFFFF",
        
        [string]$Category = "Custom"
    )
    
    $script:CustomTechDefinitions[$Name] = @{
        Abbr = $Abbr
        BgColor = $BgColor
        FgColor = $FgColor
        Category = $Category
    }
    
    Write-Host "✅ Technologie '$Name' hinzugefügt." -ForegroundColor Green
}

function New-FolderIcon {
    <#
    .SYNOPSIS
        Erstellt ein einzelnes Icon für einen Ordner.
    
    .PARAMETER FolderPath
        Pfad zum Ordner.
    
    .PARAMETER Apply
        Wendet das Icon direkt an.
    
    .EXAMPLE
        New-FolderIcon -FolderPath "C:\Dev\MyProject" -Apply
    #>
    [CmdletBinding()]
    [Alias('nfi')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$FolderPath,
        
        [string]$InkscapePath,
        
        [switch]$Apply,

        [switch]$ApplyExistingIco,
        
        [switch]$Force
    )
    
    if (-not (Test-Path $FolderPath -PathType Container)) {
        Write-Error "Ordner existiert nicht: $FolderPath"
        return
    }
    
    # Inkscape finden
    $inkscapeExe = if ($InkscapePath -and (Test-Path $InkscapePath)) {
        $InkscapePath
    } else {
        $script:DefaultInkscapePaths
    }
    
    if (-not $inkscapeExe) {
        $folderName = Split-Path $FolderPath -Leaf
        $icoPath = Join-Path $FolderPath "$folderName.ico"
        if ($ApplyExistingIco -and (Test-Path $icoPath)) {
            if ($Apply) {
                $applied = Set-FolderIcon -FolderPath $FolderPath -IconPath $icoPath -Force
                if ($applied) {
                    Write-Host "✅ Vorhandenes Icon angewendet: $icoPath" -ForegroundColor Green
                    Update-ExplorerIconCache | Out-Null
                }
            }
            else {
                Write-Host "ℹ️  Vorhandenes Icon gefunden: $icoPath" -ForegroundColor Yellow
            }
            return
        }
        Write-Error "Inkscape nicht gefunden. Bitte installieren, -InkscapePath angeben oder -ApplyExistingIco nutzen."
        return
    }
    
    $folderName = Split-Path $FolderPath -Leaf
    $icoPath = Join-Path $FolderPath "$folderName.ico"
    
    if ((Test-Path $icoPath) -and -not $Force) {
        Write-Warning "Icon existiert bereits: $icoPath (nutze -Force zum Überschreiben)"
        return
    }
    
    if ((Test-Path $icoPath) -and $Force) {
        $existing = Get-Item $icoPath -Force
        $existing.Attributes = 'Normal'
    }
    
    $techMatch = Get-TechDefinition -FolderName $folderName
    $definition = if ($techMatch) { $techMatch.Definition } else { New-DynamicTechDefinition -FolderName $folderName }
    
    $tempDir = Join-Path $env:TEMP "FolderIcon_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    $svgPath = Join-Path $tempDir "$folderName.svg"
    $svgContent = Get-SvgTemplate -Abbreviation $definition.Abbr -BackgroundColor $definition.BgColor -ForegroundColor $definition.FgColor
    $svgContent | Out-File -FilePath $svgPath -Encoding UTF8 -Force
    
    $success = Convert-SvgToIco -SvgPath $svgPath -IcoPath $icoPath -InkscapePath $inkscapeExe
    
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    if ($success) {
        Write-Host "✅ Icon erstellt: $icoPath" -ForegroundColor Green
        
        if ($Apply) {
            $applied = Set-FolderIcon -FolderPath $FolderPath -IconPath $icoPath -Force
            if ($applied) {
                Write-Host "✅ Icon angewendet auf: $FolderPath" -ForegroundColor Green
                Update-ExplorerIconCache | Out-Null
            }
        }
    }
    else {
        Write-Error "Icon-Erstellung fehlgeschlagen."
    }
}

function Set-DevFolderIcons {
    <#
    .SYNOPSIS
        Generiert und wendet Icons für alle Unterordner eines Entwicklungsverzeichnisses an.
    
    .DESCRIPTION
        Scannt einen Basisordner nach Unterordnern und erstellt für jeden
        erkannten Technologie-Ordner eine passende ICO-Datei.
        
        Mit -ApplyToFolders werden die Icons professionell eingerichtet:
        - ICO-Datei wird im jeweiligen Unterordner erstellt
        - ICO-Datei erhält Hidden + System Attribute
        - desktop.ini wird erstellt mit Hidden + System Attributen
        - Ordner erhält System-Attribut
    
    .PARAMETER BasePath
        Der Basispfad mit den Entwicklungsordnern.
    
    .PARAMETER OutputPath
        Ausgabepfad für Icons (nur ohne -ApplyToFolders).
    
    .PARAMETER InkscapePath
        Pfad zur Inkscape-Executable.
    
    .PARAMETER IconSize
        Größe der Icons (16-256).
    
    .PARAMETER Force
        Überschreibt existierende Dateien.
    
    .PARAMETER ApplyToFolders
        Wendet Icons direkt auf Ordner an.
    
    .EXAMPLE
        Set-DevFolderIcons -BasePath "C:\Dev" -ApplyToFolders
        
    .EXAMPLE
        sfdi -BasePath "D:\Projects" -ini -Force
    #>
    [CmdletBinding()]
    [Alias('sfdi')]
    param(
        [Parameter(Position = 0)]
        [string]$BasePath = "C:\Users\$env:USERNAME\Development",
        
        [string]$OutputPath,
        
        [string]$InkscapePath,
        
        [ValidateSet(16, 32, 48, 64, 128, 256)]
        [int]$IconSize = 256,
        
        [switch]$Force,

        [Alias("ini")]
        [switch]$ApplyToFolders,

        [switch]$ApplyExistingIco
    )
    
    # Validierung
    if (-not (Test-Path $BasePath -PathType Container)) {
        Write-Error "Basispfad existiert nicht: $BasePath"
        return
    }
    
    if (-not $OutputPath) { $OutputPath = $BasePath }
    
    # Inkscape finden
    $inkscapeExe = if ($InkscapePath -and (Test-Path $InkscapePath)) {
        $InkscapePath
    } else {
        $script:DefaultInkscapePaths
    }
    
    if (-not $inkscapeExe) {
        if (-not $ApplyExistingIco) {
            Write-Error @"
Inkscape nicht gefunden!

Installation:
  - Download: https://inkscape.org/release/
  - Oder: choco install inkscape
  - Oder: winget install Inkscape.Inkscape

Nach Installation erneut ausführen oder -InkscapePath angeben.
"@
            return
        }
    }
    
    # Banner
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     🎨 Development Folder Icon Generator                     ║" -ForegroundColor Cyan
    Write-Host "║     SetFoldersICO Module v1.2.0                              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📁 Basispfad:  " -ForegroundColor Yellow -NoNewline
    Write-Host $BasePath
    Write-Host "📂 Ausgabe:    " -ForegroundColor Yellow -NoNewline
    if ($ApplyToFolders) {
        Write-Host "In jeweiligem Unterordner (versteckt)" -ForegroundColor Cyan
    } else {
        Write-Host $OutputPath
    }
    Write-Host "🖌️  Inkscape:   " -ForegroundColor Yellow -NoNewline
    if ($inkscapeExe) { Write-Host $inkscapeExe } else { Write-Host "nicht vorhanden (ApplyExistingIco)" -ForegroundColor Yellow }
    Write-Host "📐 Icongröße:  " -ForegroundColor Yellow -NoNewline
    Write-Host "${IconSize}px"
    Write-Host "📋 desktop.ini:" -ForegroundColor Yellow -NoNewline
    if ($ApplyToFolders) {
        Write-Host " Ja (Icons + INI versteckt, Ordner mit System-Attribut)" -ForegroundColor Green
    } else {
        Write-Host " Nein (nur ICO-Dateien im Ausgabeordner)" -ForegroundColor Gray
    }
    Write-Host ""
    
    $folders = Get-ChildItem -Path $BasePath -Directory | Sort-Object Name
    
    if ($folders.Count -eq 0) {
        Write-Warning "Keine Unterordner in $BasePath gefunden."
        return
    }
    
    Write-Host "🔍 Gefundene Ordner: " -ForegroundColor Cyan -NoNewline
    Write-Host $folders.Count
    Write-Host ""
    Write-Host ("─" * 65) -ForegroundColor DarkGray
    
    $tempDir = Join-Path $env:TEMP "DevFolderIcons_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    $successCount = 0
    $skipCount = 0
    $errorCount = 0
    
    foreach ($folder in $folders) {
        $folderName = $folder.Name
        
        if ($ApplyToFolders) {
            $icoPath = Join-Path $folder.FullName "$folderName.ico"
        } else {
            $icoPath = Join-Path $OutputPath "$folderName.ico"
        }
        
        if ((Test-Path $icoPath) -and -not $Force) {
            Write-Host "⏭️  " -ForegroundColor DarkGray -NoNewline
            Write-Host $folderName.PadRight(25) -ForegroundColor DarkGray -NoNewline
            Write-Host "bereits vorhanden" -ForegroundColor DarkGray
            $skipCount++
            continue
        }
        
        if ((Test-Path $icoPath) -and $Force) {
            $existingIco = Get-Item $icoPath -Force
            $existingIco.Attributes = 'Normal'
        }
        
        $techMatch = Get-TechDefinition -FolderName $folderName
        
        if ($techMatch) {
            $definition = $techMatch.Definition
            $matchType = "✓"
            $matchColor = "Green"
        }
        else {
            $definition = New-DynamicTechDefinition -FolderName $folderName
            $matchType = "~"
            $matchColor = "Yellow"
        }
        
        $success = $false
        if ($inkscapeExe) {
            $svgContent = Get-SvgTemplate -Abbreviation $definition.Abbr `
                                           -BackgroundColor $definition.BgColor `
                                           -ForegroundColor $definition.FgColor `
                                           -Size $IconSize
            
            $svgPath = Join-Path $tempDir "$folderName.svg"
            $svgContent | Out-File -FilePath $svgPath -Encoding UTF8 -Force
            
            $success = Convert-SvgToIco -SvgPath $svgPath `
                                         -IcoPath $icoPath `
                                         -InkscapePath $inkscapeExe `
                                         -Size $IconSize
        }
        elseif ($ApplyExistingIco -and (Test-Path $icoPath)) {
            $success = $true
        }
        
        if ($success) {
            Write-Host "$matchType  " -ForegroundColor $matchColor -NoNewline
            Write-Host $folderName.PadRight(25) -NoNewline
            Write-Host "[" -NoNewline -ForegroundColor DarkGray
            Write-Host $definition.Abbr.PadRight(3) -NoNewline -ForegroundColor White
            Write-Host "] " -NoNewline -ForegroundColor DarkGray
            Write-Host "█ " -NoNewline -ForegroundColor DarkGray
            Write-Host $definition.BgColor -NoNewline -ForegroundColor Cyan
            
            $iniApplied = $false
            if ($ApplyToFolders) {
                $iniApplied = Set-FolderIcon -FolderPath $folder.FullName -IconPath $icoPath -Force
                if ($iniApplied) {
                    Write-Host " → " -NoNewline -ForegroundColor DarkGray
                    Write-Host "✓ ini" -NoNewline -ForegroundColor Green
                }
            }
            
            Write-Host " → " -NoNewline -ForegroundColor DarkGray
            Write-Host $definition.Category -ForegroundColor DarkCyan
            
            $successCount++
        }
        else {
            Write-Host "❌  " -ForegroundColor Red -NoNewline
            Write-Host $folderName.PadRight(25) -NoNewline
            Write-Host "Konvertierung fehlgeschlagen" -ForegroundColor Red
            $errorCount++
        }
    }
    
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    if ($ApplyToFolders -and $successCount -gt 0) {
        Write-Host ""
        Write-Host "🔄 Aktualisiere Windows Icon-Cache..." -ForegroundColor Cyan
        $cacheRefreshed = Update-ExplorerIconCache
        if ($cacheRefreshed) {
            Write-Host "   ✅ Icon-Cache aktualisiert" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Cache erfordert ggf. Explorer-Neustart" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host ("─" * 65) -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "📊 Zusammenfassung:" -ForegroundColor Cyan
    Write-Host "   ✅ Erfolgreich:  " -NoNewline
    Write-Host $successCount -ForegroundColor Green
    Write-Host "   ⏭️  Übersprungen: " -NoNewline
    Write-Host $skipCount -ForegroundColor Yellow
    Write-Host "   ❌ Fehler:       " -NoNewline
    Write-Host $errorCount -ForegroundColor Red
    Write-Host ""
    
    if ($successCount -gt 0 -and $ApplyToFolders) {
        Write-Host "💡 " -ForegroundColor Yellow -NoNewline
        Write-Host "Struktur: " -ForegroundColor White
        Write-Host "   📁 Ordner        → System-Attribut" -ForegroundColor Gray
        Write-Host "   📄 desktop.ini   → Hidden + System" -ForegroundColor Gray
        Write-Host "   🎨 [Name].ico    → Hidden + System" -ForegroundColor Gray
        Write-Host ""
    }
}

#endregion

#region ==================== MODUL-INITIALISIERUNG ====================

# System.Web für HTML-Encoding laden
Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue

# Export-Aliase werden im Manifest definiert, hier nur für IntelliSense
Set-Alias -Name sfdi -Value Set-DevFolderIcons -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name sfi -Value Set-FolderIcon -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name rfi -Value Remove-FolderIcon -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name gtd -Value Get-TechDefinitions -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name nfi -Value New-FolderIcon -Scope Global -ErrorAction SilentlyContinue

#endregion
