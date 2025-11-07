@echo off
REM Farm Management System - Emergency Restart Script
REM For when you come back from lunch and servers are down

echo ========================================
echo   Emergency Server Restart
echo ========================================
echo.

color 0C

cd /d "D:\Code\farm"

echo [%TIME%] 🚨 Emergency restart initiated...
echo.

REM Kill all existing processes
echo [%TIME%] 🧹 Cleaning up existing processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im dart.exe >nul 2>&1

REM Wait for processes to terminate
timeout /t 3 /nobreak >nul

echo [%TIME%] ✅ Process cleanup completed
echo.

REM Start servers manually
echo [%TIME%] 🚀 Starting Backend Server...
start "Backend Server" cmd /k "cd /d D:\Code\farm\backend && node server.js"

REM Wait for backend to start
timeout /t 5 /nobreak >nul

echo [%TIME%] 🌐 Starting Flutter Web Server...
start "Flutter Web" cmd /k "cd /d D:\Code\farm && C:\src\flutter\bin\flutter.bat run -d web-server --web-port=8096"

echo.
echo ========================================
echo   Emergency restart completed
echo   Servers are starting in separate windows
echo ========================================
echo.

REM Test the servers (simplified)
echo [%TIME%] 🔍 Testing server connectivity...
echo.

REM Test backend with PowerShell (more reliable than curl)
echo Testing Backend API...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/api/health' -TimeoutSec 5; Write-Host '✅ Backend is healthy' } catch { Write-Host '❌ Backend is not responding' }"

REM Test frontend port
echo Testing Frontend port...
netstat -an | find ":8096" >nul 2>&1
if errorlevel 1 (
    echo ❌ Frontend port 8096 is not open yet (may still be starting)
) else (
    echo ✅ Frontend port 8096 is active
)

echo.
echo 🌐 Frontend URL: http://localhost:8096
echo 🔧 Backend URL: http://localhost:3000/api/health
echo.

pause
