# Reset and Run RBAC Migration
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Reset and Run RBAC Migration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "D:\Code\farm\backend"

Write-Host "[1/4] Deleting old migration history..." -ForegroundColor Yellow
node -e "const sqlite3 = require('sqlite3').verbose(); const db = new sqlite3.Database('farm_auth.db'); db.run('DELETE FROM migrations_history WHERE filename LIKE `\`"%rbac%`\`"', (err) => { if (err) console.log('Note:', err.message); else console.log('✅ Cleared migration history'); db.close(); });"

Write-Host ""
Write-Host "[2/4] Removing old migration file..." -ForegroundColor Yellow
if (Test-Path "migrations\001_rbac_setup.sql") {
    Rename-Item "migrations\001_rbac_setup.sql" "001_rbac_setup.sql.bak" -Force
    Write-Host "✅ Renamed old migration to .bak" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No old migration file found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[3/4] Running new safe migration..." -ForegroundColor Yellow
node migrations\run_migration.js

Write-Host ""
Write-Host "[4/4] Checking results..." -ForegroundColor Yellow
node -e "const sqlite3 = require('sqlite3').verbose(); const db = new sqlite3.Database('farm_auth.db'); db.get('SELECT COUNT(*) as count FROM roles', (err, row) => { if (err) { console.log('❌', err.message); } else { console.log('✅ Roles:', row.count); } db.get('SELECT COUNT(*) as count FROM permissions', (err2, row2) => { if (err2) { console.log('❌', err2.message); } else { console.log('✅ Permissions:', row2.count); } db.close(); }); });"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Migration completed!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
