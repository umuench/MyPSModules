<#
.SYNOPSIS
    Erstellt eine neue .env-Datei für Datenbanken (Secure & Standard-Konform).

.DESCRIPTION
    Liest Standardwerte aus einer Master-Vorlage im Modul-Ordner.
    Fragt Passwörter sicher ab, falls sie nicht übergeben wurden oder im Template fehlen.
    Generiert eine 'New' .env-Datei im aktuellen Verzeichnis.

.NOTES
    Autor: Gemini (für umuench)
    Version: 2.0
    - Rename zu New-EnvDB (Standard-Verb).
    - Sicherheits-Feature: Interaktive, maskierte Passwortabfrage (Read-Host -AsSecureString).
#>

# ===================================================================
# ⚙️ MODUL-KONFIGURATION
# ===================================================================
$script:DefaultUser = 'dbuser'
$script:DefaultPass = 'dbpass'
$script:EnvConfig = $null


# ===================================================================
# 🔒 PRIVATE HILFSFUNKTIONEN
# ===================================================================

function Import-EnvFile {
    # (Lädt die Vorlage - Logik unverändert)
    param([string]$TemplatePath)
    if ($script:EnvConfig -ne $null) { return }
    Write-Verbose "Initialisiere Master-Vorlagen-Cache..."
    $script:EnvConfig = @{}
    
    $templatePath = $null
    $envNames = 'config.env', '.env'

    if ($TemplatePath -and (Test-Path -Path $TemplatePath -PathType Leaf)) {
        $templatePath = $TemplatePath
    }
    else {
        foreach ($name in $envNames) {
            $potentialPath = Join-Path -Path $PSScriptRoot -ChildPath $name
            if (Test-Path -Path $potentialPath -PathType Leaf) {
                $templatePath = $potentialPath
                break
            }
        }
    }
    if (-not $templatePath) {
        Write-Warning "Keine Vorlage im Modulverzeichnis ($PSScriptRoot) gefunden."
        return
    }
    try {
        Get-Content -Path $templatePath | ForEach-Object {
            $line = $_.Trim()
            if ($line -and $line -notmatch '^\s*#') {
                $parts = $line.Split('=', 2)
                if ($parts.Count -eq 2) {
                    $key = $parts[0].Trim()
                    $value = $parts[1].Trim() -replace '^["'']' -replace '["'']$'
                    $script:EnvConfig[$key] = $value
                }
            }
        }
    }
    catch { Write-Error "Fehler beim Lesen der Vorlage: $($_.Exception.Message)" }
}

function Quote-EnvValue {
    # (Setzt Anführungszeichen bei Sonderzeichen - Logik unverändert)
    param([string]$Value)
    if ([string]::IsNullOrEmpty($Value)) { return "" }
    if ($Value -match '[ #=$]') {
        $escaped = $Value -replace '"', '\"'
        return """$escaped"""
    }
    return $Value
}

function Convert-SecureStringToString {
    # (Wandelt SecureString zurück in Plaintext für die Datei)
    param([System.Security.SecureString]$SecureString)
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($SecureString)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($ptr)
    }
}


# ===================================================================
# ✅ ÖFFENTLICHE FUNKTION (New-EnvDB)
# ===================================================================

