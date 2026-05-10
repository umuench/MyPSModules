function New-EnvDB {
    <#
    .SYNOPSIS
        Erstellt eine neue .env-Datei fuer eine Datenbankverbindung.
    .DESCRIPTION
        Liest Standardwerte aus einer Vorlagendatei (config.env oder .env) im Modulverzeichnis.
        Unterstuetzt Profil-basierte Konfiguration (z.B. REPLICA, STAGING).
        Passwortabfrage erfolgt sicher maskiert, wenn kein Passwort uebergeben wird.
        Unterstuetzt -WhatIf.
    .PARAMETER DatabaseSystem
        Ziel-Datenbanksystem. Erlaubte Werte: MySQL, MariaDB, PostgreSQL, MSSQL.
    .PARAMETER DatabaseName
        Name der Datenbank.
    .PARAMETER User
        Benutzername. Wenn nicht angegeben, wird der Standardwert aus der Vorlage genutzt.
    .PARAMETER Password
        Passwort als Klartext (unsicher). Bevorzuge PasswordSecure.
    .PARAMETER PasswordSecure
        Passwort als SecureString (sicher).
    .PARAMETER FileName
        Zieldateiname. Standard: .env
    .PARAMETER TemplatePath
        Pfad zu einer benutzerdefinierten Vorlagendatei.
    .PARAMETER Profile
        Optionales Instanz-Profil (z.B. REPLICA, STAGING).
    .PARAMETER Force
        Ueberschreibt eine vorhandene Datei ohne Rueckfrage.
    .EXAMPLE
        New-EnvDB -DatabaseSystem MySQL -DatabaseName 'shop'
        Erstellt .env fuer MySQL mit interaktiver Passwortabfrage.
    .EXAMPLE
        New-EnvDB -DatabaseSystem PostgreSQL -DatabaseName 'analytics' -Profile REPLICA -Force
        Erstellt .env fuer das REPLICA-Profil und ueberschreibt eine vorhandene Datei.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('MySQL', 'MariaDB', 'PostgreSQL', 'MSSQL')]
        [string]$DatabaseSystem,

        [Parameter(Mandatory, Position = 1)]
        [string]$DatabaseName,

        [string]$User,

        [string]$Password,

        [System.Security.SecureString]$PasswordSecure,

        [string]$FileName = ".env",

        [string]$TemplatePath,

        [string]$Profile,

        [switch]$Force
    )

    # 1. Zielpfad pruefen
    $targetPath = Join-Path -Path (Get-Location).Path -ChildPath $FileName
    if ((Test-Path $targetPath) -and -not $Force) {
        Write-Error "Datei '$targetPath' existiert bereits. Nutze -Force zum Ueberschreiben."
        return
    }

    # 2. Vorlage laden
    Import-EnvFile -TemplatePath $TemplatePath
    $Prefix = "DB_$($DatabaseSystem.ToUpper())_"

    # 3. Profil bestimmen (Parameter > System-Profil > Global-Profil)
    $FinalProfile = $null
    if ($Profile) {
        $FinalProfile = $Profile.ToUpper()
    }
    elseif ($script:EnvConfig.ContainsKey("${Prefix}PROFILE")) {
        $FinalProfile = $script:EnvConfig["${Prefix}PROFILE"].ToUpper()
    }
    elseif ($script:EnvConfig.ContainsKey("DB_PROFILE")) {
        $FinalProfile = $script:EnvConfig["DB_PROFILE"].ToUpper()
    }

    # 4. Host & Port aus Vorlage (Profil zuerst, dann Standard)
    $FinalHost = $null
    $FinalPort = $null
    if ($FinalProfile) {
        $FinalHost = $script:EnvConfig["${Prefix}HOST_$FinalProfile"]
        $FinalPort = $script:EnvConfig["${Prefix}PORT_$FinalProfile"]
        if (-not $FinalHost) { $FinalHost = $script:EnvConfig["DB_HOST_$FinalProfile"] }
        if (-not $FinalPort) { $FinalPort = $script:EnvConfig["DB_PORT_$FinalProfile"] }
    }
    if (-not $FinalHost) { $FinalHost = $script:EnvConfig["${Prefix}HOST"] }
    if (-not $FinalPort) { $FinalPort = $script:EnvConfig["${Prefix}PORT"] }
    if (-not $FinalHost) { $FinalHost = "localhost" }
    if (-not $FinalPort) {
        $FinalPort = switch ($DatabaseSystem) {
            "MySQL"      { "3306" }
            "MariaDB"    { "3306" }
            "PostgreSQL" { "5432" }
            "MSSQL"      { "1433" }
            default      { "3306" }
        }
    }

    # 5. Benutzer ermitteln
    $FinalUser = $null
    if ($PSBoundParameters.ContainsKey('User')) {
        $FinalUser = $User
    }
    else {
        if ($FinalProfile -and $script:EnvConfig.ContainsKey("${Prefix}USER_DEFAULT_$FinalProfile")) {
            $FinalUser = $script:EnvConfig["${Prefix}USER_DEFAULT_$FinalProfile"]
        }
        elseif ($FinalProfile -and $script:EnvConfig.ContainsKey("DB_USER_DEFAULT_$FinalProfile")) {
            $FinalUser = $script:EnvConfig["DB_USER_DEFAULT_$FinalProfile"]
        }
        else {
            $key = "${Prefix}USER_DEFAULT"
            $FinalUser = if ($script:EnvConfig.ContainsKey($key)) { $script:EnvConfig[$key] } else { $script:DefaultUser }
        }
    }

    # 6. Passwort ermitteln
    $FinalPass = $null
    if ($PSBoundParameters.ContainsKey('PasswordSecure')) {
        $FinalPass = Convert-SecureStringToString -SecureString $PasswordSecure
    }
    elseif ($PSBoundParameters.ContainsKey('Password')) {
        Write-Verbose "Nutze uebergebenes Klartext-Passwort."
        $FinalPass = $Password
    }
    else {
        $tplPassKey = if ($FinalProfile) {
            "${Prefix}PASS_$($FinalUser.ToUpper())_$FinalProfile"
        } else {
            "${Prefix}PASS_$($FinalUser.ToUpper())"
        }

        if ($script:EnvConfig.ContainsKey($tplPassKey)) {
            Write-Verbose "Passwort fuer '$FinalUser' in Vorlage gefunden."
            $FinalPass = $script:EnvConfig[$tplPassKey]
        }
        elseif ($FinalProfile -and $script:EnvConfig.ContainsKey("DB_PASS_$($FinalUser.ToUpper())_$FinalProfile")) {
            $FinalPass = $script:EnvConfig["DB_PASS_$($FinalUser.ToUpper())_$FinalProfile"]
        }
        elseif ($FinalProfile -and $FinalUser -eq $script:EnvConfig["${Prefix}USER_DEFAULT_$FinalProfile"]) {
            $FinalPass = $script:EnvConfig["${Prefix}PASS_DEFAULT_$FinalProfile"]
        }
        elseif ($FinalProfile -and $FinalUser -eq $script:EnvConfig["DB_USER_DEFAULT_$FinalProfile"]) {
            $FinalPass = $script:EnvConfig["DB_PASS_DEFAULT_$FinalProfile"]
        }
        elseif ($FinalUser -eq $script:EnvConfig["${Prefix}USER_DEFAULT"]) {
            $FinalPass = $script:EnvConfig["${Prefix}PASS_DEFAULT"]
        }
        else {
            Write-Host "Bitte Passwort fuer User '$FinalUser' eingeben (Eingabe ist maskiert): " -ForegroundColor Yellow -NoNewline
            $secureInput = Read-Host -AsSecureString
            $FinalPass   = Convert-SecureStringToString -SecureString $secureInput
        }
    }

    # 7. Werte quoten und Inhalt zusammenstellen
    $content = @(
        "# Generated by New-EnvDB"
        "# System: $DatabaseSystem"
        if ($FinalProfile) { "# Profile: $FinalProfile" }
        ""
        "DB_HOST=$(Quote-EnvValue $FinalHost)"
        "DB_PORT=$(Quote-EnvValue $FinalPort)"
        "DB_USER=$(Quote-EnvValue $FinalUser)"
        "DB_PASS=$(Quote-EnvValue $FinalPass)"
        "DB_NAME=$(Quote-EnvValue $DatabaseName)"
    )

    # 8. Datei schreiben
    if ($PSCmdlet.ShouldProcess($targetPath, "Erstelle .env")) {
        try {
            $content | Out-File -FilePath $targetPath -Encoding utf8 -Force
            Write-Host "OK: '$targetPath' erfolgreich erstellt." -ForegroundColor Green
        }
        catch {
            Write-Error "Fehler beim Schreiben: $($_.Exception.Message)"
        }
    }
}