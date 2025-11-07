# Script สำหรับตรวจสอบและแก้ไข errors อัตโนมัติ
# Social Commerce Auto-Fix Script

Write-Host "🔧 Starting Auto-Fix for Social Commerce..." -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# 1. Check Flutter
Write-Host "📱 Checking Flutter..." -ForegroundColor Yellow
if (-not (Test-Command "flutter")) {
    Write-Host "❌ Flutter not found!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Flutter found" -ForegroundColor Green

# 2. Clean project
Write-Host ""
Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
flutter clean
Write-Host "✅ Clean complete" -ForegroundColor Green

# 3. Get dependencies
Write-Host ""
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    Write-Host "👉 Please check pubspec.yaml and add missing dependencies from pubspec_additions.yaml" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Dependencies installed" -ForegroundColor Green

# 4. Generate mocks (if mockito is configured)
Write-Host ""
Write-Host "🏗️  Generating mocks..." -ForegroundColor Yellow
flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Mock generation failed (this is OK if mockito not configured yet)" -ForegroundColor Yellow
} else {
    Write-Host "✅ Mocks generated" -ForegroundColor Green
}

# 5. Analyze code
Write-Host ""
Write-Host "🔍 Analyzing code..." -ForegroundColor Yellow
flutter analyze > analyze_output.txt 2>&1
$analyzeErrors = Select-String -Path "analyze_output.txt" -Pattern "error •" -AllMatches
$analyzeWarnings = Select-String -Path "analyze_output.txt" -Pattern "warning •" -AllMatches

if ($analyzeErrors.Count -gt 0) {
    Write-Host "❌ Found $($analyzeErrors.Count) errors:" -ForegroundColor Red
    Get-Content "analyze_output.txt" | Select-String "error •" | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Red
    }
} else {
    Write-Host "✅ No errors found" -ForegroundColor Green
}

if ($analyzeWarnings.Count -gt 0) {
    Write-Host "⚠️  Found $($analyzeWarnings.Count) warnings" -ForegroundColor Yellow
}

# 6. Try to compile
Write-Host ""
Write-Host "🔨 Trying to compile..." -ForegroundColor Yellow
flutter build apk --debug --no-tree-shake-icons 2>&1 | Tee-Object -Variable buildOutput
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Common Fixes:" -ForegroundColor Yellow
    Write-Host "1. Check pubspec.yaml has all dependencies" -ForegroundColor Gray
    Write-Host "2. Run: flutter pub add share_plus url_launcher uni_links" -ForegroundColor Gray
    Write-Host "3. Check imports in files" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Copy error messages and send to Cascade for fixes" -ForegroundColor Cyan
} else {
    Write-Host "✅ Build successful!" -ForegroundColor Green
}

# 7. Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Errors: $($analyzeErrors.Count)" -ForegroundColor $(if ($analyzeErrors.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $($analyzeWarnings.Count)" -ForegroundColor $(if ($analyzeWarnings.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($analyzeErrors.Count -eq 0) {
    Write-Host "🎉 No critical errors! Ready to test!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run tests: flutter test" -ForegroundColor Gray
    Write-Host "2. If tests fail, copy errors and send to Cascade" -ForegroundColor Gray
} else {
    Write-Host "⚠️  Please fix errors above" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Full analysis saved to: analyze_output.txt" -ForegroundColor Gray
    Write-Host "💡 Send errors to Cascade for automated fixes" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
