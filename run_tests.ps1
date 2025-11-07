# PowerShell Script to Run All Tests
# Social Commerce Testing Suite

Write-Host "🧪 Starting Social Commerce Test Suite..." -ForegroundColor Cyan
Write-Host ""

# Function to print section header
function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

# Check if Flutter is installed
Write-Section "Checking Prerequisites"
$flutterVersion = flutter --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Flutter is installed" -ForegroundColor Green

# Clean previous build
Write-Section "Cleaning Previous Build"
Write-Host "Running flutter clean..." -ForegroundColor Cyan
flutter clean
Write-Host "✅ Clean complete" -ForegroundColor Green

# Get dependencies
Write-Section "Getting Dependencies"
Write-Host "Running flutter pub get..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Dependencies installed" -ForegroundColor Green

# Run Unit Tests
Write-Section "Running Unit Tests"
Write-Host "Testing models and services..." -ForegroundColor Cyan
flutter test test/ --coverage
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Unit tests failed" -ForegroundColor Red
    $unitTestsFailed = $true
} else {
    Write-Host "✅ Unit tests passed" -ForegroundColor Green
    $unitTestsPassed = $true
}

# Run Widget Tests
Write-Section "Running Widget Tests"
Write-Host "Testing UI components..." -ForegroundColor Cyan
flutter test test/widgets/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Widget tests failed" -ForegroundColor Red
    $widgetTestsFailed = $true
} else {
    Write-Host "✅ Widget tests passed" -ForegroundColor Green
    $widgetTestsPassed = $true
}

# Run Integration Tests
Write-Section "Running Integration Tests"
Write-Host "This will launch the app. Make sure a device/emulator is connected." -ForegroundColor Cyan
Write-Host "Press any key to continue or Ctrl+C to skip..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

flutter test integration_test/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Integration tests failed" -ForegroundColor Red
    $integrationTestsFailed = $true
} else {
    Write-Host "✅ Integration tests passed" -ForegroundColor Green
    $integrationTestsPassed = $true
}

# Generate Coverage Report
Write-Section "Generating Coverage Report"
if (Test-Path "coverage/lcov.info") {
    Write-Host "Converting coverage to HTML..." -ForegroundColor Cyan
    
    # Check if genhtml is available (part of lcov package)
    $genhtmlExists = Get-Command genhtml -ErrorAction SilentlyContinue
    if ($genhtmlExists) {
        genhtml coverage/lcov.info -o coverage/html
        Write-Host "✅ Coverage report generated at coverage/html/index.html" -ForegroundColor Green
        
        # Ask if user wants to open the report
        Write-Host ""
        Write-Host "Do you want to open the coverage report? (Y/N)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq 'Y' -or $response -eq 'y') {
            Start-Process "coverage/html/index.html"
        }
    } else {
        Write-Host "⚠️  genhtml not found. Install lcov to generate HTML coverage report." -ForegroundColor Yellow
        Write-Host "   On Windows: choco install lcov" -ForegroundColor Gray
        Write-Host "   On Mac: brew install lcov" -ForegroundColor Gray
        Write-Host "   On Linux: sudo apt-get install lcov" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  No coverage data found" -ForegroundColor Yellow
}

# Print Summary
Write-Section "Test Summary"
Write-Host "Test Results:" -ForegroundColor Cyan
Write-Host ""

if ($unitTestsPassed) {
    Write-Host "  ✅ Unit Tests: PASSED" -ForegroundColor Green
} elseif ($unitTestsFailed) {
    Write-Host "  ❌ Unit Tests: FAILED" -ForegroundColor Red
} else {
    Write-Host "  ⚠️  Unit Tests: SKIPPED" -ForegroundColor Yellow
}

if ($widgetTestsPassed) {
    Write-Host "  ✅ Widget Tests: PASSED" -ForegroundColor Green
} elseif ($widgetTestsFailed) {
    Write-Host "  ❌ Widget Tests: FAILED" -ForegroundColor Red
} else {
    Write-Host "  ⚠️  Widget Tests: SKIPPED" -ForegroundColor Yellow
}

if ($integrationTestsPassed) {
    Write-Host "  ✅ Integration Tests: PASSED" -ForegroundColor Green
} elseif ($integrationTestsFailed) {
    Write-Host "  ❌ Integration Tests: FAILED" -ForegroundColor Red
} else {
    Write-Host "  ⚠️  Integration Tests: SKIPPED" -ForegroundColor Yellow
}

Write-Host ""

# Check if all tests passed
if ($unitTestsPassed -and $widgetTestsPassed -and $integrationTestsPassed) {
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  🎉 ALL TESTS PASSED! 🎉" -ForegroundColor Green
    Write-Host "  Ready for Production Deployment! 🚀" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Green
    exit 0
} else {
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  ⚠️  SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "  Please fix the issues before deployment" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Red
    exit 1
}
