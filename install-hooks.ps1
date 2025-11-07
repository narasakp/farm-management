# Install Git Hooks - PowerShell Version
# สำหรับ Windows

Write-Host "📦 Installing Git hooks..." -ForegroundColor Cyan
Write-Host ""

# Create .git/hooks directory if it doesn't exist
$hooksDir = ".git\hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    Write-Host "✅ Created $hooksDir directory" -ForegroundColor Green
}

# Copy pre-commit hook
$source = ".githooks\pre-commit"
$destination = ".git\hooks\pre-commit"

if (Test-Path $source) {
    Copy-Item -Path $source -Destination $destination -Force
    Write-Host "✅ Copied pre-commit hook" -ForegroundColor Green
} else {
    Write-Host "❌ Error: $source not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Git hooks installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "The following checks will run before each commit:" -ForegroundColor Yellow
Write-Host "  - New screen detection" -ForegroundColor White
Write-Host "  - SCREEN_INVENTORY.md update verification" -ForegroundColor White
Write-Host "  - Duplicate route detection" -ForegroundColor White
Write-Host ""
Write-Host "To bypass hooks (NOT recommended):" -ForegroundColor Gray
Write-Host "  git commit --no-verify" -ForegroundColor Gray
Write-Host ""

# Test if hook is executable
if (Test-Path $destination) {
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🧪 To test the hook:" -ForegroundColor Cyan
    Write-Host "  1. Create a test file: New-Item lib\screens\test_screen.dart" -ForegroundColor White
    Write-Host "  2. Stage it: git add lib\screens\test_screen.dart" -ForegroundColor White
    Write-Host "  3. Try commit: git commit -m 'test'" -ForegroundColor White
    Write-Host "  4. Should see warning about SCREEN_INVENTORY.md!" -ForegroundColor White
} else {
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    exit 1
}
