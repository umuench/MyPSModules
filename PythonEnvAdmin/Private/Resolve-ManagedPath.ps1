function Resolve-ManagedPath {
    <#
    .SYNOPSIS
        Loest einen relativen oder absoluten Pfad auf, mit optionalem Projektpfad als Basis.
    .DESCRIPTION
        Gibt $null zurueck, wenn $Path leer ist.
        Absolute Pfade werden normalisiert.
        Relative Pfade werden relativ zu $ProjectPath aufgeloest; fehlt dieser,
        wird $script:ModuleBase als Fallback verwendet.
    .PARAMETER Path
        Der aufzuloesende Pfad (relativ oder absolut).
    .PARAMETER ProjectPath
        Optionaler Basispfad fuer relative Pfade.
    #>
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Path,

        [AllowNull()]
        [AllowEmptyString()]
        [string]$ProjectPath
    )

    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    if (-not [string]::IsNullOrWhiteSpace($ProjectPath)) {
        return [System.IO.Path]::GetFullPath((Join-Path -Path $ProjectPath -ChildPath $Path))
    }

    return [System.IO.Path]::GetFullPath((Join-Path -Path $script:ModuleBase -ChildPath $Path))
}