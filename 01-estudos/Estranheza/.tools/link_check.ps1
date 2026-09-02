$root = (Get-Location).Path
$mdFiles = Get-ChildItem -Path $root -Recurse -Include *.md -File
$broken = @()
$conceptFiles = @()
$missingStandard = @()

foreach ($file in $mdFiles) {
    $text = Get-Content -Raw -Encoding UTF8 -Path $file.FullName
    $pattern = '\[[^\]]+\]\(([^)]+)\)'
    $matches = [regex]::Matches($text, $pattern)
    foreach ($m in $matches) {
        $target = $m.Groups[1].Value.Trim()
        if ($target -match '^(http://|https://|mailto:|#)') { continue }
        $target = $target.Split('#')[0]
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        $p = Join-Path -Path ($file.DirectoryName) -ChildPath $target
        if (-not (Test-Path $p)) {
            $broken += @{file = (Resolve-Path -Relative $file.FullName); target = $target}
        }
    }
    $rel = (Resolve-Path -Relative $file.FullName)
    if ($rel -match '^(01|02|03|04|05|06|07|08|09)-') { $conceptFiles += $rel }
}

foreach ($rel in $conceptFiles) {
    $full = Join-Path $root $rel
    $text = Get-Content -Raw -Encoding UTF8 -Path $full
    if ($text -notmatch '### Percurso' -or $text -notmatch '### Rastreabilidade') {
        $missingStandard += $rel
    }
}

Write-Output "FILES_CHECKED $($mdFiles.Count)"
Write-Output "BROKEN_RELATIVE_LINKS $($broken.Count)"
foreach ($b in $broken[0..([Math]::Min($broken.Count-1,19))]) {
    Write-Output ("BROKEN {0} -> {1}" -f $b.file, $b.target)
}
Write-Output "MISSING_STANDARD_BLOCKS $($missingStandard.Count)"
foreach ($m in $missingStandard) { Write-Output ("MISSING {0}" -f $m) }

if ($broken.Count -gt 0 -or $missingStandard.Count -gt 0) { exit 2 } else { exit 0 }
