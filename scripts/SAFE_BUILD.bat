@echo off
REM Safe Flutter Build - Double Click to Run (Auto-close)
REM Created: 2025-10-07
REM Updated: 2025-10-07 19:17 - Auto-close, no lingering windows

cd /d "%~dp0.."

REM Show notification
start "" cmd /c "echo Safe Build starting... && timeout /t 2 >nul"

REM Run build script silently
powershell -WindowStyle Minimized -ExecutionPolicy Bypass -File "%~dp0safe-build-v2.ps1"

REM Auto-close (no pause)
