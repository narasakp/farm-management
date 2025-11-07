@echo off
echo ========================================
echo Installing Multer for File Upload
echo ========================================
echo.

cd /d D:\Code\farm\backend

echo [1/1] Installing multer...
call npm install multer --save

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Restart backend server
echo 2. Test upload endpoint: POST /api/upload/feedback
echo.
pause
