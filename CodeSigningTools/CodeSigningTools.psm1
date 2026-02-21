# CodeSigningTools.psm1
# Author: Uwe Markus Münch
# Description: Reusable PowerShell utilities for Authenticode code signing

Set-StrictMode -Version Latest

function Get-CodeSigningCertificate {
    [CmdletBinding()]
    param(
        [string]$SubjectMatch = "Uwe Markus Münch - PowerShell Code Signing",
        [string]$Thumbprint
    )

    if ($Thumbprint) {
        $cert = Get-ChildItem Cert:\CurrentUser\My |
            Where-Object { $_.Thumbprint -eq $Thumbprint -and $_.HasPrivateKey } |
            Select-Object -First 1
    }
    else {
        $cert = Get-ChildItem Cert:\CurrentUser\My |
            Where-Object {
                $_.Subject -like "*$SubjectMatch*" -and
                $_.HasPrivateKey
            } |
            Sort-Object NotAfter -Descending |
            Select-Object -First 1
    }

    if (-not $cert) {
        if ($Thumbprint) {
            throw "Kein Code-Signing-Zertifikat mit Thumbprint '$Thumbprint' gefunden."
        }
        throw "Kein Code-Signing-Zertifikat mit Subject '$SubjectMatch' gefunden."
    }

    return $cert
}

