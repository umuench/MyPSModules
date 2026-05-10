function Convert-SvgToIco {
    <#
    .SYNOPSIS
        Konvertiert eine SVG-Datei in eine mehrstufige ICO-Datei.
    .DESCRIPTION
        Nutzt Inkscape zum Rendern der SVG als PNG, dann System.Drawing zum
        Erstellen einer ICO-Datei mit mehreren Aufloesungen (256, 128, 64, 48, 32, 16 px).
    .PARAMETER SvgPath
        Pfad zur Quell-SVG-Datei.
    .PARAMETER IcoPath
        Zielpfad fuer die erstellte ICO-Datei.
    .PARAMETER InkscapePath
        Pfad zur inkscape.exe.
    .PARAMETER Size
        Maximale Icon-Groesse in Pixeln (Standard: 256).
    .EXAMPLE
        Convert-SvgToIco -SvgPath 'C:\Temp\Python.svg' -IcoPath 'C:\Dev\Python\Python.ico' -InkscapePath 'C:\Program Files\Inkscape\bin\inkscape.exe'
    #>
    param(
        [Parameter(Mandatory)]
        [string]$SvgPath,
        [Parameter(Mandatory)]
        [string]$IcoPath,
        [Parameter(Mandatory)]
        [string]$InkscapePath,
        [int]$Size = 256
    )

    $pngPath = [System.IO.Path]::ChangeExtension($SvgPath, '.png')

    try {
        $inkscapeArgs = @(
            "--export-filename=`"$pngPath`"",
            "--export-width=$Size",
            "--export-height=$Size",
            "`"$SvgPath`""
        )
        Start-Process -FilePath $InkscapePath -ArgumentList $inkscapeArgs -Wait -NoNewWindow -PassThru | Out-Null

        if (-not (Test-Path $pngPath)) {
            return $false
        }

        Add-Type -AssemblyName System.Drawing

        $sizes          = @(256, 128, 64, 48, 32, 16) | Where-Object { $_ -le $Size }
        $originalBitmap = [System.Drawing.Bitmap]::FromFile($pngPath)

        $icons = foreach ($iconSize in $sizes) {
            $resized  = New-Object System.Drawing.Bitmap($iconSize, $iconSize)
            $graphics = [System.Drawing.Graphics]::FromImage($resized)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($originalBitmap, 0, 0, $iconSize, $iconSize)
            $graphics.Dispose()
            $resized
        }

        $ms = New-Object System.IO.MemoryStream
        $bw = New-Object System.IO.BinaryWriter($ms)

        $bw.Write([int16]0)
        $bw.Write([int16]1)
        $bw.Write([int16]$icons.Count)

        $imageDataOffset = 6 + (16 * $icons.Count)
        $imageDataList   = @()

        foreach ($icon in $icons) {
            $iconMs    = New-Object System.IO.MemoryStream
            $icon.Save($iconMs, [System.Drawing.Imaging.ImageFormat]::Png)
            $imageData = $iconMs.ToArray()
            $iconMs.Dispose()

            $w = if ($icon.Width  -ge 256) { 0 } else { $icon.Width }
            $h = if ($icon.Height -ge 256) { 0 } else { $icon.Height }

            $bw.Write([byte]$w)
            $bw.Write([byte]$h)
            $bw.Write([byte]0)
            $bw.Write([byte]0)
            $bw.Write([int16]1)
            $bw.Write([int16]32)
            $bw.Write([int32]$imageData.Length)
            $bw.Write([int32]$imageDataOffset)

            $imageDataOffset += $imageData.Length
            $imageDataList   += ,$imageData
        }

        foreach ($imageData in $imageDataList) {
            $bw.Write($imageData)
        }

        $bw.Flush()
        [System.IO.File]::WriteAllBytes($IcoPath, $ms.ToArray())

        $bw.Dispose()
        $ms.Dispose()
        $originalBitmap.Dispose()
        foreach ($ico in $icons) { $ico.Dispose() }

        return $true
    }
    catch {
        Write-Warning "ICO-Konvertierung fehlgeschlagen: $_"
        return $false
    }
    finally {
        if (Test-Path $pngPath) {
            Remove-Item $pngPath -Force -ErrorAction SilentlyContinue
        }
    }
}
