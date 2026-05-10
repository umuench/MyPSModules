function New-TaskFolder {
    <#
    .SYNOPSIS
        Erstellt einen Task-Scheduler-Ordner rekursiv via COM-Schnittstelle.
    .DESCRIPTION
        Verbindet sich mit dem Task-Scheduler-Dienst und legt alle fehlenden
        Unterordner entlang des angegebenen Pfades an. Bereits vorhandene
        Ordner werden uebersprungen.
    .PARAMETER Path
        Vollstaendiger Task-Scheduler-Pfad (z.B. '\Eigene\System\Updates').
    .EXAMPLE
        New-TaskFolder -Path '\Eigene\System\Updates'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()

    $normalizedPath = Format-TaskPath -Path $Path
    if ($normalizedPath -eq '\') { return }

    $parts   = $normalizedPath.Trim('\').Split('\')
    $current = ''

    foreach ($part in $parts) {
        if (-not $part) { continue }

        if ([string]::IsNullOrWhiteSpace($current)) {
            $current = '\' + $part
        } else {
            $current = $current + '\' + $part
        }

        try {
            $service.GetFolder($current) | Out-Null
        }
        catch {
            $parent = Split-Path $current -Parent
            if ([string]::IsNullOrWhiteSpace($parent)) { $parent = '\' }
            $folder = Split-Path $current -Leaf
            $service.GetFolder($parent).CreateFolder($folder) | Out-Null
        }
    }
}
