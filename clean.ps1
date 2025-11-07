Write-Host "Cleaning Flutter cache..." -ForegroundColor Yellow
Get-Process -Name dart,node -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
Write-Host "Done! Run: flutter pub get" -ForegroundColor Green
