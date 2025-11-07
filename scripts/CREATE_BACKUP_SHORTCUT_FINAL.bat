@echo off
REM Create Backup Shortcut on Desktop (OneDrive Compatible)
REM Created: 2025-10-07

set "scriptDir=%~dp0"
set "targetScript=%scriptDir%BACKUP_FARM.bat"

REM Try OneDrive Desktop first, then regular Desktop
if exist "%USERPROFILE%\OneDrive\Desktop\" (
    set "desktopPath=%USERPROFILE%\OneDrive\Desktop"
    echo Using OneDrive Desktop...
) else (
    set "desktopPath=%USERPROFILE%\Desktop"
    echo Using regular Desktop...
)

set "shortcutPath=%desktopPath%\BACKUP_FARM.lnk"

echo.
echo Creating backup shortcut...
echo Target: %targetScript%
echo Desktop: %desktopPath%
echo.

REM Create temporary VBScript
set "vbsFile=%TEMP%\CreateShortcut.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%vbsFile%"
echo sLinkFile = "%shortcutPath%" >> "%vbsFile%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%vbsFile%"
echo oLink.TargetPath = "%targetScript%" >> "%vbsFile%"
echo oLink.WorkingDirectory = "%scriptDir%.." >> "%vbsFile%"
echo oLink.Description = "Backup Farm Management App" >> "%vbsFile%"
echo oLink.IconLocation = "shell32.dll,4" >> "%vbsFile%"
echo oLink.Save >> "%vbsFile%"

REM Run VBScript
cscript //nologo "%vbsFile%"

REM Clean up
del "%vbsFile%"

REM Verify
echo.
if exist "%shortcutPath%" (
    echo =====================================
    echo ✅ SUCCESS!
    echo =====================================
    echo.
    echo Shortcut created: BACKUP_FARM
    echo Location: %desktopPath%
    echo.
    echo Double-click "BACKUP_FARM" on Desktop to backup!
    echo.
) else (
    echo =====================================
    echo ❌ Failed to create shortcut
    echo =====================================
    echo.
    echo Manual method:
    echo 1. Right-click on Desktop
    echo 2. New ^> Shortcut
    echo 3. Paste this path:
    echo    %targetScript%
    echo 4. Click Next
    echo 5. Name it: BACKUP FARM
    echo 6. Click Finish
    echo.
)

pause
