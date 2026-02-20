# SetFoldersICO - PowerShell Modul

Generiert und wendet individuelle Ordner-Icons für Entwicklungsprojekte an.  
Unterstützt **280+ Technologien** mit offiziellen Markenfarben.

## 📦 Installation

### Option 1: Automatische Installation (empfohlen)

```powershell
# Modul-Ordner erstellen und Dateien kopieren
$modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\SetFoldersICO"
New-Item -ItemType Directory -Path $modulePath -Force
Copy-Item -Path ".\SetFoldersICO\*" -Destination $modulePath -Recurse
```

### Option 2: Manuelle Installation

1. Kopiere den Ordner `SetFoldersICO` nach:
   ```
   C:\Users\<USERNAME>\Documents\PowerShell\Modules\
   ```

2. Struktur sollte sein:
   ```
   Documents\PowerShell\Modules\SetFoldersICO\
   ├── SetFoldersICO.psd1
   └── SetFoldersICO.psm1
   ```

### Abhängigkeit: Inkscape

Das Modul benötigt Inkscape für die SVG→ICO Konvertierung:

```powershell
# Via Chocolatey
choco install inkscape

# Via Winget
winget install Inkscape.Inkscape

# Oder Download: https://inkscape.org/release/
```

Optional: Pfad per Umgebungsvariable setzen:

```powershell
$env:INKSCAPE_PATH = "C:\Program Files\Inkscape\bin\inkscape.exe"
```

## 🚀 Verwendung

Nach der Installation ist das Modul automatisch verfügbar:

```powershell
# Alle Funktionen anzeigen
Get-Command -Module SetFoldersICO

# Hilfe anzeigen
Get-Help Set-DevFolderIcons -Full
```

### Hauptfunktionen

| Funktion | Alias | Beschreibung |
|----------|-------|--------------|
| `Set-DevFolderIcons` | `sfdi` | Generiert Icons für alle Unterordner |
| `Set-FolderIcon` | `sfi` | Wendet ein Icon auf einen Ordner an |
| `Remove-FolderIcon` | `rfi` | Entfernt ein Ordner-Icon |
| `New-FolderIcon` | `nfi` | Erstellt ein einzelnes Icon |
| `Get-TechDefinitions` | `gtd` | Zeigt verfügbare Technologien |
| `Add-TechDefinition` | - | Fügt benutzerdefinierte Tech hinzu |
| `Update-ExplorerIconCache` | - | Aktualisiert Icon-Cache |

## 📖 Beispiele

### Icons für alle Entwicklungsordner erstellen und anwenden

```powershell
# Standard-Pfad (C:\Users\<USER>\Development)
Set-DevFolderIcons -ApplyToFolders

# Kurzform mit Alias
sfdi -ini

# Eigener Pfad
sfdi -BasePath "D:\Projects" -ApplyToFolders -Force

# Ohne Inkscape: vorhandene ICOs anwenden
sfdi -BasePath "D:\Projects" -ApplyToFolders -ApplyExistingIco
```

### Einzelnes Icon erstellen

```powershell
# Icon für einen Ordner erstellen und anwenden
New-FolderIcon -FolderPath "C:\Dev\MeinProjekt" -Apply

# Kurzform
nfi "C:\Dev\MeinProjekt" -Apply
```

### Verfügbare Technologien anzeigen

```powershell
# Alle anzeigen
Get-TechDefinitions

# Nach Kategorie filtern
Get-TechDefinitions -Category Language
Get-TechDefinitions -Category Frontend
Get-TechDefinitions -Category Database

# Nach Name suchen
Get-TechDefinitions -Name "*React*"
```

### Benutzerdefinierte Technologie hinzufügen

```powershell
Add-TechDefinition -Name "MeineApp" -Abbr "MA" -BgColor "#FF5500" -FgColor "#FFFFFF" -Category "Custom"
```

### Icon entfernen

```powershell
# Nur desktop.ini entfernen
Remove-FolderIcon -FolderPath "C:\Dev\Java"

# desktop.ini UND versteckte ICO-Datei entfernen
Remove-FolderIcon -FolderPath "C:\Dev\Java" -RemoveIconFile
```

## 📁 Resultierende Ordnerstruktur

Bei Verwendung von `-ApplyToFolders`:

```
C:\Users\Student\Development\
├── Java\
│   ├── desktop.ini     ← Hidden + System
│   ├── Java.ico        ← Hidden + System
│   └── [Ordner hat System-Attribut]
├── Python\
│   ├── desktop.ini     ← Hidden + System
│   ├── Python.ico      ← Hidden + System
│   └── [Ordner hat System-Attribut]
└── ...
```

## 🎨 Unterstützte Kategorien

- **Language** (45): Java, Python, JavaScript, TypeScript, C#, Go, Rust, ...
- **Frontend** (25): React, Vue, Angular, Svelte, Astro, ...
- **Backend** (35): Node, Express, Django, FastAPI, Spring, ...
- **Database** (22): MySQL, PostgreSQL, MongoDB, Redis, ...
- **DevOps** (30): Docker, Kubernetes, Terraform, Jenkins, ...
- **Cloud** (14): AWS, Azure, GCP, Vercel, Netlify, ...
- **Testing** (14): Jest, Cypress, Playwright, Selenium, ...
- **AI** (18): TensorFlow, PyTorch, OpenAI, LangChain, ...
- **IDE** (20): VSCode, IntelliJ, Vim, Cursor, ...
- **Tool** (15): Postman, Slack, Notion, Jira, ...
- **... und viele mehr!**

## 🔧 Troubleshooting

### Icons werden nicht angezeigt

```powershell
# Explorer-Cache aktualisieren
Update-ExplorerIconCache

# Oder Explorer neu starten
taskkill /f /im explorer.exe; Start-Process explorer.exe
```

### Modul wird nicht gefunden

```powershell
# Modul-Pfade prüfen
$env:PSModulePath -split ';'

# Modul manuell importieren
Import-Module "$env:USERPROFILE\Documents\PowerShell\Modules\SetFoldersICO"
```

## 📄 Lizenz

MIT License - Frei verwendbar und modifizierbar.

---

**Version:** 1.2.0  
**Autor:** Uwe  
**Erfordert:** PowerShell 5.1+, Inkscape
