#!/usr/bin/env pwsh
# Simple Farm Management Backup Script
# Created: 2025-10-07

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupRoot = "D:\Code\_BACKUPS\farm_build_$timestamp"

Write-Host ""
Write-Host "Starting Complete Backup..." -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Target: $backupRoot" -ForegroundColor White
Write-Host ""

# Create backup directory
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

# 1. Backup compiled output
Write-Host "Backing up compiled output (build\web)..." -ForegroundColor Yellow
$buildDest = "$backupRoot\build_web"
New-Item -ItemType Directory -Path $buildDest -Force | Out-Null
Copy-Item "build\web\*" -Destination $buildDest -Recurse -Force
$buildFileCount = (Get-ChildItem $buildDest -Recurse | Measure-Object).Count
Write-Host "  Compiled output saved: $buildFileCount files" -ForegroundColor Green

# 2. Backup source code
Write-Host ""
Write-Host "Backing up source code (lib\)..." -ForegroundColor Yellow
$libDest = "$backupRoot\lib"
New-Item -ItemType Directory -Path $libDest -Force | Out-Null
Copy-Item "lib\*" -Destination $libDest -Recurse -Force
$libFileCount = (Get-ChildItem $libDest -Recurse | Measure-Object).Count
Write-Host "  Source code saved: $libFileCount files" -ForegroundColor Green

# 3. Backup configuration
Write-Host ""
Write-Host "Backing up configuration..." -ForegroundColor Yellow
$configDest = "$backupRoot\config"
New-Item -ItemType Directory -Path $configDest -Force | Out-Null
Copy-Item "pubspec.yaml" -Destination $configDest -Force
Copy-Item "pubspec.lock" -Destination $configDest -Force
if (Test-Path "analysis_options.yaml") {
    Copy-Item "analysis_options.yaml" -Destination $configDest -Force
}
Write-Host "  Configuration saved" -ForegroundColor Green

# 4. Backup assets
if (Test-Path "assets") {
    Write-Host ""
    Write-Host "Backing up assets..." -ForegroundColor Yellow
    $assetsDest = "$backupRoot\assets"
    New-Item -ItemType Directory -Path $assetsDest -Force | Out-Null
    Copy-Item "assets\*" -Destination $assetsDest -Recurse -Force
    Write-Host "  Assets saved" -ForegroundColor Green
}

# 5. Create metadata file
Write-Host ""
Write-Host "Creating metadata..." -ForegroundColor Yellow
$buildSize = (Get-Item "build\web\main.dart.js").Length
$metadata = @"
# Farm Management Backup (Build Mode)
Created: $timestamp
Source: D:\Code\farm
Backup Location: D:\Code\_BACKUPS\farm_build_$timestamp

## Contents:
- build_web/ - Compiled Flutter web output
- lib/ - Source code
- config/ - Configuration files
- assets/ - Static assets (if exists)

## Key Files:
- build_web/main.dart.js - Compiled JavaScript ($buildSize bytes)
- lib/main.dart - Flutter entry point
- pubspec.yaml - Dependencies

## Restore Instructions:

### Quick restore (compiled only):
xcopy /E /I /Y "$buildDest" "D:\Code\farm\build\web"

### Full restore (with source):
1. Copy build_web/* to D:\Code\farm\build\web\
2. Copy lib/* to D:\Code\farm\lib\
3. Copy config/* to D:\Code\farm\
4. Run: flutter pub get
5. Run: flutter build web

## Notes:
- This is a complete backup
- Can restore both compiled output and source
- Can rebuild from source if needed
"@

$metadata | Out-File "$backupRoot\README.md" -Encoding UTF8
Write-Host "  Metadata created" -ForegroundColor Green

# 6. Summary
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

# 7. Verification
Write-Host ""
Write-Host "Verification:" -ForegroundColor Cyan
$buildFile = Get-Item "$buildDest\main.dart.js"
Write-Host "  main.dart.js: $($buildFile.Length) bytes" -ForegroundColor Green
Write-Host "  Timestamp: $($buildFile.LastWriteTime)" -ForegroundColor Green

Write-Host ""
Write-Host "To restore:" -ForegroundColor Yellow
Write-Host "  .\scripts\restore-backup.ps1 -BackupPath `"$backupRoot`" -RestoreType build" -ForegroundColor White
Write-Host ""
