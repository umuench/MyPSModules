# DirectoryTree PowerShell Modul

Ein PowerShell-Modul zum Erstellen einer hierarchischen Baumstruktur von Verzeichnissen mit optionalem JSON-Export.

## Installation

1. Kopiere den kompletten `DirectoryTree` Ordner nach:
   ```
   C:\Users\Student\Documents\PowerShell\Modules\
   ```

2. Das Modul steht dann automatisch zur Verfügung.

3. Optional: Prüfe die Installation mit:
   ```powershell
   Get-Module -ListAvailable DirectoryTree
   ```

## Verwendung

### Beispiel 1: Baumstruktur in Variable speichern (wie bisher)
```powershell
$tree = Get-DirectoryTree -Path C:\Users\Student\Development\
$tree | ConvertTo-Json -Depth 50 | Out-File "C:\meinVerzeichnis.json"
```

### Beispiel 2: Direkt als JSON exportieren (NEU!)
```powershell
Get-DirectoryTree -Path C:\Users\Student\Development\ -OutPath "C:\meinVerzeichnis.json"
```

### Beispiel 3: Mit benutzerdefinierter Tiefe
```powershell
Get-DirectoryTree -Path C:\Users\Student\Development\ -OutPath "C:\output.json" -Depth 100
```

### Beispiel 4: Nur Objekt zurückgeben
```powershell
$tree = Get-DirectoryTree -Path C:\Projekte
# Weiterverarbeitung der Daten...
```

## Parameter

- **Path** (erforderlich): Der Pfad zum zu analysierenden Verzeichnis
- **OutPath** (optional): Pfad zur JSON-Ausgabedatei
- **Depth** (optional): Tiefe für die JSON-Konvertierung (Standard: 50)

## Ausgabestruktur

Das Modul erstellt eine hierarchische Struktur mit folgenden Eigenschaften:

```json
{
  "Name": "Verzeichnisname",
  "Type": "Directory",
  "LastWriteTime": "2025-12-17T10:30:00",
  "Files": [
    {
      "Name": "datei.txt",
      "Length": 1234,
      "LastWriteTime": "2025-12-17T10:30:00"
    }
  ],
  "Directories": [...]
}
```
