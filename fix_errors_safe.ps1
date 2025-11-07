# Script สำหรับตรวจสอบและแก้ไข errors อัตโนมัติ
# Social Commerce Auto-Fix Script

Write-Host "Starting Auto-Fix for Social Commerce..." -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# 1. Check Flutter
Write-Host "Checking Flutter..." -ForegroundColor Yellow
if (-not (Test-Command "flutter")) {
    Write-Host "[ERROR] Flutter not found!" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Flutter found" -ForegroundColor Green

# 2. Clean project
Write-Host ""
Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean
Write-Host "[OK] Clean complete" -ForegroundColor Green

# 3. Get dependencies
Write-Host ""
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to get dependencies" -ForegroundColor Red
    Write-Host "TIP: Please check pubspec.yaml and add missing dependencies" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run these commands:" -ForegroundColor Cyan
    Write-Host "flutter pub add share_plus url_launcher uni_links qr_flutter go_router http intl" -ForegroundColor Gray
    Write-Host "flutter pub add firebase_core cloud_firestore firebase_storage firebase_analytics" -ForegroundColor Gray
    exit 1
}
Write-Host "[OK] Dependencies installed" -ForegroundColor Green

# 4. Generate mocks (if mockito is configured)
Write-Host ""
Write-Host "Generating mocks..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] Mock generation failed (this is OK if mockito not configured yet)" -ForegroundColor Yellow
} else {
    Write-Host "[OK] Mocks generated" -ForegroundColor Green
}

# 5. Analyze code
Write-Host ""
Write-Host "Analyzing code..." -ForegroundColor Yellow
flutter analyze > analyze_output.txt 2>&1
$analyzeContent = Get-Content "analyze_output.txt" -Raw
$analyzeErrors = Select-String -Path "analyze_output.txt" -Pattern "error •" -AllMatches
$analyzeWarnings = Select-String -Path "analyze_output.txt" -Pattern "warning •" -AllMatches

if ($analyzeErrors.Count -gt 0) {
    Write-Host "[ERROR] Found $($analyzeErrors.Count) errors:" -ForegroundColor Red
    Get-Content "analyze_output.txt" | Select-String "error •" | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Red
    }
    Write-Host ""
} else {
    Write-Host "[OK] No errors found" -ForegroundColor Green
}

if ($analyzeWarnings.Count -gt 0) {
    Write-Host "[WARNING] Found $($analyzeWarnings.Count) warnings" -ForegroundColor Yellow
}

# 6. Summary
Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Errors: $($analyzeErrors.Count)" -ForegroundColor $(if ($analyzeErrors.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $($analyzeWarnings.Count)" -ForegroundColor $(if ($analyzeWarnings.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($analyzeErrors.Count -eq 0) {
    Write-Host "SUCCESS: No critical errors! Ready to test!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run tests: flutter test" -ForegroundColor Gray
    Write-Host "2. If tests fail, copy errors and send to Cascade" -ForegroundColor Gray
} else {
    Write-Host "WARNING: Please fix errors above" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Full analysis saved to: analyze_output.txt" -ForegroundColor Gray
    Write-Host ""
    Write-Host "COPY THE ERRORS ABOVE AND SEND TO CASCADE" -ForegroundColor Cyan
    Write-Host "Cascade will fix them automatically!" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
