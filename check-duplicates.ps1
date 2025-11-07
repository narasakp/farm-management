# Duplicate Screen Detection Script
# ตรวจสอบว่ามี screen หรือ route ซ้ำไหม

Write-Host "[*] Checking for duplicate screens and routes..." -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()

# 1. Check for duplicate routes in main.dart
Write-Host "[1] Checking duplicate routes in lib/main.dart..." -ForegroundColor Yellow

if (Test-Path "lib/main.dart") {
    $routes = Select-String -Path "lib/main.dart" -Pattern "path: '([^']+)'" | ForEach-Object {
        $_.Matches[0].Groups[1].Value
    }
    
    $duplicateRoutes = $routes | Group-Object | Where-Object { $_.Count -gt 1 }
    
    if ($duplicateRoutes) {
        foreach ($dup in $duplicateRoutes) {
            $errors += "[ERROR] Duplicate route found: $($dup.Name) (appears $($dup.Count) times)"
        }
    } else {
        Write-Host "   [OK] No duplicate routes" -ForegroundColor Green
    }
} else {
    $warnings += "[WARN] lib/main.dart not found"
}

Write-Host ""

# 2. Check for similar screen names
Write-Host "[2] Checking for similar screen names..." -ForegroundColor Yellow

if (Test-Path "lib/screens") {
    $screens = Get-ChildItem -Path "lib/screens" -Recurse -Filter "*_screen.dart" | 
        Select-Object -ExpandProperty Name
    
    # Group by similar names (ignoring suffixes like detail, list, etc.)
    $baseNames = @{}
    foreach ($screen in $screens) {
        # Extract base name (e.g., "admin_users" from "admin_users_screen.dart")
        $baseName = $screen -replace "_screen\.dart$", ""
        $baseName = $baseName -replace "_(list|detail|management|edit|create)$", ""
        
        if (-not $baseNames.ContainsKey($baseName)) {
            $baseNames[$baseName] = @()
        }
        $baseNames[$baseName] += $screen
    }
    
    $similarScreens = $baseNames.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    
    if ($similarScreens) {
        foreach ($similar in $similarScreens) {
            $warnings += "[WARN] Similar screens found for '$($similar.Key)':"
            foreach ($screen in $similar.Value) {
                $warnings += "     - $screen"
            }
        }
    } else {
        Write-Host "   [OK] No obviously similar screen names" -ForegroundColor Green
    }
} else {
    $warnings += "[WARN] lib/screens directory not found"
}

Write-Host ""

# 3. Check if SCREEN_INVENTORY.md is up to date
Write-Host "[3] Checking SCREEN_INVENTORY.md..." -ForegroundColor Yellow

if (Test-Path "SCREEN_INVENTORY.md") {
    # Count screens in inventory
    $inventoryScreens = (Select-String -Path "SCREEN_INVENTORY.md" -Pattern "\| .+ \| /.+ \| " | Measure-Object).Count
    
    # Count actual screens
    $actualScreens = (Get-ChildItem -Path "lib/screens" -Recurse -Filter "*_screen.dart" | Measure-Object).Count
    
    $diff = $actualScreens - $inventoryScreens
    
    if ($diff -gt 0) {
        $warnings += "[WARN] SCREEN_INVENTORY.md might be outdated"
        $warnings += "     Actual screens: $actualScreens"
        $warnings += "     Documented: $inventoryScreens"
        $warnings += "     Missing: $diff screens"
    } elseif ($diff -lt 0) {
        $warnings += "[WARN] SCREEN_INVENTORY.md has more entries than actual screens"
        $warnings += "     (Might include deprecated screens)"
    } else {
        Write-Host "   [OK] SCREEN_INVENTORY.md appears up to date" -ForegroundColor Green
    }
} else {
    $errors += "[ERROR] SCREEN_INVENTORY.md not found!"
    $errors += "     Run: See D:/Code/_KNOWLEDGE_BASE/TROUBLESHOOTING/ADMIN_SCREEN_DUPLICATION_REFACTOR_2025-10-21.md"
}

Write-Host ""

# 4. Check for admin screen patterns
Write-Host "[4] Checking admin screen patterns..." -ForegroundColor Yellow

$adminScreens = Get-ChildItem -Path "lib/screens/admin" -Filter "*_screen.dart" -ErrorAction SilentlyContinue

if ($adminScreens) {
    $userManagementScreens = $adminScreens | Where-Object { 
        $_.Name -match "user" -and $_.Name -notmatch "dashboard"
    }
    
    if ($userManagementScreens) {
        $warnings += "[WARN] Found non-dashboard user management screens:"
        foreach ($screen in $userManagementScreens) {
            $warnings += "     - $($screen.Name)"
        }
        $warnings += "     All user management should be in admin_dashboard_screen.dart"
    } else {
        Write-Host "   [OK] No separate user management screens" -ForegroundColor Green
    }
} else {
    Write-Host "   [INFO] No admin screens found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Show errors
if ($errors.Count -gt 0) {
    Write-Host "[ERROR] ERRORS ($($errors.Count)):" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "   $err" -ForegroundColor Red
    }
    Write-Host ""
}

# Show warnings
if ($warnings.Count -gt 0) {
    Write-Host "[WARN] WARNINGS ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Final result
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "[OK] All checks passed! No duplicates found." -ForegroundColor Green
    Write-Host ""
    exit 0
} elseif ($errors.Count -gt 0) {
    Write-Host "[ERROR] Found critical issues. Please fix before continuing." -ForegroundColor Red
    Write-Host ""
    Write-Host "See: DUPLICATE_PREVENTION_SYSTEM.md" -ForegroundColor Cyan
    Write-Host "See: SCREEN_INVENTORY.md" -ForegroundColor Cyan
    Write-Host ""
    exit 1
} else {
    Write-Host "[WARN] Found warnings. Review recommended but not critical." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "See: DUPLICATE_PREVENTION_SYSTEM.md" -ForegroundColor Cyan
    Write-Host "See: SCREEN_INVENTORY.md" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}
