function Find-Venvs {
    <#
    .SYNOPSIS
        Durchsucht Verzeichnisse nach vorhandenen .venv-Ordnern.
    .DESCRIPTION
        Gibt fuer jeden gefundenen .venv-Ordner ein Objekt mit Projektpfad und
        Standardpfaden zurueck, das direkt fuer Add-Venv verwendet werden kann.
    .PARAMETER Roots
        Ein oder mehrere Stammverzeichnisse, die rekursiv durchsucht werden.
    .EXAMPLE
        Find-Venvs -Roots 'C:\Projekte'
    .EXAMPLE
        Find-Venvs -Roots 'C:\Projekte','D:\Work' | Add-Venv
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Roots
    )

    foreach ($root in $Roots) {
        Get-ChildItem -Path $root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq '.venv' } |
            ForEach-Object {
                [pscustomobject]@{
                    Name             = Split-Path $_.Parent.FullName -Leaf
                    ProjectPath      = $_.Parent.FullName
                    VenvPath         = $_.FullName
                    RequirementsPath = Join-Path -Path $_.Parent.FullName -ChildPath 'requirements.txt'
                    ConstraintsPath  = Join-Path -Path $_.Parent.FullName -ChildPath 'constraints.txt'
                }
            }
    }
}