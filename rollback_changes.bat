@echo off
echo ========================================
echo  Rollback Changes
echo ========================================
echo.

REM Restore from backup
if exist "build\web\index.html.backup" (
    echo [1/2] Restoring index.html from backup...
    copy /Y "build\web\index.html.backup" "build\web\index.html"
    echo ✅ index.html restored
) else (
    echo ⚠️ No backup found for index.html
)
echo.

if exist "build\web_backup" (
    echo [2/2] Restoring full build backup...
    rmdir /s /q "build\web"
    xcopy /E /I /Y "build\web_backup" "build\web"
    echo ✅ Full build restored
) else (
    echo ⚠️ No backup found for build\web
)
echo.

echo ========================================
echo  Rollback Complete
echo ========================================
echo.
echo 🔄 Refresh browser (Ctrl+F5)
echo 🌐 URL: http://localhost:8096
echo.
pause
