function Register-SysinternalsUpdateTask {
    <#
    .SYNOPSIS
        Registriert einen Task-Scheduler-Job fuer automatische Sysinternals-Updates.
    .DESCRIPTION
        Erstellt einen geplanten Task, der regelmaessig auf Updates prueft und diese
        installiert. Der Task importiert das SysinternalsManager-Modul und ruft
        Update-SysinternalsSuite auf. Optimiert fuer Windows 11.
    .PARAMETER Path
        Installationspfad der Sysinternals Suite.
    .PARAMETER Scope
        'User' oder 'Machine'.
    .PARAMETER TaskPath
        Ordnerpfad in der Aufgabenplanung (Standard: '\Eigene\System\').
    .PARAMETER Schedule
        'Daily', 'Weekly' (Standard) oder 'Monthly'.
    .PARAMETER Time
        Ausfuehrungszeit im Format HH:mm (Standard: '03:00').
    .PARAMETER DayOfWeek
        Wochentag fuer Weekly-Schedule (Standard: Sunday).
    .PARAMETER LogPath
        Pfad fuer Log-Dateien (Standard: %LOCALAPPDATA%\SysinternalsManager\update.log).
    .PARAMETER Proxy
        Optionale Proxy-URL fuer den geplanten Task.
    .PARAMETER CachePath
        Optionaler Cache-Pfad fuer den geplanten Task.
    .PARAMETER UseCache
        Aktiviert Cache-Nutzung im geplanten Task.
    .PARAMETER ExpectedSha256
        Optionaler SHA256-Hash fuer den geplanten Task.
    .EXAMPLE
        Register-SysinternalsUpdateTask
    .EXAMPLE
        Register-SysinternalsUpdateTask -TaskPath '\Wartung\Updates\'
    .EXAMPLE
        Register-SysinternalsUpdateTask -Schedule Daily -Time '05:00'
    .EXAMPLE
        Register-SysinternalsUpdateTask -Schedule Weekly -DayOfWeek Monday -Time '06:30'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path,

        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User',

        [string]$TaskPath = '\Eigene\System\',

        [ValidateSet('Daily', 'Weekly', 'Monthly')]
        [string]$Schedule = 'Weekly',

        [ValidatePattern('^\d{2}:\d{2}$')]
        [string]$Time = '03:00',

        [ValidateSet('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
        [string]$DayOfWeek = 'Sunday',

        [string]$LogPath,
        [string]$Proxy,
        [string]$CachePath,
        [switch]$UseCache,
        [string]$ExpectedSha256
    )

    if (-not $TaskPath.StartsWith('\')) { $TaskPath = "\$TaskPath" }
    if (-not $TaskPath.EndsWith('\'))   { $TaskPath = "$TaskPath\" }

    if (-not $Path) {
        $Path = switch ($Scope) {
            'User'    { 'C:\Tools\SysInternals' }
            'Machine' { 'C:\Program Files\SysInternals' }
        }
    }

    if (-not $LogPath) {
        $logDir  = Join-Path $env:LOCALAPPDATA 'SysinternalsManager'
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -Force | Out-Null
        }
        $LogPath = Join-Path $logDir 'update.log'
    }

    if ($Scope -eq 'Machine') {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
                   ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            throw 'Machine-Scope erfordert Administrator-Rechte. Bitte Terminal als Admin starten.'
        }
    }

    $taskName      = "SysinternalsUpdate_$Scope"
    $moduleBasePath = $script:ModuleBase

    $proxyArg     = if ($Proxy)          { " -Proxy '$Proxy'"                   } else { '' }
    $cacheArg     = if ($CachePath)      { " -CachePath '$CachePath'"           } else { '' }
    $useCacheArg  = if ($UseCache)       { ' -UseCache'                         } else { '' }
    $sha256Arg    = if ($ExpectedSha256) { " -ExpectedSha256 '$ExpectedSha256'" } else { '' }

    $command = @"
`$ErrorActionPreference = 'Stop'
try {
    Import-Module '$moduleBasePath\SysinternalsManager.psd1' -Force
    Update-SysinternalsSuite -Path '$Path' -Scope $Scope -LogPath '$LogPath'$proxyArg$cacheArg$useCacheArg$sha256Arg
}
catch {
    `$_ | Out-File -FilePath '$LogPath' -Append
    exit 1
}
"@

    $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))

    $action = New-ScheduledTaskAction `
        -Execute 'pwsh.exe' `
        -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $encodedCommand"

    $trigger = switch ($Schedule) {
        'Daily'   { New-ScheduledTaskTrigger -Daily -At $Time }
        'Weekly'  { New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DayOfWeek -At $Time }
        'Monthly' { New-ScheduledTaskTrigger -Weekly -WeeksInterval 4 -DaysOfWeek $DayOfWeek -At $Time }
    }

    $principal = switch ($Scope) {
        'User'    { New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Limited }
        'Machine' { New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest }
    }

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 30) `
        -MultipleInstances IgnoreNew

    if ($PSCmdlet.ShouldProcess("$TaskPath$taskName", 'Scheduled Task registrieren')) {
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
            Write-Host 'Bestehender Task entfernt' -ForegroundColor Yellow
        }

        Register-ScheduledTask `
            -TaskName    $taskName `
            -TaskPath    $TaskPath `
            -Action      $action `
            -Trigger     $trigger `
            -Principal   $principal `
            -Settings    $settings `
            -Description "Automatisches Update der Sysinternals Suite ($Scope-Level). Erstellt mit SysinternalsManager." `
            -Force | Out-Null

        $scheduleDesc = switch ($Schedule) {
            'Daily'   { "Taeglich um $Time" }
            'Weekly'  { "Woechentlich $DayOfWeek um $Time" }
            'Monthly' { "Monatlich (alle 4 Wochen) $DayOfWeek um $Time" }
        }

        Write-Host ''
        Write-Host '==========================================================' -ForegroundColor Green
        Write-Host ' [OK] Scheduled Task registriert'                           -ForegroundColor Green
        Write-Host '==========================================================' -ForegroundColor Green
        Write-Host "   Name:      $taskName"   -ForegroundColor Gray
        Write-Host "   Ordner:    $TaskPath"   -ForegroundColor Gray
        Write-Host "   Schedule:  $scheduleDesc" -ForegroundColor Gray
        Write-Host "   Scope:     $Scope"      -ForegroundColor Gray
        Write-Host "   Log:       $LogPath"    -ForegroundColor Gray
        Write-Host '==========================================================' -ForegroundColor Green
        Write-Host ''
        Write-Host ' Nuetzliche Befehle:' -ForegroundColor Cyan
        Write-Host "   Get-ScheduledTask -TaskPath '$TaskPath' -TaskName '$taskName' | fl *" -ForegroundColor Gray
        Write-Host "   Start-ScheduledTask -TaskPath '$TaskPath' -TaskName '$taskName'"     -ForegroundColor Gray
        Write-Host ''

        return Get-ScheduledTask -TaskPath $TaskPath -TaskName $taskName
    }
}
