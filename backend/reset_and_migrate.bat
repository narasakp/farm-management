@echo off
echo.
echo ========================================
echo   Reset and Run RBAC Migration
echo ========================================
echo.

cd /d D:\Code\farm\backend

echo [1/4] Deleting old migration history...
node -e "const sqlite3 = require('sqlite3').verbose(); const db = new sqlite3.Database('farm_auth.db'); db.run('DELETE FROM migrations_history WHERE filename LIKE \"%%rbac%%\"', (err) => { if (err) console.log('Note:', err.message); else console.log('✅ Cleared migration history'); db.close(); });"

echo.
echo [2/4] Removing old migration file...
if exist migrations\001_rbac_setup.sql (
    ren migrations\001_rbac_setup.sql 001_rbac_setup.sql.bak
    echo ✅ Renamed old migration to .bak
)

echo.
echo [3/4] Running new safe migration...
node migrations\run_migration.js

echo.
echo [4/4] Checking results...
node -e "const sqlite3 = require('sqlite3').verbose(); const db = new sqlite3.Database('farm_auth.db'); db.get('SELECT COUNT(*) as count FROM roles', (err, row) => { if (err) { console.log('❌', err.message); } else { console.log('✅ Roles:', row.count); } db.get('SELECT COUNT(*) as count FROM permissions', (err2, row2) => { if (err2) { console.log('❌', err2.message); } else { console.log('✅ Permissions:', row2.count); } db.close(); }); });"

echo.
echo ========================================
echo   Migration completed!
echo ========================================
echo.
pause
