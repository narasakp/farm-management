@echo off
REM Create desktop shortcuts for Farm Management System

echo Creating desktop shortcuts...

REM Create shortcut for main startup
powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\🚀 Start Farm System.lnk'); $Shortcut.TargetPath = '%CD%\start-farm-system.bat'; $Shortcut.WorkingDirectory = '%CD%'; $Shortcut.IconLocation = 'shell32.dll,25'; $Shortcut.Save()"

REM Create shortcut for emergency restart
powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\🔄 Emergency Restart.lnk'); $Shortcut.TargetPath = '%CD%\quick-restart.bat'; $Shortcut.WorkingDirectory = '%CD%'; $Shortcut.IconLocation = 'shell32.dll,238'; $Shortcut.Save()"

REM Create shortcut for health check
powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\🔍 Health Check.lnk'); $Shortcut.TargetPath = 'node'; $Shortcut.Arguments = 'scripts\health-check.js'; $Shortcut.WorkingDirectory = '%CD%\..'; $Shortcut.IconLocation = 'shell32.dll,23'; $Shortcut.Save()"

echo ✅ Desktop shortcuts created:
echo    🚀 Start Farm System - One-click startup with monitoring
echo    🔄 Emergency Restart - When you come back from lunch
echo    🔍 Health Check - Quick system diagnostics
echo.
pause
