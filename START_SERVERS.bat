@echo off
echo ======================================
echo  Farm Management Server Startup
echo ======================================
echo.

REM Validate Database Location
echo [1/3] Validating Database Location...
cd /d D:\Code\farm
node backend\validate_database.js
if errorlevel 1 (
    echo.
    echo ❌ Database validation failed! Please fix the issue above.
    echo.
    pause
    exit /b 1
)

REM Start Backend Server (Port 3000)
echo [2/3] Starting Backend Server...
start "Farm Backend Server" cmd /k "cd /d D:\Code\farm\backend && node server.js"
timeout /t 3 /nobreak > nul

REM Start Frontend Web Server (Port 8096)
echo [3/3] Starting Frontend Web Server...
start "Farm Web Server" cmd /k "cd /d D:\Code\farm && python -m http.server 8096 --directory build/web"

echo.
echo ======================================
echo  Servers Started Successfully!
echo ======================================
echo.
echo Backend API:  http://localhost:3000
echo Frontend App: http://localhost:8096
echo.
echo Press any key to close this window...
pause > nul
