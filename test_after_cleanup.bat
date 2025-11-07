@echo off
echo ========================================
echo Farm Management - Post-Cleanup Testing
echo ========================================
echo.
echo Cleanup Date: 2025-10-09 19:42
echo Files Archived: 18 files
echo Testing Started: %date% %time%
echo.

echo [1/5] Checking File Structure...
echo ----------------------------------------
cd /d D:\Code\farm

echo Essential Documentation:
if exist "RBAC_QUICK_START.md" (echo   [OK] RBAC_QUICK_START.md) else (echo   [FAIL] RBAC_QUICK_START.md MISSING!)
if exist "FLUTTER_RBAC_USAGE.md" (echo   [OK] FLUTTER_RBAC_USAGE.md) else (echo   [FAIL] FLUTTER_RBAC_USAGE.md MISSING!)
if exist "README.md" (echo   [OK] README.md) else (echo   [FAIL] README.md MISSING!)
if exist "SEARCH_FEATURE_DOCUMENTATION.md" (echo   [OK] SEARCH_FEATURE_DOCUMENTATION.md) else (echo   [FAIL] SEARCH_FEATURE_DOCUMENTATION.md MISSING!)

echo.
echo Archived Documentation (should NOT exist):
if not exist "RBAC_ADMIN_GUIDE.md" (echo   [OK] RBAC_ADMIN_GUIDE.md archived) else (echo   [WARNING] RBAC_ADMIN_GUIDE.md still exists!)
if not exist "DEBUG_LOGIN.md" (echo   [OK] DEBUG_LOGIN.md archived) else (echo   [WARNING] DEBUG_LOGIN.md still exists!)
if not exist "demo_4color_palette.html" (echo   [OK] demo_4color_palette.html archived) else (echo   [WARNING] demo_4color_palette.html still exists!)

echo.
echo [2/5] Checking Backend...
echo ----------------------------------------
cd /d D:\Code\farm\backend
if exist "server.js" (echo   [OK] server.js exists) else (echo   [FAIL] server.js MISSING!)
if exist "farm_auth.db" (echo   [OK] farm_auth.db exists) else (echo   [FAIL] farm_auth.db MISSING!)
if exist "package.json" (echo   [OK] package.json exists) else (echo   [FAIL] package.json MISSING!)
if exist "test_rbac.js" (echo   [OK] test_rbac.js exists) else (echo   [WARNING] test_rbac.js missing)

echo.
echo [3/5] Checking Archive...
echo ----------------------------------------
if exist "D:\Code\_UNNECESSARY_FILES_FARM\RESTORE_INDEX.md" (echo   [OK] RESTORE_INDEX.md exists) else (echo   [FAIL] RESTORE_INDEX.md MISSING!)
if exist "D:\Code\_UNNECESSARY_FILES_FARM\CLEANUP_2025_10_09.md" (echo   [OK] CLEANUP_2025_10_09.md exists) else (echo   [FAIL] CLEANUP_2025_10_09.md MISSING!)
if exist "D:\Code\_UNNECESSARY_FILES_FARM\rbac_docs" (echo   [OK] rbac_docs/ exists) else (echo   [FAIL] rbac_docs/ MISSING!)
if exist "D:\Code\_UNNECESSARY_FILES_FARM\old_docs" (echo   [OK] old_docs/ exists) else (echo   [FAIL] old_docs/ MISSING!)

echo.
echo [4/5] Counting Files...
echo ----------------------------------------
cd /d D:\Code\farm
for /f %%A in ('dir /b *.md ^| find /c /v ""') do set mdCount=%%A
echo   Documentation files: %mdCount% (expected: 14)

cd /d D:\Code\_UNNECESSARY_FILES_FARM
for /f %%A in ('dir /s /b *.* ^| find /c /v ""') do set archiveCount=%%A
echo   Archived files: %archiveCount% (expected: ~83)

echo.
echo [5/5] Testing Node.js...
echo ----------------------------------------
cd /d D:\Code\farm\backend
node -e "console.log('  [OK] Node.js is working')" 2>nul
if %errorlevel% neq 0 (echo   [FAIL] Node.js not working or not installed!)

echo.
echo ========================================
echo Testing Complete!
echo ========================================
echo.
echo Next Steps:
echo   1. Run: .\restart_backend.bat
echo   2. Build: flutter build web --release --no-source-maps --no-tree-shake-icons
echo   3. Test: python -m http.server 8096 --directory build/web
echo   4. Browse: http://localhost:8096
echo.
echo Full Testing Guide: POST_CLEANUP_TESTING_GUIDE.md
echo Archive Index: D:\Code\_UNNECESSARY_FILES_FARM\RESTORE_INDEX.md
echo.
pause
