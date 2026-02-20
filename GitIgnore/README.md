# GitIgnore PowerShell-Modul

Dieses Modul erstellt und aktualisiert `.gitignore`-Dateien aus Vorlagen. Es bietet Auto‑Detection für gängige Projektarten (Node.js, Python, Java), dedupliziert Regeln intelligent und kann vorhandene `.gitignore`-Dateien erweitern.

## Voraussetzungen

- PowerShell 5.1 oder PowerShell (Core) 7+
- Git for Windows installiert
- Vorlagenverzeichnis: `C:\ProgramData\Git\Templates`
  - Pflicht: `.gitignore_base`
  - Optional: `.gitignore_node`, `.gitignore_python`, `.gitignore_java` (und weitere nach gleichem Schema)

## Installation

### 1) Modul lokal installieren (empfohlen)

1. Kopiere den Ordner `GitIgnore` in einen der Pfade in `$env:PSModulePath`, z. B.:

   ```powershell
   $userModules = Join-Path $HOME "Documents\PowerShell\Modules"
   New-Item -ItemType Directory -Force -Path $userModules | Out-Null
   Copy-Item -Recurse -Force -Path ".\GitIgnore" -Destination $userModules
   ```

2. Modul importieren:

   ```powershell
   Import-Module GitIgnore
   ```

3. Optional: Automatischer Import per Profil:

   ```powershell
   Add-Content $PROFILE "`nImport-Module GitIgnore"
   ```

### 2) Modul direkt aus diesem Ordner nutzen

Wenn du dich im Modulordner befindest, kannst du es so laden:

```powershell
Import-Module .\GitIgnore.psd1
```

## Verwendung

## Quick Start

```powershell
# 1) Modul laden
Import-Module GitIgnore

# 2) Im Projektordner eine .gitignore erzeugen (Auto‑Detection)
New-GitIgnore
```

### Grundaufruf (mit Auto‑Detection)

Im Projektverzeichnis:

```powershell
New-GitIgnore
```

Das Modul erkennt die Projektart automatisch anhand typischer Dateien/Ordner und erstellt eine `.gitignore` mit Basis‑Vorlage plus den erkannten Templates.

Zusätzliche Auto‑Detection (falls Templates vorhanden):
- Dotnet, Go, Rust, Php, Ruby, Java_Kotlin, Frontend, Vscode, Jetbrains

### Bestimmte Typen angeben

```powershell
New-GitIgnore -Type Node,Python
```

### Vorhandene `.gitignore` erweitern

```powershell
New-GitIgnore -Type Java -Append
```

## Funktionsweise im Detail

- **Auto‑Detection**: Erkennt Node.js, Python und Java anhand typischer Dateien/Ordner.
- **Deduplizierung**: Doppelte Regeln werden entfernt (Groß-/Kleinschreibung egal).
- **Templates**:
  - Basis: `C:\ProgramData\Git\Templates\.gitignore_base`
  - Zusatz: `C:\ProgramData\Git\Templates\.gitignore_<typ>` (z. B. `node`, `python`, `java`)
- **Ausgabe**: `.gitignore` im aktuellen Arbeitsverzeichnis.
- **Template-Pfad**: Standard `C:\ProgramData\Git\Templates`, optional via `-TemplatePath` oder `GITIGNORE_TEMPLATES`.

## Beispiele

```powershell
# Auto‑Detection und neues .gitignore
New-GitIgnore

# Template-Pfad explizit
New-GitIgnore -TemplatePath "C:\ProgramData\Git\Templates"

# Nur Node.js
New-GitIgnore -Type Node

# Node.js + Python
New-GitIgnore -Type Node,Python

# Erweiterung bestehender .gitignore
New-GitIgnore -Append
```

## Beispielausgabe (Screenshot‑Ersatz)

```text
PS C:\Projects\Demo> New-GitIgnore
No type specified. Attempting auto-detection...
  [i] Auto-detected: Node, Python
Creating/Overwriting .gitignore...
  [+] Processed Base Template
  [+] Processed Node Template
  [+] Processed Python Template
Done! Updated .gitignore at: C:\Projects\Demo\.gitignore
```

## Hinweise & Fehlerbehebung

- **Keine Basis‑Vorlage gefunden**: Stelle sicher, dass `C:\ProgramData\Git\Templates\.gitignore_base` existiert.
- **Template fehlt**: Warnung wird ausgegeben und das Template übersprungen.
- **Append**: Bei `-Append` bleibt bestehender Inhalt erhalten; neue Regeln werden ergänzt und dedupliziert.

## Lizenz

Siehe Modulmanifest (`GitIgnore.psd1`) für Copyright‑Informationen.
