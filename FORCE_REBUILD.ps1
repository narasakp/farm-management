# Force Full Rebuild for Flutter Web
Write-Host "🧹 Cleaning Flutter build cache..." -ForegroundColor Yellow

# Stop all running processes
Get-Process -Name dart,node -ErrorAction SilentlyContinue | Stop-Process -Force

# Remove build artifacts
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .flutter-plugins -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .flutter-plugins-dependencies -ErrorAction SilentlyContinue

Write-Host "✅ Cache cleared!" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "🚀 Ready to run!" -ForegroundColor Green
Write-Host ""
Write-Host "Run these commands in separate terminals:" -ForegroundColor Cyan
Write-Host "1. cd backend; node server.js" -ForegroundColor White
Write-Host "2. flutter run -d web-server --web-port=8096" -ForegroundColor White
