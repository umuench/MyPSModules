function Read-CharSet {
    param([string]$Name)

    $path = Join-Path $PSScriptRoot "..\CharSets\$Name.txt"

    if (-not (Test-Path $path)) {
        $charSetDir = Join-Path $PSScriptRoot "..\CharSets"
        $match = Get-ChildItem -Path $charSetDir -Filter *.txt -File -ErrorAction SilentlyContinue |
            Where-Object { $_.BaseName -ieq $Name } |
            Select-Object -First 1
        if ($match) {
            $path = $match.FullName
        }
        else {
            throw "CharSet '$Name' nicht gefunden"
        }
    }

    $chars = (Get-Content $path -Raw) -replace '\s',''

    if ($chars.Length -lt 12) {
        throw "CharSet '$Name' ist unsicher klein"
    }

    return $chars.ToCharArray()
}
