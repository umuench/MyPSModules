function Export-VenvRequirements {
    <#
    .SYNOPSIS
        Exportiert installierte Pakete eines Venvs als requirements.txt.
    .PARAMETER Name
        Name des Venvs.
    .PARAMETER OutputPath
        Optionaler Ausgabepfad. Standard: requirements.txt im Projektverzeichnis.
    .PARAMETER IncludeEditable
        Schliesst editierbare Installationen (-e) ein.
    .PARAMETER NoSort
        Gibt Pakete unsortiert aus.
    .EXAMPLE
        Export-VenvRequirements -Name 'MyApp'
    .EXAMPLE
        Export-VenvRequirements -Name 'MyApp' -OutputPath 'C:\backup\req.txt' -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$OutputPath,

        [switch]$IncludeEditable,
        [switch]$NoSort
    )

    $venv = Get-Venv -Name $Name | Select-Object -First 1
    if (-not $venv)           { throw "Venv '$Name' nicht gefunden." }
    if (-not $venv.PythonFound) { throw "python.exe nicht gefunden: $($venv.PythonExe)" }

    $targetPath = if ($PSBoundParameters.ContainsKey('OutputPath')) {
        Resolve-ManagedPath -Path $OutputPath -ProjectPath $venv.ProjectPath
    } else {
        $venv.RequirementsPath
    }

    $lines = & $venv.PythonExe -m pip freeze
    if ($LASTEXITCODE -ne 0) { throw "Fehler beim Erzeugen von requirements fuer '$Name'." }

    $resultLines = @($lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if (-not $IncludeEditable) {
        $resultLines = @($resultLines | Where-Object { $_ -notmatch '^-e\s' })
    }
    if (-not $NoSort) {
        $resultLines = @($resultLines | Sort-Object)
    }

    $directory = Split-Path -Path $targetPath -Parent
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($targetPath, 'requirements.txt schreiben')) {
        $resultLines | Set-Content -LiteralPath $targetPath -Encoding UTF8
    }

    [pscustomobject]@{
        Name             = $Name
        OutputPath       = $targetPath
        PackageCount     = $resultLines.Count
        IncludesEditable = [bool]$IncludeEditable
        Sorted           = (-not $NoSort)
    }
}