# Privacy Audit Report Generator
param(
    [string]$ReportType = 'today'
)

$dbPath = "D:\Code\farm\backend\farm_auth.db"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Privacy Audit Report" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if ($ReportType -eq 'today') {
    Write-Host "Report: Today" -ForegroundColor Green
    Write-Host ""
    $query = "SELECT datetime(created_at, '+7 hours') as Time, username as User, action as Action, resource_id as FarmerID, details as Details FROM audit_logs WHERE action IN ('CLICK_TO_REVEAL', 'EMERGENCY_ACCESS', 'VIEW_SENSITIVE_DATA') AND DATE(created_at, '+7 hours') = DATE('now', '+7 hours') ORDER BY created_at DESC;"
    sqlite3 -header -column $dbPath $query
}
elseif ($ReportType -eq 'week') {
    Write-Host "Report: This Week" -ForegroundColor Green
    Write-Host ""
    $query = "SELECT DATE(created_at, '+7 hours') as Date, COUNT(CASE WHEN action = 'CLICK_TO_REVEAL' THEN 1 END) as ClickReveal, COUNT(CASE WHEN action = 'EMERGENCY_ACCESS' THEN 1 END) as Emergency, COUNT(*) as Total FROM audit_logs WHERE action IN ('CLICK_TO_REVEAL', 'EMERGENCY_ACCESS', 'VIEW_SENSITIVE_DATA') AND created_at >= datetime('now', '-7 days') GROUP BY DATE(created_at, '+7 hours') ORDER BY Date DESC;"
    sqlite3 -header -column $dbPath $query
}
elseif ($ReportType -eq 'emergency') {
    Write-Host "Report: Emergency Access" -ForegroundColor Red
    Write-Host ""
    $query = "SELECT datetime(created_at, '+7 hours') as Time, username as User, resource_id as FarmerID, details as Details FROM audit_logs WHERE action = 'EMERGENCY_ACCESS' ORDER BY created_at DESC LIMIT 20;"
    sqlite3 -header -column $dbPath $query
}
elseif ($ReportType -eq 'top-users') {
    Write-Host "Report: Top Users" -ForegroundColor Yellow
    Write-Host ""
    $query = "SELECT username as User, role as Role, COUNT(*) as Count, COUNT(DISTINCT resource_id) as Farmers FROM audit_logs WHERE action IN ('CLICK_TO_REVEAL', 'EMERGENCY_ACCESS') AND created_at >= datetime('now', '-30 days') GROUP BY username, role ORDER BY Count DESC LIMIT 10;"
    sqlite3 -header -column $dbPath $query
}
elseif ($ReportType -eq 'all') {
    Write-Host "Report: All Records" -ForegroundColor Magenta
    Write-Host ""
    $query = "SELECT datetime(created_at, '+7 hours') as Time, username as User, action as Action, resource_id as FarmerID, details as Details FROM audit_logs WHERE action IN ('CLICK_TO_REVEAL', 'EMERGENCY_ACCESS', 'VIEW_SENSITIVE_DATA') ORDER BY created_at DESC LIMIT 50;"
    sqlite3 -header -column $dbPath $query
}
else {
    Write-Host "Invalid report type: $ReportType" -ForegroundColor Red
    Write-Host "Available: today, week, emergency, top-users, all" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Done!" -ForegroundColor Green
Write-Host ""
