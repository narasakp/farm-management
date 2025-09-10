@echo off
echo ========================================
echo   Git Authentication Setup
echo ========================================

echo [1/3] Setting up Git credential manager...
git config --global credential.helper manager-core
if %errorlevel% neq 0 (
    echo ERROR: Failed to set credential helper!
    pause
    exit /b 1
)

echo [2/3] Checking current git configuration...
echo Git user name:
git config --global user.name
echo Git user email:
git config --global user.email

echo.
echo [3/3] Testing GitHub connection...
echo This will prompt for GitHub login if not authenticated
git ls-remote https://github.com/narasakp/farm-management.git
if %errorlevel% neq 0 (
    echo ERROR: GitHub authentication failed!
    echo Please check your credentials and try again
    pause
    exit /b 1
)

echo ========================================
echo   Git Authentication Setup Complete!
echo   You can now use deploy.bat
echo ========================================
pause
