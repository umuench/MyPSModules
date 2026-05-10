# PythonEnvAdmin Pro

## Neuerungen

- `requirements.txt` pro Projekt
- `constraints.txt` pro Projekt
- optionales globales `constraints.global.txt` im Modulordner
- `ExcludePackages` pro Venv in `venvs.json`
- `Update-AllVenvs` bricht bei einem Fehler nicht komplett ab
- `Test-Venv` für Schnellprüfung

## Empfohlene Kommandos

```powershell
Import-Module PythonEnvAdmin -Force
Get-Venv
Test-Venv
```

### Requirements installieren

```powershell
Install-VenvRequirements -Name "LiteLLM"
Install-VenvRequirements -Name "LiteLLM" -UseGlobalConstraints
```

### Requirements exportieren

```powershell
Export-VenvRequirements -Name "LiteLLM"
```

### Paket-Updates

```powershell
Update-VenvPip -Name "DeepMail"
Update-VenvPip -Name "DeepMail" -UpgradeAll
Update-AllVenvs -UpgradeAll
```

### LiteLLM absichern

```powershell
Set-VenvConfig -Name "LiteLLM" -ExcludePackages "pydantic-core"
Update-VenvPip -Name "LiteLLM" -UpgradeAll
```
