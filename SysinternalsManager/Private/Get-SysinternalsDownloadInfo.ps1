function Get-SysinternalsDownloadInfo {
    <#
    .SYNOPSIS
        Ermittelt Metadaten der aktuellen Sysinternals Suite vom Microsoft-Server.
    .DESCRIPTION
        Sendet einen HTTP-HEAD-Request an den Sysinternals-Download-Endpunkt und
        liest Last-Modified und Content-Length aus den Response-Headern.
        Unterstuetzt optionale Proxy-Konfiguration.
    .PARAMETER Proxy
        Optionale Proxy-URL (z.B. 'http://proxy.example.com:8080').
    .EXAMPLE
        $info = Get-SysinternalsDownloadInfo
        Write-Host $info.LastModified
    #>
    param(
        [string]$Proxy
    )

    $url = 'https://download.sysinternals.com/files/SysinternalsSuite.zip'

    try {
        $reqParams = @{ Uri = $url; Method = 'Head'; UseBasicParsing = $true }
        if ($Proxy) { $reqParams['Proxy'] = $Proxy }

        $response = Invoke-WebRequest @reqParams

        $lastModified = $response.Headers['Last-Modified']
        if ($lastModified -is [array]) { $lastModified = $lastModified[0] }

        $contentLength = $response.Headers['Content-Length']
        if ($contentLength -is [array]) { $contentLength = $contentLength[0] }

        return @{
            Url           = $url
            LastModified  = [DateTime]$lastModified
            ContentLength = [int64]$contentLength
        }
    }
    catch {
        throw "Fehler beim Abrufen der Download-Informationen: $_"
    }
}
