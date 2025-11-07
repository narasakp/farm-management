@echo off
REM Simple Health Check for Farm Management System

echo ========================================
echo   Farm System Health Check
echo ========================================
echo.

color 0B

REM Check processes
echo 📊 Checking running processes...
tasklist | findstr "node.exe" >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js process not running
) else (
    echo ✅ Node.js process is running
)

tasklist | findstr "dart.exe" >nul 2>&1
if errorlevel 1 (
    echo ❌ Dart process not running
) else (
    echo ✅ Dart process is running
)

echo.

REM Check ports
echo 🔌 Checking ports...
netstat -an | find ":3000" >nul 2>&1
if errorlevel 1 (
    echo ❌ Port 3000 (Backend) is not open
) else (
    echo ✅ Port 3000 (Backend) is open
)

netstat -an | find ":8096" >nul 2>&1
if errorlevel 1 (
    echo ❌ Port 8096 (Frontend) is not open
) else (
    echo ✅ Port 8096 (Frontend) is open
)

echo.

REM Test backend API
echo 🌐 Testing Backend API...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/api/health' -TimeoutSec 5; Write-Host '✅ Backend API is responding' } catch { Write-Host '❌ Backend API is not responding' }"

echo.

REM Show URLs
echo 🔗 System URLs:
echo    Frontend: http://localhost:8096
echo    Backend:  http://localhost:3000/api/health

echo.
echo ========================================
pause
