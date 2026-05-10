function Install-SysinternalsCore {
    <#
    .SYNOPSIS
        Kernlogik fuer Download, Entpacken und Einrichten der Sysinternals Suite.
    .DESCRIPTION
        Laedt die Suite herunter (oder nutzt einen Cache), entpackt das Archiv,
        aktualisiert PATH, akzeptiert die EULA fuer alle Tools via Registry und
        schreibt die Versions-Marker-Datei.
    .PARAMETER Path
        Installationsverzeichnis.
    .PARAMETER Scope
        'User' oder 'Machine' - bestimmt Registry-Root und PATH-Scope.
    .PARAMETER LogPath
        Optionaler Pfad zur Log-Datei.
    .PARAMETER Proxy
        Optionale Proxy-URL.
    .PARAMETER CachePath
        Verzeichnis zum Cachen der heruntergeladenen ZIP-Datei.
    .PARAMETER UseCache
        Verwendet eine vorhandene ZIP im CachePath statt neu herunterzuladen.
    .PARAMETER ExpectedSha256
        Optionaler SHA256-Hash zur Integritaetspruefung der heruntergeladenen Datei.
    .EXAMPLE
        Install-SysinternalsCore -Path 'C:\Tools\SysInternals' -Scope User -LogPath 'C:\Logs\install.log'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateSet('User', 'Machine')]
        [string]$Scope,

        [string]$LogPath,
        [string]$Proxy,
        [string]$CachePath,
        [switch]$UseCache,
        [string]$ExpectedSha256
    )

    $registryRoot = switch ($Scope) {
        'User'    { 'HKCU:\Software\Sysinternals' }
        'Machine' { 'HKLM:\Software\Sysinternals' }
    }

    Write-Log 'Pruefe Download-Quelle...' -LogPath $LogPath
    $downloadInfo = Get-SysinternalsDownloadInfo -Proxy $Proxy

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Log "Verzeichnis erstellt: $Path" -LogPath $LogPath
    }

    $sizeMB = [math]::Round($downloadInfo.ContentLength / 1MB, 1)
    Write-Log "Lade Sysinternals Suite herunter (~$sizeMB MB)..." -LogPath $LogPath

    if ($CachePath) {
        if (-not (Test-Path $CachePath)) {
            New-Item -Path $CachePath -ItemType Directory -Force | Out-Null
        }
        $zipPath = Join-Path $CachePath 'SysinternalsSuite.zip'
    } else {
        $zipPath = Join-Path $env:TEMP "SysinternalsSuite_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    }

    $useCached = $UseCache -and (Test-Path $zipPath)
    if (-not $useCached) {
        $dlParams = @{ Uri = $downloadInfo.Url; OutFile = $zipPath; UseBasicParsing = $true }
        if ($Proxy) { $dlParams['Proxy'] = $Proxy }
        Invoke-WebRequest @dlParams
    } else {
        Write-Log "Nutze Cache: $zipPath" -LogPath $LogPath
    }

    if ($ExpectedSha256) {
        $hash = (Get-FileHash -Path $zipPath -Algorithm SHA256).Hash
        if ($hash -ne $ExpectedSha256) {
            throw "SHA256 stimmt nicht ueberein. Erwartet: $ExpectedSha256, Ist: $hash"
        }
        Write-Log "SHA256 validiert: $hash" -LogPath $LogPath
    }

    Write-Log 'Entpacke Archiv...' -LogPath $LogPath
    Expand-Archive -Path $zipPath -DestinationPath $Path -Force
    if (-not $CachePath) {
        Remove-Item $zipPath -Force
    }

    $tools     = Get-ChildItem $Path -Filter '*.exe'
    $toolCount = $tools.Count

    $currentPath = [Environment]::GetEnvironmentVariable('Path', $Scope)
    if ($currentPath -notlike "*$Path*") {
        [Environment]::SetEnvironmentVariable('Path', "$currentPath;$Path", $Scope)
        Write-Log "PATH aktualisiert ($Scope)" -Level Success -LogPath $LogPath
    } else {
        Write-Log 'PATH bereits konfiguriert' -LogPath $LogPath
    }

    $tools | ForEach-Object {
        $regPath = Join-Path $registryRoot $_.BaseName
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name 'EulaAccepted' -Value 1 -Type DWord
    }
    Write-Log "EULA fuer $toolCount Tools akzeptiert" -Level Success -LogPath $LogPath

    Set-LocalVersionInfo -Path $Path -LastModified $downloadInfo.LastModified -ToolCount $toolCount

    return @{
        Path         = $Path
        ToolCount    = $toolCount
        LastModified = $downloadInfo.LastModified
    }
}
