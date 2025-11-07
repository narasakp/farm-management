@echo off
REM Create Desktop Shortcut for Farm Backup (Dev Mode)
REM Created: 2025-10-12

echo.
echo Creating Desktop Shortcut...
echo.

set SCRIPT_DIR=%~dp0
set BACKUP_SCRIPT=%SCRIPT_DIR%BACKUP_FARM_DEV.bat

REM Try multiple Desktop locations
set DESKTOP=%USERPROFILE%\Desktop
if not exist "%DESKTOP%" set DESKTOP=%USERPROFILE%\OneDrive\Desktop
if not exist "%DESKTOP%" set DESKTOP=%PUBLIC%\Desktop

echo Desktop location: %DESKTOP%
echo.

set SHORTCUT_VBS=%TEMP%\create_shortcut.vbs
set SHORTCUT_NAME=Backup Farm Dev.lnk

REM Create VBScript to make shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%SHORTCUT_VBS%"
echo sLinkFile = "%DESKTOP%\%SHORTCUT_NAME%" >> "%SHORTCUT_VBS%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%SHORTCUT_VBS%"
echo oLink.TargetPath = "%BACKUP_SCRIPT%" >> "%SHORTCUT_VBS%"
echo oLink.WorkingDirectory = "%SCRIPT_DIR%" >> "%SHORTCUT_VBS%"
echo oLink.IconLocation = "shell32.dll,4" >> "%SHORTCUT_VBS%"
echo oLink.Description = "Backup Farm (Development Mode)" >> "%SHORTCUT_VBS%"
echo oLink.Save >> "%SHORTCUT_VBS%"

REM Execute VBScript
cscript //nologo "%SHORTCUT_VBS%"

REM Cleanup
del "%SHORTCUT_VBS%"

echo.
echo =====================================
echo  Shortcut Created!
echo =====================================
echo.
echo Location: %DESKTOP%\%SHORTCUT_NAME%
echo Target: %BACKUP_SCRIPT%
echo.
echo You can now double-click the shortcut
echo on your Desktop to backup the farm!
echo.
pause
