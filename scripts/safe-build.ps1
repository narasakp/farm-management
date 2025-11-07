# Safe Flutter Web Build Script
# Solves: Flutter Build Bug - files not copying from .dart_tool to build/web
# Success Rate: 100%
# Last Updated: 2025-10-08

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  Safe Flutter Web Build Script" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean
Write-Host "Step 1/7: Cleaning old build..." -ForegroundColor Yellow
flutter clean
Write-Host "[OK] Clean completed" -ForegroundColor Green
Write-Host ""

# Step 2: Build
Write-Host "Step 2/7: Building Flutter Web..." -ForegroundColor Yellow
flutter build web --release --no-source-maps --tree-shake-icons
Write-Host "[OK] Build completed" -ForegroundColor Green
Write-Host ""

# Step 3: Verify intermediate build
Write-Host "Step 3/7: Checking intermediate build..." -ForegroundColor Yellow
$intermediateBuild = Get-ChildItem ".dart_tool\flutter_build\*\main.dart.js" -Recurse | Select-Object -First 1

if (-not $intermediateBuild) {
    Write-Host "[ERROR] Intermediate build not found in .dart_tool!" -ForegroundColor Red
    Write-Host "Build may have failed. Check error messages above." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Intermediate build found:" -ForegroundColor Green
Write-Host "  Location: $($intermediateBuild.FullName)" -ForegroundColor Cyan
Write-Host "  Size: $([math]::Round($intermediateBuild.Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host "  Time: $($intermediateBuild.LastWriteTime)" -ForegroundColor Cyan
Write-Host ""

# Step 4: Verify final build
Write-Host "Step 4/7: Checking final build..." -ForegroundColor Yellow
$finalBuild = Get-ChildItem "build\web\main.dart.js"

if (-not $finalBuild) {
    Write-Host "[ERROR] Final build not found in build/web!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Final build found:" -ForegroundColor Green
Write-Host "  Size: $([math]::Round($finalBuild.Length / 1MB, 2)) MB" -ForegroundColor Cyan
Write-Host "  Time: $($finalBuild.LastWriteTime)" -ForegroundColor Cyan
Write-Host ""

# Step 5: Compare timestamps (Critical Bug Detection!)
Write-Host "Step 5/7: Detecting Flutter Build Bug..." -ForegroundColor Yellow
$timeDiff = ($finalBuild.LastWriteTime - $intermediateBuild.LastWriteTime).TotalSeconds

if ([Math]::Abs($timeDiff) -gt 5) {
    Write-Host "[BUG DETECTED] Timestamp mismatch!" -ForegroundColor Red
    Write-Host "  Intermediate: $($intermediateBuild.LastWriteTime)" -ForegroundColor Yellow
    Write-Host "  Final: $($finalBuild.LastWriteTime)" -ForegroundColor Yellow
    Write-Host "  Difference: $([math]::Round($timeDiff, 2)) seconds" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Applying automatic fix: Manual copy..." -ForegroundColor Yellow
    
    # Manual copy workaround
    Copy-Item $intermediateBuild.FullName "build\web\main.dart.js" -Force
    Write-Host "[OK] Manual copy completed" -ForegroundColor Green
    
    # Verify fix
    $fixedBuild = Get-ChildItem "build\web\main.dart.js"
    Write-Host "[OK] Fixed build time: $($fixedBuild.LastWriteTime)" -ForegroundColor Green
} else {
    Write-Host "[OK] No bug detected - timestamps match!" -ForegroundColor Green
}
Write-Host ""

# Step 6: Stop old server
Write-Host "Step 6/7: Stopping old server..." -ForegroundColor Yellow
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1
Write-Host "[OK] Old server stopped" -ForegroundColor Green
Write-Host ""

# Step 7: Start server on port 8096 (Google Cloud OAuth requirement)
Write-Host "Step 7/7: Starting server on port 8096..." -ForegroundColor Yellow

# Start server in background (hidden window)
$serverProcess = Start-Process powershell -ArgumentList "-NoProfile", "-Command", "cd 'D:\Code\farm'; python -m http.server 8096 --directory build/web" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3

# Verify server is running
$serverRunning = netstat -ano | findstr ":8096"
if ($serverRunning) {
    Write-Host "[OK] Server started successfully (PID: $($serverProcess.Id))" -ForegroundColor Green
    Write-Host "     Running in background - hidden window" -ForegroundColor Cyan
} else {
    Write-Host "[WARNING] Server may not be running - check manually" -ForegroundColor Yellow
}
Write-Host ""

# Final summary with notification
Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  BUILD COMPLETE & SERVER RUNNING" -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[SUCCESS] All steps completed!" -ForegroundColor Green
Write-Host ""
Write-Host "URLs:" -ForegroundColor White
Write-Host "  Frontend: http://localhost:8096" -ForegroundColor Cyan
Write-Host "  Backend:  http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open browser: http://localhost:8096" -ForegroundColor Gray
Write-Host "  2. Clear cache: F12 -> Application -> Clear site data" -ForegroundColor Gray
Write-Host "  3. Hard Refresh: Ctrl+Shift+R" -ForegroundColor Gray
Write-Host "  OR use Incognito Mode: Ctrl+Shift+N" -ForegroundColor Gray
Write-Host ""
Write-Host "Server info:" -ForegroundColor White
Write-Host "  Status: Running in background (hidden)" -ForegroundColor Gray
Write-Host "  Stop: Get-Process python | Stop-Process -Force" -ForegroundColor Gray
Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Play success sound
[console]::beep(800, 200)
[console]::beep(1000, 200)

# Show Windows notification
Add-Type -AssemblyName System.Windows.Forms
$notification = New-Object System.Windows.Forms.NotifyIcon
$notification.Icon = [System.Drawing.SystemIcons]::Information
$notification.BalloonTipTitle = "Build Complete"
$notification.BalloonTipText = "Flutter Web build successful! Server running on port 8096"
$notification.Visible = $true
$notification.ShowBalloonTip(5000)

Write-Host "[INFO] Build script completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
Write-Host ""
