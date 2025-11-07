@echo off
REM Farm Management Backup - Development Mode
REM Created: 2025-10-12
REM Usage: Double-click to backup source code and database

cd /d "%~dp0.."
echo.
echo =====================================
echo  Farm Management Backup (Dev Mode)
echo =====================================
echo.
echo Starting backup...
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0backup-dev.ps1"

echo.
echo =====================================
echo  Backup Complete!
echo =====================================
echo.
echo Press any key to close...
pause > nul
