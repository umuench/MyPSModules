# MyPSModules

A curated collection of production-ready PowerShell modules for Windows administration,
developer tooling, and system automation.

All modules are compatible with **PowerShell 5.1** (Windows PowerShell) and
**PowerShell 7+** (Core) and follow a strict `Public/Private` architecture with
full Comment-Based Help on every exported function.

---

## Requirements

| Requirement             | Version      |
|-------------------------|--------------|
| PowerShell              | 5.1 or later |
| Windows                 | 10 / 11      |
| Inkscape *(optional)*   | any — only required by `SetFoldersICO` |

---

## Installation

Clone the repository into your PowerShell module path:

```powershell
git clone git@github.com:umuench/MyPSModules.git `
    "$HOME\Documents\PowerShell\Modules"
```

Verify that all modules are discoverable:

```powershell
Get-Module -ListAvailable
```

Import a specific module:

```powershell
Import-Module WinPwd
```

---

## Modules

| Module | Description | Functions | Aliases |
|---|---|---|---|
| **CodeSigningTools** | Authenticode signing utilities for scripts and modules | `Get-CodeSigningCertificate`, `Set-PowerShellCodeSignature` | `gcsc`, `scs` |
| **ConvertToUtf8** | Converts ANSI text files to UTF-8 (with or without BOM) | `Convert-ToUtf8` | — |
| **DatabaseEnv** | Generates secure `.env` files for MySQL, MariaDB, PostgreSQL, and MSSQL with template support and masked password input | `New-EnvDB` | `nedb` |
| **DirectoryTree** | Renders a hierarchical directory tree with optional JSON export | `Get-DirectoryTree` | `gdt` |
| **DomainCheck** | Validates NS and A records of a domain against expected values; suitable for monitoring and scheduled tasks | `Test-DomainDns` | `tdd` |
| **DualbootSSHKeyStore** | Safely synchronises SSH KeyStore directories between two dual-boot Windows installations | `Sync-SSHKeyStore` | `ssk` |
| **GitIgnore** | Creates and manages `.gitignore` files with auto-detection for Node.js, Python, Java and more; uses templates with intelligent deduplication | `New-GitIgnore` | `ngi` |
| **PythonEnvAdmin** | Manages and automates updates for Python virtual environments including `requirements.txt`, `constraints.txt`, and exclusion lists | `Get-Venv`, `Add-Venv`, `Set-VenvConfig`, `Remove-VenvEntry`, `Enter-Venv`, `Invoke-VenvPython`, `Install-VenvRequirements`, `Export-VenvRequirements`, `Update-VenvPip`, `Update-AllVenvs`, `Test-Venv`, `Find-Venvs` | — |
| **SetFoldersICO** | Generates and applies custom ICO icons for development folders; supports 280+ technologies with official brand colours; requires Inkscape for SVG-to-ICO conversion | `Set-DevFolderIcons`, `Set-FolderIcon`, `Remove-FolderIcon`, `Update-ExplorerIconCache`, `Get-TechDefinitions`, `Add-TechDefinition`, `New-FolderIcon` | `sfdi`, `sfi`, `rfi`, `gtd`, `nfi` |
| **SysinternalsManager** | Installs, updates, and maintains the Microsoft Sysinternals Suite; supports user and machine scope, Task Scheduler integration, and proxy configuration | `Install-SysinternalsSuite`, `Update-SysinternalsSuite`, `Register-SysinternalsUpdateTask`, `Unregister-SysinternalsUpdateTask`, `Get-SysinternalsStatus` | `ism`, `usm`, `rsm`, `urm`, `ssm` |
| **TaskSchedulerTools** | Exports and imports Windows Scheduled Tasks as XML files including recursive folder structure and credential support | `Export-TaskBranch`, `Import-TaskBranch` | `etb`, `itb` |
| **WinPwd** | Cryptographically secure password generator with configurable character sets (CharSets) and indexed output | `Get-WinPwd` | `gwp` |

---

## Repository Structure

Each module follows the same layout:

```
ModuleName/
├── ModuleName.psd1       # Module manifest (explicit FunctionsToExport, no wildcards)
├── ModuleName.psm1       # Root loader (Set-StrictMode, dot-sourcing, alias registration)
├── Public/               # Exported functions (one file per function)
│   └── Verb-Noun.ps1
└── Private/              # Internal helper functions
    └── Helper-Name.ps1
```

### Conventions

- **StrictMode** — `Set-StrictMode -Version Latest` is active in every module
- **Help** — every exported function has full Comment-Based Help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`)
- **Encoding** — all files use UTF-8 with BOM
- **Aliases** — registered with a `ReadOnly`/`Constant` conflict guard; never overwrite system aliases
- **PS 5.1 compatibility** — no ternary operators, no `?.` null-conditional; compatible with Windows PowerShell

---

## Getting Help

```powershell
Get-Help Get-WinPwd -Full
Get-Help New-GitIgnore -Examples
```

---

## Author

**Uwe Markus Münch** — GFN-Retrainee
© 2026 — All rights reserved
