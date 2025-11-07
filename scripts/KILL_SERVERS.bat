@echo off
REM Kill All Python Servers - Quick Cleanup
REM Created: 2025-10-07

echo.
echo =====================================
echo  Killing All Python Servers
echo =====================================
echo.

taskkill /F /IM python.exe /T >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo Success: All servers stopped!
) else (
    echo No servers running
)

echo.
timeout /t 2 >nul
