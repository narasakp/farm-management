# Preview what will be cleaned up
Write-Host "Files that will be REMOVED:" -ForegroundColor Yellow
Write-Host ""

$toRemove = @(
    "*.bat",
    "*.ps1",
    "*.py",
    "*.txt",
    "*.log",
    "backend/",
    "scripts/",
    "docs/",
    "build/",
    ".vscode/",
    ".githooks/",
    ".github/"
)

$totalSize = 0
$fileCount = 0

foreach ($pattern in $toRemove) {
    $items = Get-ChildItem -Path . -Filter $pattern -Recurse -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            $size = (Get-ChildItem -Path $item.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
            Write-Host "[DIR]  $($item.FullName) ($([math]::Round($size/1MB, 2)) MB)" -ForegroundColor Cyan
        } else {
            $size = $item.Length
            Write-Host "[FILE] $($item.FullName) ($([math]::Round($size/1KB, 2)) KB)" -ForegroundColor Gray
        }
        $totalSize += $size
        $fileCount++
    }
}

Write-Host ""
Write-Host "Total: $fileCount items, $([math]::Round($totalSize/1MB, 2)) MB" -ForegroundColor Green
Write-Host ""
Write-Host "These are SAFE to delete (not used in production)" -ForegroundColor Yellow
