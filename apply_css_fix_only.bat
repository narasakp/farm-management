@echo off
echo ========================================
echo  Apply CSS Fix Only (No Rebuild Needed)
echo ========================================
echo.

REM Backup current index.html
echo [1/2] Backing up build/web/index.html...
if exist "build\web\index.html" (
    copy /Y "build\web\index.html" "build\web\index.html.backup"
    echo ✅ Backup saved: build\web\index.html.backup
) else (
    echo ❌ build\web\index.html not found!
    pause
    exit /b 1
)
echo.

REM Copy new index.html
echo [2/2] Applying CSS fix...
copy /Y index.html build\web\index.html
if errorlevel 1 (
    echo ❌ Copy failed! Restoring backup...
    copy /Y "build\web\index.html.backup" "build\web\index.html"
    pause
    exit /b 1
)
echo.

echo ========================================
echo  CSS Fix Applied Successfully!
echo ========================================
echo.
echo ✅ Changes applied to build\web\index.html
echo 📁 Backup saved: build\web\index.html.backup
echo.
echo 🔄 Refresh browser (Ctrl+F5) to see changes
echo 🌐 URL: http://localhost:8096
echo.
echo ⚠️ If issues occur, restore with:
echo    copy build\web\index.html.backup build\web\index.html
echo.
pause
