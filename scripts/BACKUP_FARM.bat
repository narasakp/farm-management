@echo off
REM Farm Management Backup - Double Click to Run
REM Created: 2025-10-07

cd /d "%~dp0.."
echo.
echo =====================================
echo  Farm Management Backup
echo =====================================
echo.
echo Starting backup...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0backup-simple.ps1"

echo.
echo =====================================
echo  Backup Complete!
echo =====================================
echo.
echo Press any key to close...
pause > nul
