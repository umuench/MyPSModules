function Test-DomainDns {
    <#
    .SYNOPSIS
        Prueft NS- und A-Records einer Domain gegen erwartete Werte.
    .DESCRIPTION
        Fuehrt DNS-Abfragen fuer NS- und A-Records durch und vergleicht die Ergebnisse
        optional mit erwarteten Nameservern und A-Record-Adressen.
        Gibt einen Statuscode zurueck: 0=OK, 1=PENDING, 2=BROKEN, 3=ERROR.
        Unterstuetzt alternative DNS-Resolver (Google, Cloudflare) und automatische Wiederholungen.
    .PARAMETER Domain
        Die zu pruefende Domain (z.B. example.com).
    .PARAMETER ExpectedNameservers
        Optionale Liste erwarteter Nameserver. Fehlt ein Eintrag, wird BROKEN gemeldet.
    .PARAMETER ExpectedARecord
        Optionaler erwarteter A-Record. Stimmt er nicht, wird BROKEN gemeldet.
    .PARAMETER Resolver
        DNS-Resolver: System (Standard), Google (8.8.8.8) oder Cloudflare (1.1.1.1).
    .PARAMETER RetryCount
        Anzahl der Wiederholungsversuche bei DNS-Fehlern. Standard: 0.
    .PARAMETER RetryDelayMs
        Wartezeit in Millisekunden zwischen Wiederholungen. Standard: 500.
    .PARAMETER NoEmoji
        Unterdrückt Emoji-Ausgabe in der Konsolenausgabe.
    .PARAMETER AsJson
        Gibt das Ergebnis als JSON-String aus.
    .PARAMETER OutputObject
        Gibt das Ergebnis als PSCustomObject zurueck statt der Konsolenausgabe.
    .PARAMETER Quiet
        Keine Konsolenausgabe; gibt nur den Statuscode zurueck.
    .EXAMPLE
        Test-DomainDns -Domain 'example.com'
        Prueft die Domain mit dem System-Resolver und gibt den Status in der Konsole aus.
    .EXAMPLE
        Test-DomainDns -Domain 'example.com' -ExpectedNameservers 'ns1.host.de','ns2.host.de' -Resolver Google
        Prueft NS-Records gegen erwartete Werte via Google DNS.
    .EXAMPLE
        $result = Test-DomainDns -Domain 'example.com' -OutputObject -Quiet
        Gibt das Ergebnis-Objekt zurueck ohne Konsolenausgabe.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Domain,

        [string[]]$ExpectedNameservers,
        [string]$ExpectedARecord,

        [ValidateSet('System', 'Google', 'Cloudflare')]
        [string]$Resolver = 'System',

        [int]$RetryCount    = 0,
        [int]$RetryDelayMs  = 500,

        [switch]$NoEmoji,
        [switch]$AsJson,
        [switch]$OutputObject,
        [switch]$Quiet
    )

    $DnsServer = switch ($Resolver) {
        'Google'     { '8.8.8.8' }
        'Cloudflare' { '1.1.1.1' }
        default      { $null }
    }

    $state   = 'ERROR'
    $code    = 3
    $emoji   = 'WARN'
    $foundNS = @()
    $foundA  = $null
    $nsOk    = $false
    $aOk     = $false

    $dnsParams = @{ ErrorAction = 'Stop' }
    if ($DnsServer) { $dnsParams['Server'] = $DnsServer }

    try {
        $attempts = 0
        do {
            $attempts++
            try {
                $nsQuery = Resolve-DnsName -Name $Domain -Type NS @dnsParams
                $aQuery  = Resolve-DnsName -Name $Domain -Type A  @dnsParams
                break
            }
            catch {
                if ($attempts -le $RetryCount) {
                    Start-Sleep -Milliseconds $RetryDelayMs
                }
                else {
                    throw
                }
            }
        } while ($attempts -le $RetryCount)

        $nsAnswers = $nsQuery | Where-Object Section -eq 'Answer'
        $aAnswers  = $aQuery  | Where-Object Section -eq 'Answer'

        if ($nsAnswers) {
            $foundNS = $nsAnswers |
                Select-Object -ExpandProperty NameHost |
                ForEach-Object { $_.TrimEnd('.') }
        }

        if ($aAnswers) {
            $foundA = $aAnswers |
                Select-Object -ExpandProperty IPAddress |
                Where-Object { $_ -notmatch '^127\.' } |
                Select-Object -First 1
        }

        $nsOk = if ($ExpectedNameservers) {
            ($ExpectedNameservers | Where-Object { $foundNS -notcontains $_ }).Count -eq 0
        } else { $true }

        $aOk = if ($ExpectedARecord) {
            $foundA -eq $ExpectedARecord
        } else { $true }

        if ($nsOk -and $aOk) {
            $state = 'OK';      $code = 0; $emoji = 'OK '
        }
        elseif (-not $foundNS -and -not $foundA) {
            $state = 'PENDING'; $code = 1; $emoji = '...'
        }
        else {
            $state = 'BROKEN';  $code = 2; $emoji = 'ERR'
        }
    }
    catch {
        # state bleibt ERROR / code 3
    }

    if ($NoEmoji) { $emoji = '' }

    $result = [PSCustomObject]@{
        State        = $state
        StatusSymbol = $emoji
        Domain       = $Domain
        Resolver     = $Resolver
        NameserverOK = $nsOk
        ARecordOK    = $aOk
        FoundNS      = $foundNS
        FoundA       = $foundA
        Timestamp    = Get-Date
    }

    if (-not $Quiet) {
        if ($AsJson) {
            $result | ConvertTo-Json -Depth 3
        }
        elseif ($OutputObject) {
            $result
        }
        else {
            Write-Host "$emoji  $Domain  [$state]"
        }
    }

    return $code
}