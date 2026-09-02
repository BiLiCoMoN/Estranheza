$files = Get-ChildItem -Path .\00-mapa-de-estudos\overview -Filter *.md -Recurse
foreach ($f in $files) {
    try {
        $text = Get-Content -Raw -Encoding UTF8 $f.FullName
    } catch {
        $text = Get-Content -Raw $f.FullName
    }
    $pattern = 'http[s]?://[^)\s]+'
    $matches = [regex]::Matches($text,$pattern)
    foreach ($m in $matches) {
        Write-Output ("$($f.FullName) -> $($m.Value)")
    }
}
