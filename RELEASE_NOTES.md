# Release Notes

## Zusammenfassung
Dieses Release liefert ein vollstaendiges Modul-Handbuch, ein Setup-Skript sowie zahlreiche funktionale Verbesserungen und Best-Practice-Optimierungen in allen Modulen.

## Highlights
- Vollstaendiges Handbuch (`README.md`) + Offline-Export (`README.html`)
- Setup-Skript (`Setup-Modules.ps1`) fuer Templates und Abhaengigkeiten
- Erweiterte GitIgnore-Templates inkl. Auto-Detection
- DatabaseEnv: PostgreSQL/MSSQL + Profile/Instanzen, SecureString, Alias
- Neue Aliase fuer alle Module
- `CHANGELOG.md` und `CHECKLIST.md`

## Wichtige Aenderungen (Auswahl)
- **SysinternalsManager**: Proxy, Cache, SHA256-Check, Task-Weitergabe
- **DomainCheck**: Retry-Parameter, Objekt-Ausgabe
- **DirectoryTree**: Include/Exclude-Filter
- **DualbootSSHKeyStore**: Force/SkipAcl + verbessertes WhatIf
- **WinPwd**: Default-Charset + case-insensitive CharSets
- **GitIgnore**: TemplatePath + env/module Fallback + Auto-Detection erweitert

## Neue Dateien
- `README.html`
- `Setup-Modules.ps1`
- `CHANGELOG.md`
- `CHECKLIST.md`
- `GitIgnore/Templates/*`
- `RELEASE_NOTES.md`

