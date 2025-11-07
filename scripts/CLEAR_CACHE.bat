@echo off
REM Clear Browser Cache - Force Reload New Build
REM Created: 2025-10-07

cd /d "%~dp0.."

echo.
echo =====================================
echo  Clear Browser Cache
echo =====================================
echo.

REM Kill existing python servers
echo Stopping server...
taskkill /f /im python.exe >nul 2>&1

REM Update version file
echo Creating new version file...
powershell -Command "$timestamp = Get-Date -Format 'yyyyMMddHHmmss'; $version = @{version=$timestamp;build=(Get-Date).ToString('o')} | ConvertTo-Json; $version | Out-File 'web\version.json' -Encoding UTF8"

REM Start server with hidden window
echo Starting server (hidden)...
start /B powershell -WindowStyle Hidden -Command "cd '%~dp0..'; python -m http.server 8096 --directory web"

timeout /t 2 >nul

echo.
echo =====================================
echo  Done!
echo =====================================
echo.
echo Next steps to see changes:
echo.
echo 1. Open Incognito/Private Window (Ctrl+Shift+N)
echo 2. Go to: http://localhost:8096
echo.
echo OR
echo.
echo 1. Open DevTools (F12)
echo 2. Right-click Refresh button
echo 3. Select "Empty Cache and Hard Reload"
echo.
echo OR
echo.
echo 1. Go to: chrome://serviceworker-internals
echo 2. Find "localhost:8096"
echo 3. Click "Unregister"
echo 4. Refresh page
echo.

pause
