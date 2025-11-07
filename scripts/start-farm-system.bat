@echo off
REM Farm Management System - One-Click Startup Script
REM Prevents the half-day crisis from happening again

echo ========================================
echo   Farm Management System Startup
echo ========================================
echo.

REM Set colors for better visibility
color 0A

REM Change to the correct directory
cd /d "D:\Code\farm"

echo [%TIME%] 🚀 Starting Farm Management System...
echo.

REM Check if Node.js is available
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if Flutter is available
C:\src\flutter\bin\flutter.bat --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo ✅ Node.js and Flutter are available
echo.

REM Start servers manually (more reliable)
echo [%TIME%] 🚀 Starting Backend Server...
start "Backend Server" cmd /k "cd /d D:\Code\farm\backend && node server.js"

REM Wait for backend to start
timeout /t 5 /nobreak >nul

echo [%TIME%] 🌐 Starting Flutter Web Server...
start "Flutter Web" cmd /k "cd /d D:\Code\farm && C:\src\flutter\bin\flutter.bat run -d web-server --web-port=8096"

echo.
echo ========================================
echo   Servers are starting...
echo   Backend: http://localhost:3000
echo   Frontend: http://localhost:8096
echo ========================================
echo.
echo ✅ Both servers should be running in separate windows
echo 💡 Close those windows to stop the servers
echo.
pause
