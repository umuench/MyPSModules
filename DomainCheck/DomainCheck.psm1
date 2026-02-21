function Test-DomainDns {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Domain,

        [string[]]$ExpectedNameservers,
        [string]$ExpectedARecord,

        [ValidateSet("System","Google","Cloudflare")]
        [string]$Resolver = "System",

        [int]$RetryCount = 0,
        [int]$RetryDelayMs = 500,

        [switch]$NoEmoji,
        [switch]$AsJson,
        [switch]$OutputObject,
        [switch]$Quiet
    )

    # -------------------------------
    # Resolver
    # -------------------------------
    switch ($Resolver) {
        "Google"     { $DnsServer = "8.8.8.8" }
        "Cloudflare" { $DnsServer = "1.1.1.1" }
        default      { $DnsServer = $null }
    }

    # -------------------------------
    # Default State (falls Fehler)
    # -------------------------------
    $state = "ERROR"
    $code  = 3
    $emoji = "⚠️"
    $foundNS = @()
    $foundA  = $null
    $nsOk = $false
    $aOk  = $false

    try {
        $attempts = 0
        do {
            $attempts++
            try {
                $nsQuery = Resolve-DnsName -Name $Domain -Type NS -Server $DnsServer -ErrorAction Stop
                $aQuery  = Resolve-DnsName -Name $Domain -Type A  -Server $DnsServer -ErrorAction Stop
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

        $nsOk = $ExpectedNameservers ?
            (($ExpectedNameservers | Where-Object { $foundNS -notcontains $_ }).Count -eq 0)
            : $true

        $aOk = $ExpectedARecord ?
            ($foundA -eq $ExpectedARecord)
            : $true

        if ($nsOk -and $aOk) {
            $state = "OK";      $code = 0; $emoji = "✅"
        }
        elseif (-not $foundNS -and -not $foundA) {
            $state = "PENDING"; $code = 1; $emoji = "⏳"
        }
        else {
            $state = "BROKEN";  $code = 2; $emoji = "❌"
        }
    }
    catch {
        # bleibt bei ERROR / ⚠️
    }

    if ($NoEmoji) { $emoji = "" }

    $result = [PSCustomObject]@{
        State        = $state
        StatusSymbol= $emoji
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
        elseif ($emoji) {
            Write-Host "$emoji  $Domain  [$state]"
        }
        else {
            $result
        }
    }

    return $code
}

Export-ModuleMember -Function Test-DomainDns

Set-Alias -Name tdd -Value Test-DomainDns
Export-ModuleMember -Alias tdd