function New-EnvDB {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Ziel-DB-System (MySQL/MariaDB).")]
        [ValidateSet('MySQL', 'MariaDB')]
        [string]$DatabaseSystem,
        
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Name der Datenbank.")]
        [string]$DatabaseName,

        [Parameter(HelpMessage = "Benutzername.")]
        [string]$User,

        [Parameter(HelpMessage = "Passwort (Optional). Wenn leer, wird interaktiv gefragt.")]
        [string]$Password,

        [Parameter(HelpMessage = "Passwort als SecureString (Optional).")]
        [System.Security.SecureString]$PasswordSecure,

        [Parameter(HelpMessage = "Zieldateiname.")]
        [string]$FileName = ".env",

        [Parameter(HelpMessage = "Pfad zur Vorlage (config.env oder .env).")]
        [string]$TemplatePath,

        [Parameter(HelpMessage = "Überschreiben erzwingen.")]
        [switch]$Force
    )

    # 1. Zielpfad prüfen
    $targetPath = Join-Path -Path (Get-Location).Path -ChildPath $FileName
    if ((Test-Path $targetPath) -and -not $Force) {
        Write-Error "Datei '$targetPath' existiert bereits. Nutze -Force zum Überschreiben."
        return
    }

    # 2. Vorlage laden
    Import-EnvFile -TemplatePath $TemplatePath
    $Prefix = "DB_$($DatabaseSystem.ToUpper())_"

    # 3. Host & Port aus Vorlage
    $FinalHost = $script:EnvConfig["${Prefix}HOST"]
    $FinalPort = $script:EnvConfig["${Prefix}PORT"]
    if (-not $FinalHost) { $FinalHost = "localhost" }
    if (-not $FinalPort) { $FinalPort = "3306" }

    # 4. Benutzer & Passwort Logik
    $FinalUser = $null
    $FinalPass = $null

    # A) Benutzer ermitteln
    if ($PSBoundParameters.ContainsKey('User')) {
        $FinalUser = $User
    } else {
        # Default User aus Vorlage
        $key = "${Prefix}USER_DEFAULT"
        $FinalUser = if ($script:EnvConfig.ContainsKey($key)) { $script:EnvConfig[$key] } else { $script:DefaultUser }
    }

    # B) Passwort ermitteln (Hier ist die neue Logik!)
    if ($PSBoundParameters.ContainsKey('PasswordSecure')) {
        $FinalPass = Convert-SecureStringToString -SecureString $PasswordSecure
    }
    elseif ($PSBoundParameters.ContainsKey('Password')) {
        # Fall 1: Passwort wurde als Parameter übergeben (unsicher, aber möglich)
        Write-Verbose "Nutze übergebenes Passwort."
        $FinalPass = $Password
    }
    else {
        # Fall 2: Kein Passwort-Parameter. Prüfe Vorlage für diesen User.
        $tplPassKey = "${Prefix}PASS_$($FinalUser.ToUpper())"
        
        if ($script:EnvConfig.ContainsKey($tplPassKey)) {
            Write-Verbose "Passwort für '$FinalUser' in Vorlage gefunden."
            $FinalPass = $script:EnvConfig[$tplPassKey]
        }
        elseif ($FinalUser -eq $script:EnvConfig["${Prefix}USER_DEFAULT"]) {
            # Es ist der Default User, nimm Default Pass
            $FinalPass = $script:EnvConfig["${Prefix}PASS_DEFAULT"]
        }
        else {
            # Fall 3: Weder Parameter noch Vorlage -> SICHERE EINGABE
            Write-Host "Bitte Passwort für User '$FinalUser' eingeben (Eingabe ist maskiert): " -ForegroundColor Yellow -NoNewline
            $secureInput = Read-Host -AsSecureString
            $FinalPass = Convert-SecureStringToString -SecureString $secureInput
        }
    }

    # 5. Werte quoten (für Sonderzeichen)
    $OutHost = Quote-EnvValue $FinalHost
    $OutPort = Quote-EnvValue $FinalPort
    $OutUser = Quote-EnvValue $FinalUser
    $OutPass = Quote-EnvValue $FinalPass
    $OutName = Quote-EnvValue $DatabaseName

    # 6. Inhalt bauen
    $content = @(
        "# Generated by New-EnvDB",
        "# System: $DatabaseSystem",
        "",
        "DB_HOST=$OutHost",
        "DB_PORT=$OutPort",
        "DB_USER=$OutUser",
        "DB_PASS=$OutPass",
        "DB_NAME=$OutName"
    )

    # 7. Schreiben
    if ($PSCmdlet.ShouldProcess($targetPath, "Erstelle .env")) {
        try {
            $content | Out-File -FilePath $targetPath -Encoding utf8 -Force
            Write-Host "✅ '$targetPath' erfolgreich erstellt." -ForegroundColor Green
        }
        catch { Write-Error "Fehler: $($_.Exception.Message)" }
    }
}

Export-ModuleMember -Function New-EnvDB
