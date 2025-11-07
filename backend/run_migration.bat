@echo off
echo.
echo ========================================
echo   RBAC Migration Runner
echo ========================================
echo.

cd /d D:\Code\farm\backend

echo [1/3] Checking database...
if exist farm_auth.db (
    echo     Found: farm_auth.db
) else (
    echo     Warning: farm_auth.db not found, will be created
)

echo.
echo [2/3] Running migration...
node migrations\run_migration.js

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [3/3] Migration completed successfully!
    echo.
    echo ========================================
    echo   Next Step: Run test_rbac.js
    echo ========================================
) else (
    echo.
    echo [ERROR] Migration failed!
    echo Please check the error messages above
)

echo.
pause
