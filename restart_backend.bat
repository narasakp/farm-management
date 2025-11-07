@echo off
echo Stopping Backend Server...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') do taskkill /F /PID %%a 2>nul
timeout /t 2 /nobreak >nul

echo Starting Backend Server with Logging...
cd backend
start "Farm Backend Server" cmd /k "node server.js"
cd ..

echo Backend server restarted!
echo Check the new window for logs.
pause