function Set-PowerShellCodeSignature {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$SubjectMatch = "Uwe Markus Münch - PowerShell Code Signing",

        [string]$Thumbprint,

        [string]$TimestampServer = "http://timestamp.digicert.com"
    )

    if (-not (Test-Path $Path)) {
        throw "Pfad existiert nicht: $Path"
    }

    $cert = Get-CodeSigningCertificate -SubjectMatch $SubjectMatch -Thumbprint $Thumbprint

    $files = Get-ChildItem $Path -Recurse -File -Include *.ps1, *.psm1

    if (-not $files) {
        Write-Warning "Keine signierbaren Dateien gefunden unter: $Path"
        return
    }

    foreach ($file in $files) {
        if ($PSCmdlet.ShouldProcess($file.FullName, "Set Authenticode Signature")) {

            $result = Set-AuthenticodeSignature `
                -FilePath $file.FullName `
                -Certificate $cert `
                -TimestampServer $TimestampServer

            [PSCustomObject]@{
                File   = $file.FullName
                Status = $result.Status
            }
        }
    }
}

Export-ModuleMember -Function `
    Get-CodeSigningCertificate,
    Set-PowerShellCodeSignature

Set-Alias -Name gcs -Value Get-CodeSigningCertificate
Set-Alias -Name scs -Value Set-PowerShellCodeSignature
Export-ModuleMember -Alias gcs, scs


# SIG # Begin signature block
# MIIfSgYJKoZIhvcNAQcCoIIfOzCCHzcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCN5YOMjxN/UL1D
# vhfiFtteXX6PLUGfkztjxCJM/RX6fKCCGHowggU8MIIDJKADAgECAhAckEskpTwk
# jk6UNrbJXnuMMA0GCSqGSIb3DQEBCwUAMDYxNDAyBgNVBAMMK1V3ZSBNYXJrdXMg
# TcO8bmNoIC0gUG93ZXJTaGVsbCBDb2RlIFNpZ25pbmcwHhcNMjYwMTMwMjE0MDI1
# WhcNMzYwMTMwMjE1MDI1WjA2MTQwMgYDVQQDDCtVd2UgTWFya3VzIE3DvG5jaCAt
# IFBvd2VyU2hlbGwgQ29kZSBTaWduaW5nMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAyTpf9sAXwSDs/whiBzYSHwm5hPX4hvEKr5lkXhl9Z5TEfVIWtRAG
# Eh13ZKHv0nFxMo/zgllHVw/Rv5y9YWxq9F9n2LmIF0mKjJ0n+GgxSW8kvDUbdJ8i
# baKLae7B+B2aPvqh4Q+1WDcjFz6L4uaAEIzBlHvLwPMwSN48kUAuAjNwlABPYsBO
# mNpTMHFZX1lwW4f+0Wk4fI6TsJZml7DDSodHi7++JLk51CTASlmpleyZQ+S7vf2g
# EbrdLgBwO0QWJO79UaaPAaTDM1fyLV3W8xvS7hCY0lDJX0nX7gJ2aFHPAf0o+Rh4
# iXwF3MPNKN+0rxpIS7Fb1feHR/WlWIEWS3LBj5TrRN7KWoiYNLeHNmBEQ3uK0Hf4
# GS0kvRLLB9boTHAX1eGKyUIvBQRShKjBgFzKZqKKQIeAo2DrPwb5hkUk/mVgGcqL
# SUAeqcKI8580JuEjR6Htpoh/RCtd34hRJrhD+mAXArtV0SFzz6ltBWgJqniBimWe
# fuz6/1e9jRNe8kYZr5/i60f2o+4iyK8k2RgM0ThQ9PQlLeHYvAvWStj+PwBoym5B
# fJYf6EJMfCkT8KG7+TEI2qxs1AGFONhGqXaP6HvnJqeU5xuCothZJpNCo33fns6W
# ee/Ue5Buoi8ILVTsqVN4Me2+CO3rc7sQxaFFSvp29T+F/bF/Qub/aCUCAwEAAaNG
# MEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQW
# BBSsEnIWYBcHTDzdhOnTl/xpkyuXNDANBgkqhkiG9w0BAQsFAAOCAgEAsKvvDf2I
# hGdyvjpBXpb8jXfqeLgs/2YN5Pr6EMclZEV1rEVd46B6FCpi6ZMTi8oEh2hpvqvy
# rmjM8/BJPjUwKSb+hBdRFNHAEkUIdLt2JgDxbRMqnf1iULGFwiOPa2oBs+eVQFKY
# /ASz4JOD4X1QNTEB2g2wF+4x2HkTPqNK5Onp3tBLoFc1PKtlc8aJkgKQ6jb8czf+
# IGyT7m64dpmAO+EebyG5CI+R6/0g+K1iL6XdnajJp61iM+2Vc0VQyJOrtCC6Syba
# wDWF9VqBEqOthNfYtxYPrNvRGGXIsE6BuTAjXGDc++ijsJ+KIKlYdA+Y40YqII+j
# MQP1FaOWzUw6M8IxX7+4OPvd29NRAm6Z1eqUexCOTbl2gk0x298jRKvr1B414HJH
# RilcIXyw7+oXL5evBdNTB4L1ommyMA08Pi4uRzy3zlq22vdCzOE25YRm08mSh5z2
# UfSc6ysbyQhn00HnjuPaZZ4bCUz7FHH2xE2A7jdnFxwBzzCq2YaWnHotqPKGNTRQ
# e9SqkmB+rQ3p3a7J6D43TYhO2MjdOzW1KQey3FYjObYD+hqC7BED36sglEWEy6RV
# eLlVuEduT+lREoAkI7L55TWm3vqdgaJ+E+dMKyvf2mGGsj01ATqeykPb+cnzfP9e
# op4/4TiZ/hqjRa9K8bJPJqtzE7HXWAFiNwUwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwgga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIMOkmGMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yNTA1MDcwMDAwMDBaFw0zODAxMTQyMzU5NTlaMGkx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYg
# MjAyNSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0eDHTCphB
# cr48RsAcrHXbo0ZodLRRF51NrY0NlLWZloMsVO1DahGPNRcybEKq+RuwOnPhof6p
# vF4uGjwjqNjfEvUi6wuim5bap+0lgloM2zX4kftn5B1IpYzTqpyFQ/4Bt0mAxAHe
# HYNnQxqXmRinvuNgxVBdJkf77S2uPoCj7GH8BLuxBG5AvftBdsOECS1UkxBvMgEd
# gkFiDNYiOTx4OtiFcMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3mmdglTcaarps0wjU
# jsZvkgFkriK9tUKJm/s80FiocSk1VYLZlDwFt+cVFBURJg6zMUjZa/zbCclF83bR
# VFLeGkuAhHiGPMvSGmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS5xLrfxnGpTXiUOeS
# LsJygoLPp66bkDX1ZlAeSpQl92QOMeRxykvq6gbylsXQskBBBnGy3tW/AMOMCZIV
# NSaz7BX8VtYGqLt9MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqLXvJWnY0v5ydPpOjL
# 6s36czwzsucuoKs7Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7psNOdgJMoiwOrUG2Zd
# SoQbU2rMkpLiQ6bGRinZbI4OLu9BMIFm1UUl9VnePs6BaaeEWvjJSjNm2qA+sdFU
# eEY0qVjPKOWug/G6X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQU729TSunkBnx6yuKQVvYv1Ensy04wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBABfO+xaAHP4HPRF2cTC9vgvItTSmf83Qh8WIGjB/
# T8ObXAZz8OjuhUxjaaFdleMM0lBryPTQM2qEJPe36zwbSI/mS83afsl3YTj+IQhQ
# E7jU/kXjjytJgnn0hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgXf9r5nWMQwr8Myb9r
# EVKChHyfpzee5kH0F8HABBgr0UdqirZ7bowe9Vj2AIMD8liyrukZ2iA/wdG2th9y
# 1IsA0QF8dTXqvcnTmpfeQh35k5zOCPmSNq1UH410ANVko43+Cdmu4y81hjajV/gx
# dEkMx1NKU4uHQcKfZxAvBAKqMVuqte69M9J6A47OvgRaPs+2ykgcGV00TYr2Lr3t
# y9qIijanrUR3anzEwlvzZiiyfTPjLbnFRsjsYg39OlV8cipDoq7+qNNjqFzeGxcy
# tL5TTLL4ZaoBdqbhOhZ3ZRDUphPvSRmMThi0vw9vODRzW6AxnJll38F0cuJG7uEB
# YTptMSbhdhGQDpOXgpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAlZ66RzIg9sC+NJpud
# /v4+7RWsWCiKi9EOLLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1MIDpMPx0LckTetiS
# uEtQvLsNz3Qbp7wGWqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZsq8WhbaM2tszWkPZP
# ubdcMIIG7TCCBNWgAwIBAgIQCoDvGEuN8QWC0cR2p5V0aDANBgkqhkiG9w0BAQsF
# ADBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNV
# BAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hB
# MjU2IDIwMjUgQ0ExMB4XDTI1MDYwNDAwMDAwMFoXDTM2MDkwMzIzNTk1OVowYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBTSEEyNTYgUlNBNDA5NiBUaW1lc3RhbXAgUmVzcG9uZGVyIDIwMjUg
# MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANBGrC0Sxp7Q6q5gVrMr
# V7pvUf+GcAoB38o3zBlCMGMyqJnfFNZx+wvA69HFTBdwbHwBSOeLpvPnZ8ZN+vo8
# dE2/pPvOx/Vj8TchTySA2R4QKpVD7dvNZh6wW2R6kSu9RJt/4QhguSssp3qome7M
# rxVyfQO9sMx6ZAWjFDYOzDi8SOhPUWlLnh00Cll8pjrUcCV3K3E0zz09ldQ//nBZ
# ZREr4h/GI6Dxb2UoyrN0ijtUDVHRXdmncOOMA3CoB/iUSROUINDT98oksouTMYFO
# nHoRh6+86Ltc5zjPKHW5KqCvpSduSwhwUmotuQhcg9tw2YD3w6ySSSu+3qU8DD+n
# igNJFmt6LAHvH3KSuNLoZLc1Hf2JNMVL4Q1OpbybpMe46YceNA0LfNsnqcnpJeIt
# K/DhKbPxTTuGoX7wJNdoRORVbPR1VVnDuSeHVZlc4seAO+6d2sC26/PQPdP51ho1
# zBp+xUIZkpSFA8vWdoUoHLWnqWU3dCCyFG1roSrgHjSHlq8xymLnjCbSLZ49kPmk
# 8iyyizNDIXj//cOgrY7rlRyTlaCCfw7aSUROwnu7zER6EaJ+AliL7ojTdS5PWPsW
# eupWs7NpChUk555K096V1hE0yZIXe+giAwW00aHzrDchIc2bQhpp0IoKRR7YufAk
# prxMiXAJQ1XCmnCfgPf8+3mnAgMBAAGjggGVMIIBkTAMBgNVHRMBAf8EAjAAMB0G
# A1UdDgQWBBTkO/zyMe39/dfzkXFjGVBDz2GM6DAfBgNVHSMEGDAWgBTvb1NK6eQG
# fHrK4pBW9i/USezLTjAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYB
# BQUHAwgwgZUGCCsGAQUFBwEBBIGIMIGFMCQGCCsGAQUFBzABhhhodHRwOi8vb2Nz
# cC5kaWdpY2VydC5jb20wXQYIKwYBBQUHMAKGUWh0dHA6Ly9jYWNlcnRzLmRpZ2lj
# ZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZTSEEy
# NTYyMDI1Q0ExLmNydDBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3RhbXBpbmdSU0E0MDk2U0hB
# MjU2MjAyNUNBMS5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcB
# MA0GCSqGSIb3DQEBCwUAA4ICAQBlKq3xHCcEua5gQezRCESeY0ByIfjk9iJP2zWL
# pQq1b4URGnwWBdEZD9gBq9fNaNmFj6Eh8/YmRDfxT7C0k8FUFqNh+tshgb4O6Lgj
# g8K8elC4+oWCqnU/ML9lFfim8/9yJmZSe2F8AQ/UdKFOtj7YMTmqPO9mzskgiC3Q
# YIUP2S3HQvHG1FDu+WUqW4daIqToXFE/JQ/EABgfZXLWU0ziTN6R3ygQBHMUBaB5
# bdrPbF6MRYs03h4obEMnxYOX8VBRKe1uNnzQVTeLni2nHkX/QqvXnNb+YkDFkxUG
# tMTaiLR9wjxUxu2hECZpqyU1d0IbX6Wq8/gVutDojBIFeRlqAcuEVT0cKsb+zJNE
# suEB7O7/cuvTQasnM9AWcIQfVjnzrvwiCZ85EE8LUkqRhoS3Y50OHgaY7T/lwd6U
# Arb+BOVAkg2oOvol/DJgddJ35XTxfUlQ+8Hggt8l2Yv7roancJIFcbojBcxlRcGG
# 0LIhp6GvReQGgMgYxQbV1S3CrWqZzBt1R9xJgKf47CdxVRd/ndUlQ05oxYy2zRWV
# FjF7mcr4C34Mj3ocCVccAvlKV9jEnstrniLvUxxVZE/rptb7IRE2lskKPIJgbaP5
# t2nGj/ULLi49xTcBZU8atufk+EMF/cWuiC7POGT75qaL6vdCvHlshtjdNXOCIUjs
# arfNZzGCBiYwggYiAgEBMEowNjE0MDIGA1UEAwwrVXdlIE1hcmt1cyBNw7xuY2gg
# LSBQb3dlclNoZWxsIENvZGUgU2lnbmluZwIQHJBLJKU8JI5OlDa2yV57jDANBglg
# hkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3
# DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEV
# MC8GCSqGSIb3DQEJBDEiBCBZ9bUesAEpgP4iXXfDwUNRVYvF2kfFd5H9qZAxDPLn
# rjANBgkqhkiG9w0BAQEFAASCAgCob2N9yYqY6CwGX264qJ1TQC2lDXMfYrXVhoTL
# FAWQ9QC72AZ8m7DJIj8KYiisbUV9GAnqcCBzrunSec6ya+5p2DsGV+iNMR0fCpWr
# NcbOYEF5uNlyJPHRoFTPxtpyqvf3lWsno/wvfaTxRtNqdTO94pHTvAfISGFqB5xY
# jbGrIfkvqcbm3YJc/v3L86WvoLHV40+xf1fIffcaW4PucDaMO0Emcs6afWQAKogh
# rmnDhl7y08PAjvUm6IMd2Exwh6M6HaPeesw7k4fD7YMExYJflHaYbjaRdM9cw2dI
# As40IVKiVfoemm990PrS57x3cXM1saT8nrZaMTBCPiSzHGaTICbhdVhtcjQG6nBZ
# FVUG+z+3ieknQBEA9JHc4MKhrLszmygZcZwd1A+sAu1RnHWuHzeiWoThVmJsI/MS
# v2NDeNv8BCgqGLoTeHKiIWd0ySisn0wTvUGfr+a5rAsHs285Wl/zUN/RVOc67T+M
# r6YAxpXXNpbRU73t/osGWfjIjUkZOzZevITmqiGBfkisNcoFbqQ5kFGi9O3p+meC
# Z3LDonHHKpyh+au38P56ShJRkVrFZMvf0BGg/ap/ognP7gYwwb6ZBjrZjVU5Xnxs
# 02NMnvqjqkES1/wT0lu4sBtapvu/Q+dl0TUCfxCTVY7qEa0QN6DQm8RBcmrJPkUW
# RB5jtKGCAyYwggMiBgkqhkiG9w0BCQYxggMTMIIDDwIBATB9MGkxCzAJBgNVBAYT
# AlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQg
# VHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYgMjAyNSBDQTEC
# EAqA7xhLjfEFgtHEdqeVdGgwDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMx
# CwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNjAxMzAyMjAyMzRaMC8GCSqG
# SIb3DQEJBDEiBCB7ADrcLKT/u3ZZfnvpczoep/o4C59bqD+rB2LjznylJDANBgkq
# hkiG9w0BAQEFAASCAgBfTFOmzjJKrnlot2YMxy5XB8aWcS8wRJITM8A+5skQd3H6
# XWYMdmhPSPQK2PJSdWwkc2sMfIaezEu4ZWxVqFdxohPG66w2bFM17YtVzD1pmuac
# LImi4n+3mFYIxWiUHsN4LNB6BWaB8Zjlfk+yrrb3JgVQ0++TsVzolTz4n4TerYX7
# U2E6oz9wWmQAzk3GQ4wtRm3cc48L/iJoTG35RtzcvLg/Koh+wtbwqV0z0ucGwnJv
# k6jU+121uC3NtXQzvIYp1dVOC3mJOG7902P4gq98xqO1xvDdvUEw9lBfn7yKS98f
# 9opdOOnxA9tBY2fPyMWlu/bmlu0UExcu87ebmBBQDHyxFfiuu3P8zVj/DAawVgF1
# yJNLnQPCBBKACAMXCs5TPo/HJw6MpTjagOQ2PY0/ElWouD5hmr+6hzxUFfDGsXzy
# zkFHJ0+jKp6N8L8ZYBD195F5WiduhIvT4gpWyVLr2XKLbryzaTfSCKl9seZnrkrC
# PMp0z353SNsqHFrPNdoYa7yRXj9SHGh5Fa43A+CfLoGq5Owwx6PcNbtB2x0INl+X
# Vg7pliXZfslFEJBi7CQwfttpFwwbrmlD+8i4xAnXgCpm9YZtCVZw5CN6Zg6hRFZI
# JdAtlcuFLLs47045IcYYC2XIUjPe9uBHIn5GjEbi4grImVhyuU3R+Dz4m3gOyA==
# SIG # End signature block
