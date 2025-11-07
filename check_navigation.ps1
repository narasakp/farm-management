# Navigation Checker Script
# Check which screens use TabController and have Smart Back Navigation

Write-Host "[*] Checking Smart Back Navigation Implementation..." -ForegroundColor Cyan
Write-Host ""

# Find files with TabController
Write-Host "[TAB SCREENS]" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow

$screensWithTabs = Get-ChildItem -Path "lib\screens" -Recurse -Filter "*.dart" | 
    Select-String -Pattern "TabController" | 
    Select-Object -ExpandProperty Path -Unique

$implemented = 0
$total = 0

foreach ($file in $screensWithTabs) {
    $total++
    $relativePath = $file -replace [regex]::Escape($PWD.Path + "\"), ""
    $fileName = Split-Path $relativePath -Leaf
    
    # Check for TabNavigationMixin
    $hasMixin = Select-String -Path $file -Pattern "TabNavigationMixin" -Quiet
    
    # Check for initTabNavigation
    $hasInit = Select-String -Path $file -Pattern "initTabNavigation" -Quiet
    
    # Check for handleSmartBackPress
    $hasHandler = Select-String -Path $file -Pattern "handleSmartBackPress" -Quiet
    
    $status = "[X] Not Implemented"
    $color = "Red"
    
    if ($hasMixin -and $hasInit -and $hasHandler) {
        $status = "[OK] Fully Implemented"
        $color = "Green"
        $implemented++
    } elseif ($hasMixin -or $hasInit) {
        $status = "[!] Partially Implemented"
        $color = "Yellow"
    }
    
    Write-Host "  $fileName" -NoNewline
    Write-Host " $status" -ForegroundColor $color
    Write-Host "    $relativePath" -ForegroundColor Gray
    
    if ($status -ne "[OK] Fully Implemented") {
        if (-not $hasMixin) { Write-Host "      - Missing: with TabNavigationMixin" -ForegroundColor Yellow }
        if (-not $hasInit) { Write-Host "      - Missing: initTabNavigation()" -ForegroundColor Yellow }
        if (-not $hasHandler) { Write-Host "      - Missing: handleSmartBackPress" -ForegroundColor Yellow }
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "[NON-TAB SCREENS]" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow

# Find files without TabController
$allScreens = Get-ChildItem -Path "lib\screens" -Recurse -Filter "*_screen.dart"

foreach ($file in $allScreens) {
    if ($screensWithTabs -notcontains $file.FullName) {
        $relativePath = $file.FullName -replace [regex]::Escape($PWD.Path + "\"), ""
        $fileName = $file.Name
        
        # Check for StandardAppBar
        $hasStandardAppBar = Select-String -Path $file.FullName -Pattern "StandardAppBar" -Quiet
        
        # Check for any AppBar
        $hasAnyAppBar = Select-String -Path $file.FullName -Pattern "appBar:" -Quiet
        
        $status = "[?] Unknown"
        $color = "Gray"
        
        if ($hasStandardAppBar) {
            $status = "[OK] Uses StandardAppBar"
            $color = "Green"
        } elseif ($hasAnyAppBar) {
            $status = "[!] Uses Custom AppBar"
            $color = "Yellow"
        } else {
            $status = "[X] No AppBar Found"
            $color = "Red"
        }
        
        Write-Host "  $fileName" -NoNewline
        Write-Host " $status" -ForegroundColor $color
        Write-Host "    $relativePath" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "[SUMMARY]" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$percentage = if ($total -gt 0) { [math]::Round(($implemented / $total) * 100, 1) } else { 0 }

Write-Host "  Total screens with tabs: $total" -ForegroundColor White
Write-Host "  Fully implemented: $implemented" -ForegroundColor Green
Write-Host "  Remaining: $($total - $implemented)" -ForegroundColor Yellow
Write-Host "  Progress: $percentage%" -ForegroundColor Cyan
Write-Host ""

if ($implemented -eq $total) {
    Write-Host "[SUCCESS] All screens are using Smart Back Navigation!" -ForegroundColor Green
} else {
    Write-Host "[TODO] Please implement Smart Back Navigation on remaining screens." -ForegroundColor Yellow
    Write-Host "See NAVIGATION_AUDIT.md for instructions." -ForegroundColor Cyan
}
