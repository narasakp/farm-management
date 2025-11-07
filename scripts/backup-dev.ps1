#!/usr/bin/env pwsh
# Farm Management Backup Script - Development Mode
# Created: 2025-10-12
# Backs up source code, database, and configuration (no build files)

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupRoot = "D:\Code\_BACKUPS\farm_dev_$timestamp"

Write-Host ""
Write-Host "Starting Development Backup..." -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Target: $backupRoot" -ForegroundColor White
Write-Host ""

# Create backup directory
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

# 1. Backup source code (lib/)
Write-Host "Backing up source code (lib\)..." -ForegroundColor Yellow
$libDest = "$backupRoot\lib"
New-Item -ItemType Directory -Path $libDest -Force | Out-Null
Copy-Item "lib\*" -Destination $libDest -Recurse -Force
$libFileCount = (Get-ChildItem $libDest -Recurse -File | Measure-Object).Count
Write-Host "  Source code saved: $libFileCount files" -ForegroundColor Green

# 2. Backup backend (backend/)
Write-Host ""
Write-Host "Backing up backend..." -ForegroundColor Yellow
$backendDest = "$backupRoot\backend"
New-Item -ItemType Directory -Path $backendDest -Force | Out-Null

# Copy backend files (exclude node_modules)
Get-ChildItem "backend" -File | ForEach-Object {
    Copy-Item $_.FullName -Destination $backendDest -Force
}

# Copy backend subdirectories (exclude node_modules)
Get-ChildItem "backend" -Directory | Where-Object { $_.Name -ne "node_modules" } | ForEach-Object {
    Copy-Item $_.FullName -Destination $backendDest -Recurse -Force
}

$backendFileCount = (Get-ChildItem $backendDest -Recurse -File | Measure-Object).Count
Write-Host "  Backend saved: $backendFileCount files" -ForegroundColor Green

# 3. Backup database
Write-Host ""
Write-Host "Backing up database..." -ForegroundColor Yellow
if (Test-Path "backend\farm_auth.db") {
    Copy-Item "backend\farm_auth.db" -Destination "$backendDest\farm_auth.db" -Force
    $dbSize = [math]::Round((Get-Item "backend\farm_auth.db").Length / 1KB, 2)
    Write-Host "  Database saved: $dbSize KB" -ForegroundColor Green
} else {
    Write-Host "  Database not found (skipped)" -ForegroundColor Yellow
}

# 4. Backup configuration files
Write-Host ""
Write-Host "Backing up configuration..." -ForegroundColor Yellow
$configDest = "$backupRoot\config"
New-Item -ItemType Directory -Path $configDest -Force | Out-Null

$configFiles = @("pubspec.yaml", "pubspec.lock", "analysis_options.yaml", ".env")
foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination $configDest -Force
    }
}
Write-Host "  Configuration saved" -ForegroundColor Green

# 5. Backup web files (if exists)
if (Test-Path "web") {
    Write-Host ""
    Write-Host "Backing up web files..." -ForegroundColor Yellow
    $webDest = "$backupRoot\web"
    New-Item -ItemType Directory -Path $webDest -Force | Out-Null
    Copy-Item "web\*" -Destination $webDest -Recurse -Force
    Write-Host "  Web files saved" -ForegroundColor Green
}

# 6. Backup assets (if exists)
if (Test-Path "assets") {
    Write-Host ""
    Write-Host "Backing up assets..." -ForegroundColor Yellow
    $assetsDest = "$backupRoot\assets"
    New-Item -ItemType Directory -Path $assetsDest -Force | Out-Null
    Copy-Item "assets\*" -Destination $assetsDest -Recurse -Force
    Write-Host "  Assets saved" -ForegroundColor Green
}

# 7. Backup documentation
Write-Host ""
Write-Host "Backing up documentation..." -ForegroundColor Yellow
$docsDest = "$backupRoot\docs"
New-Item -ItemType Directory -Path $docsDest -Force | Out-Null

$docFiles = Get-ChildItem -Filter "*.md" | Where-Object { $_.Name -ne "README.md" }
foreach ($doc in $docFiles) {
    Copy-Item $doc.FullName -Destination $docsDest -Force
}
Write-Host "  Documentation saved: $($docFiles.Count) files" -ForegroundColor Green

# 8. Create metadata file
Write-Host ""
Write-Host "Creating metadata..." -ForegroundColor Yellow

$metadata = @"
# Farm Management Development Backup
Created: $timestamp
Source: D:\Code\farm
Mode: Development (flutter run)

## Contents:
- lib/ - Flutter source code
- backend/ - Backend server (Node.js + SQLite)
- config/ - Configuration files (pubspec.yaml, .env, etc.)
- web/ - Web assets (index.html, manifest.json, etc.)
- assets/ - Static assets (images, fonts, etc.)
- docs/ - Documentation files

## Database:
- farm_auth.db - User authentication database

## Key Files:
- lib/main.dart - Flutter entry point
- backend/server.js - Backend server
- pubspec.yaml - Flutter dependencies
- package.json - Backend dependencies

## Restore Instructions:

### Full Restore:
1. Copy all folders back to D:\Code\farm\
2. Install Flutter dependencies:
   cd D:\Code\farm
   flutter pub get

3. Install Backend dependencies:
   cd D:\Code\farm\backend
   npm install

4. Start servers:
   cd D:\Code\farm
   .\scripts\START_ALL.bat

### Partial Restore:
- Source only: Copy lib/ folder
- Backend only: Copy backend/ folder
- Database only: Copy backend/farm_auth.db

## Development Mode:
- Uses flutter run (not flutter build)
- No build/web folder needed
- Hot reload enabled (press 'r')
- Hot restart enabled (press 'R')

## Notes:
- This is a complete development backup
- Can restore and continue development immediately
- Database includes all user accounts and data
- No compiled/build files (saves space)
"@

$metadata | Out-File "$backupRoot\README.md" -Encoding UTF8
Write-Host "  Metadata created" -ForegroundColor Green

# 9. Summary
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Backup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Location: $backupRoot" -ForegroundColor White

$totalFiles = (Get-ChildItem $backupRoot -Recurse -File | Measure-Object).Count
$totalSize = [math]::Round((Get-ChildItem $backupRoot -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
Write-Host "  Total files: $totalFiles" -ForegroundColor White
Write-Host "  Total size: $totalSize MB" -ForegroundColor White

# 10. Verification
Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan
Write-Host "  lib/ folder: $libFileCount files" -ForegroundColor Green
Write-Host "  backend/ folder: $backendFileCount files" -ForegroundColor Green
if (Test-Path "$backendDest\farm_auth.db") {
    Write-Host "  Database: Backed up" -ForegroundColor Green
}

Write-Host ""
Write-Host "Backup saved to:" -ForegroundColor Yellow
Write-Host "  $backupRoot" -ForegroundColor White
Write-Host ""
Write-Host "To restore, copy folders back to D:\Code\farm\" -ForegroundColor Cyan
Write-Host ""
