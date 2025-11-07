@echo off
REM Start ngrok tunnel for Facebook Login (HTTPS required)

echo.
echo ====================================
echo   Starting ngrok HTTPS Tunnel
echo ====================================
echo.

REM Find ngrok.exe
set NGROK_PATH=C:\Users\ASUS\AppData\Local\Microsoft\WinGet\Packages\Ngrok.Ngrok_Microsoft.Winget.Source_8wekyb3d8bbwe\ngrok.exe

if not exist "%NGROK_PATH%" (
    echo ERROR: ngrok.exe not found!
    echo Please install: winget install ngrok.ngrok
    pause
    exit /b 1
)

echo Found ngrok at: %NGROK_PATH%
echo.
echo Starting tunnel to http://localhost:8096...
echo.
echo [IMPORTANT] After tunnel starts:
echo   1. Copy the HTTPS URL (e.g., https://abc123.ngrok-free.app)
echo   2. Add it to Facebook App OAuth Redirect URIs
echo   3. Open that HTTPS URL in browser
echo.

"%NGROK_PATH%" http 8096

pause
