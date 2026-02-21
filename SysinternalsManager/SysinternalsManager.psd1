@{
    # Modul-Identifikation
    RootModule        = 'SysinternalsManager.psm1'
    ModuleVersion     = '1.1.0'
    GUID              = 'f7e8d9c0-b1a2-4c3d-8e5f-6a7b8c9d0e1f'
    
    # Autor-Informationen
    Author            = 'Uwe'
    CompanyName       = 'Private'
    Copyright         = '(c) 2025. MIT License.'
    Description       = 'Installation, Update und automatische Wartung der Microsoft Sysinternals Suite für Windows 11'
    
    # Anforderungen
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Core')
    
    # Betriebssystem-Anforderung (nur Windows)
    # PowerShell 7+ unterstützt dieses Attribut
    
    # Exportierte Funktionen
    FunctionsToExport = @(
        'Install-SysinternalsSuite',
        'Update-SysinternalsSuite',
        'Register-SysinternalsUpdateTask',
        'Unregister-SysinternalsUpdateTask',
        'Get-SysinternalsStatus'
    )
    
    # Keine Cmdlets, Variablen oder Aliase exportieren
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('ism','usm','rsm','urm','ssm')
    
    # Private Daten / PSGallery Metadaten
    PrivateData = @{
        PSData = @{
            # Tags für die Suche in PSGallery
            Tags         = @(
                'Sysinternals', 
                'Windows', 
                'Windows11',
                'Administration', 
                'Tools',
                'TaskScheduler',
                'Automation'
            )
            
            # Lizenz
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            
            # Projekt-Link (falls vorhanden)
            # ProjectUri = 'https://github.com/username/SysinternalsManager'
            
            # Icon (falls vorhanden)
            # IconUri    = ''
            
            # Release Notes
            ReleaseNotes = @'
## Version 1.1.0 (2026-02)

### Features
- Proxy, cache, and SHA256 verification support
- Task registration forwards proxy/cache options

## Version 1.0.1 (2025-01)

### Bugfix
- Fix: HTTP-Header werden in PowerShell 7 als Array zurückgegeben - jetzt korrekt behandelt

## Version 1.0.0 (2025-01)

### Features
- Install-SysinternalsSuite: Erstinstallation mit konfigurierbarem Pfad und Scope
- Update-SysinternalsSuite: Intelligentes Update mit Versionsprüfung
- Register-SysinternalsUpdateTask: Task Scheduler Integration für Windows 11 25H2
- Unregister-SysinternalsUpdateTask: Task-Entfernung
- Get-SysinternalsStatus: Übersicht über Installation und Task-Status

### Highlights
- User-Level und Machine-Level Installation
- Automatische EULA-Akzeptanz für alle Tools
- Versionsverfolgung via Last-Modified Header
- Umfangreiches Logging für Task Scheduler
- Windows 11 25H2 optimiert
'@
            
            # Mindestversion des PowerShellGet-Moduls
            # RequireLicenseAcceptance = $false
        }
    }
    
    # Hilfe-Info
    HelpInfoURI = ''
}
