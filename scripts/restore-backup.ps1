#!/usr/bin/env pwsh
# Restore Farm Management Backup Script
# Created: 2025-10-07
# Purpose: Restore from backup

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "build", "source", "config")]
    [string]$RestoreType = "all"
)

Write-Host "`n🔄 Starting Restore..." -ForegroundColor Cyan

# Verify backup exists
if (-not (Test-Path $BackupPath)) {
    Write-Host "❌ Backup path not found: $BackupPath" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Backup: $BackupPath" -ForegroundColor White
Write-Host "🎯 Restore type: $RestoreType`n" -ForegroundColor White

$restored = 0

# Restore build output
if ($RestoreType -eq "all" -or $RestoreType -eq "build") {
    Write-Host "📁 Restoring compiled output..." -ForegroundColor Yellow
    $buildSrc = Join-Path $BackupPath "build_web"
    
    if (Test-Path $buildSrc) {
        # Backup current build first
        if (Test-Path "build\web\main.dart.js") {
            $currentTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            Write-Host "   💾 Backing up current build to build\web_backup_$currentTimestamp\" -ForegroundColor Cyan
            New-Item -ItemType Directory -Path "build\web_backup_$currentTimestamp" -Force | Out-Null
            Copy-Item "build\web\*" -Destination "build\web_backup_$currentTimestamp" -Recurse -Force
        }
        
        # Restore
        New-Item -ItemType Directory -Path "build\web" -Force | Out-Null
        Copy-Item "$buildSrc\*" -Destination "build\web" -Recurse -Force
        
        $mainDartJs = Get-Item "build\web\main.dart.js"
        Write-Host "   ✅ Build restored: $($mainDartJs.Length) bytes @ $($mainDartJs.LastWriteTime)" -ForegroundColor Green
        $restored++
    } else {
        Write-Host "   ⚠️  No build_web found in backup" -ForegroundColor Yellow
    }
}

# Restore source code
if ($RestoreType -eq "all" -or $RestoreType -eq "source") {
    Write-Host "`n📁 Restoring source code..." -ForegroundColor Yellow
    $libSrc = Join-Path $BackupPath "lib"
    
    if (Test-Path $libSrc) {
        # Backup current source first
        if (Test-Path "lib\main.dart") {
            $currentTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            Write-Host "   💾 Backing up current source to lib_backup_$currentTimestamp\" -ForegroundColor Cyan
            Copy-Item "lib" -Destination "lib_backup_$currentTimestamp" -Recurse -Force
        }
        
        # Restore
        Remove-Item "lib\*" -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item "$libSrc\*" -Destination "lib" -Recurse -Force
        
        $fileCount = (Get-ChildItem "lib" -Recurse -File | Measure-Object).Count
        Write-Host "   ✅ Source restored: $fileCount files" -ForegroundColor Green
        $restored++
    } else {
        Write-Host "   ⚠️  No lib found in backup" -ForegroundColor Yellow
    }
}

# Restore configuration
if ($RestoreType -eq "all" -or $RestoreType -eq "config") {
    Write-Host "`n📁 Restoring configuration..." -ForegroundColor Yellow
    $configSrc = Join-Path $BackupPath "config"
    
    if (Test-Path $configSrc) {
        # Backup current config
        if (Test-Path "pubspec.yaml") {
            $currentTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            Copy-Item "pubspec.yaml" -Destination "pubspec.yaml.backup_$currentTimestamp" -Force
        }
        
        # Restore
        if (Test-Path "$configSrc\pubspec.yaml") {
            Copy-Item "$configSrc\pubspec.yaml" -Destination "." -Force
            Write-Host "   ✅ pubspec.yaml restored" -ForegroundColor Green
        }
        if (Test-Path "$configSrc\pubspec.lock") {
            Copy-Item "$configSrc\pubspec.lock" -Destination "." -Force
            Write-Host "   ✅ pubspec.lock restored" -ForegroundColor Green
        }
        if (Test-Path "$configSrc\analysis_options.yaml") {
            Copy-Item "$configSrc\analysis_options.yaml" -Destination "." -Force
            Write-Host "   ✅ analysis_options.yaml restored" -ForegroundColor Green
        }
        $restored++
    } else {
        Write-Host "   ⚠️  No config found in backup" -ForegroundColor Yellow
    }
}

# Restore assets
if ($RestoreType -eq "all") {
    $assetsSrc = Join-Path $BackupPath "assets"
    if (Test-Path $assetsSrc) {
        Write-Host "`n📁 Restoring assets..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "assets" -Force | Out-Null
        Copy-Item "$assetsSrc\*" -Destination "assets" -Recurse -Force
        Write-Host "   ✅ Assets restored" -ForegroundColor Green
        $restored++
    }
}

# Summary
Write-Host "`n" -NoNewline
Write-Host "=====================================`n" -ForegroundColor Cyan

if ($restored -eq 0) {
    Write-Host "⚠️  Nothing restored - check backup path" -ForegroundColor Yellow
} else {
    Write-Host "✅ Restore Complete!" -ForegroundColor Green
    
    if ($RestoreType -eq "all" -or $RestoreType -eq "source" -or $RestoreType -eq "config") {
        Write-Host "`n📝 Next steps:" -ForegroundColor Cyan
        Write-Host "   1. flutter pub get" -ForegroundColor White
        
        if ($RestoreType -eq "source" -or $RestoreType -eq "all") {
            Write-Host "   2. flutter build web --release" -ForegroundColor White
        }
    }
    
    if ($RestoreType -eq "build") {
        Write-Host "`n🌐 Ready to serve:" -ForegroundColor Cyan
        Write-Host "   python -m http.server 8096 --directory build\web" -ForegroundColor White
    }
}

Write-Host ""
