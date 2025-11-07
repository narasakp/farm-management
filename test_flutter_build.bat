@echo off
echo ========================================
echo  Testing Flutter Web Build
echo ========================================
echo.

REM Backup current build
echo [1/4] Backing up current build...
if exist "build\web_backup" rmdir /s /q "build\web_backup"
if exist "build\web" (
    xcopy /E /I /Y "build\web" "build\web_backup"
    echo ✅ Backup complete: build\web_backup
) else (
    echo ⚠️ No existing build to backup
)
echo.

REM Test build with new changes
echo [2/4] Building Flutter web with new changes...
call flutter build web --release --no-source-maps
if errorlevel 1 (
    echo.
    echo ❌ Build failed! Restoring backup...
    if exist "build\web_backup" (
        rmdir /s /q "build\web"
        xcopy /E /I /Y "build\web_backup" "build\web"
        echo ✅ Backup restored successfully
    )
    pause
    exit /b 1
)
echo.

REM Copy index.html to build
echo [3/4] Copying index.html to build...
copy /Y index.html build\web\index.html
echo.

REM Test server
echo [4/4] Testing on http://localhost:8097...
echo.
echo ========================================
echo  Test Server Ready
echo ========================================
echo.
echo 🌐 URL: http://localhost:8097
echo.
echo Press Ctrl+C to stop server
echo ========================================
echo.

python -m http.server 8097 --directory build\web
