# TaskSchedulerTools

PowerShell module to export and import Windows Task Scheduler branches recursively, including subfolders and task XML definitions.

## English

### Requirements
- Windows with Task Scheduler service
- PowerShell 5.1+ (module targets Desktop and Core)
- Rights to read/write scheduled tasks (run elevated when needed)

### Installation (local module folder)
1. Place `TaskSchedulerTools.psm1` and `TaskSchedulerTools.psd1` in a module folder, for example:
   - `C:\Users\<User>\Documents\PowerShell\Modules\TaskSchedulerTools`
2. Import the module:

```powershell
Import-Module TaskSchedulerTools -Force
```

### Commands
- `Export-TaskBranch`
  - Exports all tasks under a scheduler path recursively.
  - Parameters:
    - `-TaskPath` (default: `\Eigene\`)
    - `-BackupPath` (default: `C:\TaskBackup`)
    - `-NameFilter` (optional wildcard list)
- `Import-TaskBranch`
  - Imports all `.xml` files from a backup folder recursively and recreates folder structure.
  - Parameters:
    - `-SourcePath` (default: `C:\TaskBackup`)
    - `-TaskPath` (default: `\Eigene\`)
    - `-Credential` (optional `PSCredential`)

### Usage Examples

Export one branch:

```powershell
Export-TaskBranch -TaskPath "\\Eigene\\" -BackupPath "D:\\TaskBackup"

Export with name filter:

```powershell
Export-TaskBranch -TaskPath "\\Eigene\\" -BackupPath "D:\\TaskBackup" -NameFilter "Backup*","Sync*"
```
```

Dry-run export (`-WhatIf`):

```powershell
Export-TaskBranch -TaskPath "\\Eigene\\" -BackupPath "D:\\TaskBackup" -WhatIf
```

Import backup into another branch:

```powershell
Import-TaskBranch -SourcePath "D:\\TaskBackup" -TaskPath "\\Imported\\"
```

Dry-run import (`-WhatIf`):

```powershell
Import-TaskBranch -SourcePath "D:\\TaskBackup" -TaskPath "\\Imported\\" -WhatIf
```

Import with explicit credentials:

```powershell
$cred = Get-Credential
Import-TaskBranch -SourcePath "D:\\TaskBackup" -TaskPath "\\Imported\\" -Credential $cred
```

### Notes
- Task names are sanitized for file output when exporting invalid filename characters.
- If a task folder cannot be read, the module logs a warning and continues.
- If no XML files are found during import, the module exits cleanly with a warning.
- Both commands support PowerShell `-WhatIf` for safe preview.

### Troubleshooting
- `0x8007007B` usually means an invalid task folder path (for example malformed `-TaskPath`).
- Access denied: run PowerShell as Administrator.
- Import failures for specific tasks are shown as warnings; check the XML and task principal settings.

---

## Deutsch

### Voraussetzungen
- Windows mit Task Scheduler Dienst
- PowerShell 5.1+ (Modul fuer Desktop und Core)
- Rechte zum Lesen/Schreiben von geplanten Tasks (bei Bedarf als Administrator starten)

### Installation (lokaler Modulordner)
1. Lege `TaskSchedulerTools.psm1` und `TaskSchedulerTools.psd1` in einen Modulordner, z. B.:
   - `C:\Users\<User>\Documents\PowerShell\Modules\TaskSchedulerTools`
2. Modul importieren:

```powershell
Import-Module TaskSchedulerTools -Force
```

### Befehle
- `Export-TaskBranch`
  - Exportiert alle Tasks unter einem Scheduler-Pfad rekursiv.
  - Parameter:
    - `-TaskPath` (Standard: `\Eigene\`)
    - `-BackupPath` (Standard: `C:\TaskBackup`)
    - `-NameFilter` (optional Wildcards)
- `Import-TaskBranch`
  - Importiert alle `.xml`-Dateien aus einem Backup-Ordner rekursiv und erstellt die Ordnerstruktur.
  - Parameter:
    - `-SourcePath` (Standard: `C:\TaskBackup`)
    - `-TaskPath` (Standard: `\Eigene\`)
    - `-Credential` (optional `PSCredential`)

### Beispiele

Branch exportieren:

```powershell
Export-TaskBranch -TaskPath "\\Eigene\\" -BackupPath "D:\\TaskBackup"

Export mit Filter:

```powershell
Export-TaskBranch -TaskPath "\\Eigene\\" -BackupPath "D:\\TaskBackup" -NameFilter "Backup*","Sync*"
```
```

Export als Vorschau (`-WhatIf`):

```powershell
Export-TaskBranch -TaskPath "\\Eigene\\" -BackupPath "D:\\TaskBackup" -WhatIf
```

Backup in anderen Branch importieren:

```powershell
Import-TaskBranch -SourcePath "D:\\TaskBackup" -TaskPath "\\Imported\\"
```

Import als Vorschau (`-WhatIf`):

```powershell
Import-TaskBranch -SourcePath "D:\\TaskBackup" -TaskPath "\\Imported\\" -WhatIf
```

Import mit expliziten Credentials:

```powershell
$cred = Get-Credential
Import-TaskBranch -SourcePath "D:\\TaskBackup" -TaskPath "\\Imported\\" -Credential $cred
```

### Hinweise
- Task-Namen werden beim Export fuer Dateinamen bereinigt, wenn ungueltige Zeichen enthalten sind.
- Wenn ein Task-Ordner nicht gelesen werden kann, wird eine Warnung ausgegeben und der Lauf geht weiter.
- Wenn beim Import keine XML-Dateien gefunden werden, endet der Lauf sauber mit Warnung.
- Beide Befehle unterstuetzen PowerShell `-WhatIf` fuer eine sichere Vorschau.

### Fehlerbehebung
- `0x8007007B` bedeutet meist ein ungueltiger Task-Ordnerpfad (z. B. fehlerhafter `-TaskPath`).
- Bei Zugriffsfehlern PowerShell als Administrator starten.
- Importfehler einzelner Tasks werden als Warnung ausgegeben; XML und Principal-Einstellungen pruefen.
