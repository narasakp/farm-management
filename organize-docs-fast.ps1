# ============================================
# Farm Management - Document Organization
# แยกไฟล์ .md เป็น 2 โฟลเดอร์อย่างรวดเร็ว
# ============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Farm Management - Document Organization" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# สร้างโฟลเดอร์
$projectDocs = "docs_project_specific"
$reusableDocs = "docs_reusable_knowledge"

Write-Host "[1/4] Creating folders..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $projectDocs | Out-Null
New-Item -ItemType Directory -Force -Path $reusableDocs | Out-Null
Write-Host "✅ Folders created" -ForegroundColor Green
Write-Host ""

# ====================================
# 1. เฉพาะโปรเจกต์นี้ (Farm-specific)
# ====================================
$farmSpecific = @(
    "ACTIVE_FILES_ONLY.md",
    "ACTIVITY_FEED_IMPLEMENTATION.md",
    "AFTERNOON_TESTING_CHECKLIST.md",
    "ADVANCED_SEARCH_IMPLEMENTATION.md",
    "CHANGELOG.md",
    "DATA_PRIVACY_PERMISSIONS.md",
    "DEBUG_INSTRUCTIONS.md",
    "DEVELOPMENT_ROADMAP.md",
    "DUPLICATE_PREVENTION_SYSTEM.md",
    "ENHANCEMENTS_SUMMARY.md",
    "EXPORT_SURVEY_FEATURE.md",
    "FACEBOOK_LOGIN_QUICK_START.md",
    "FACEBOOK_LOGIN_RESTART_GUIDE.md",
    "FEATURE_COMPLETION_STATUS.md",
    "FILE_UPLOAD_IMPLEMENTATION_GUIDE.md",
    "FINAL_SUMMARY_OCT16_2025.md",
    "FIREBASE_STORAGE_IMPLEMENTATION_SUMMARY.md",
    "FLUTTER_RBAC_USAGE.md",
    "IMAGE_UPLOAD_UPGRADE_SUMMARY.md",
    "LOGOUT_ICON_FIX.md",
    "MARKET_SCREEN_*.md",
    "MENTION_SYSTEM_IMPLEMENTATION.md",
    "NAVIGATION_AUDIT.md",
    "PHASE_*.md",
    "PLATFORM_CONFIG_GUIDE.md",
    "POST_*.md",
    "PRD_Livestock_Farm_Management_App.md",
    "PRIVACY_*.md",
    "PRODUCTION_MANAGEMENT_*.md",
    "PROGRESS.md",
    "PROJECT_POLICIES.md",
    "QUICK_*.md",
    "RBAC_QUICK_START.md",
    "README.md",
    "README_AFTERNOON.txt",
    "SCREEN_INVENTORY.md",
    "SEARCH_*.md",
    "SENIOR_FRIENDLY_UI_UPDATE.md",
    "SESSION_SUMMARY_*.md",
    "SETUP_INDEXES.md",
    "SMART_BACK_NAVIGATION.md",
    "SOCIAL_*.md",
    "SOFT_DELETE_AND_AUDIT_GUIDE.md",
    "START_HERE.md",
    "TESTING_*.md",
    "TODO_*.md",
    "UI_ENHANCEMENTS_COMPLETE.md",
    "test_debug.md"
)

# ====================================
# 2. ความรู้ทั่วไป (Reusable)
# ====================================
$reusable = @(
    "ARCHITECTURE_ANALYSIS.md",
    "BACKUP_STRATEGY.md",
    "BACKUP_RECOVERY_INFO.md",
    "CODE_OPTIMIZATION_REPORT.md",
    "CONTRIBUTING.md",
    "VERSION_CONTROL_GUIDE.md"
)

Write-Host "[2/4] Moving project-specific documents..." -ForegroundColor Yellow
$movedCount = 0
foreach ($pattern in $farmSpecific) {
    $files = Get-ChildItem -Path . -Filter $pattern -Recurse -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $destPath = Join-Path $projectDocs $file.Name
        if (-not (Test-Path $destPath)) {
            Move-Item -Path $file.FullName -Destination $destPath -Force
            $movedCount++
        }
    }
}
Write-Host "✅ Moved $movedCount project-specific files" -ForegroundColor Green
Write-Host ""

Write-Host "[3/4] Moving reusable documents..." -ForegroundColor Yellow
$movedCount = 0
foreach ($pattern in $reusable) {
    $files = Get-ChildItem -Path . -Filter $pattern -Recurse -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $destPath = Join-Path $reusableDocs $file.Name
        if (-not (Test-Path $destPath)) {
            Move-Item -Path $file.FullName -Destination $destPath -Force
            $movedCount++
        }
    }
}
Write-Host "✅ Moved $movedCount reusable files" -ForegroundColor Green
Write-Host ""

Write-Host "[4/4] Creating index files..." -ForegroundColor Yellow

# สร้าง README สำหรับแต่ละโฟลเดอร์
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$projectReadme = @'
# 📁 Project-Specific Documentation

เอกสารเฉพาะสำหรับ **Farm Management System**

## 📋 Categories

### 🚀 Getting Started
- START_HERE.md
- README.md
- QUICK_START_*.md

### 🔐 Authentication & Security
- FACEBOOK_LOGIN_*.md
- RBAC_QUICK_START.md
- PRIVACY_*.md
- DATA_PRIVACY_PERMISSIONS.md

### 🛠️ Development
- DEVELOPMENT_ROADMAP.md
- FEATURE_COMPLETION_STATUS.md
- PROGRESS.md
- DEBUG_INSTRUCTIONS.md

### 🧪 Testing
- TESTING_PLAN.md
- TESTING_CHECKLIST.md
- TESTING_QUICK_START.md

### 🎨 Features
- MARKET_SCREEN_*.md
- SEARCH_*.md
- SOCIAL_*.md
- PRODUCTION_MANAGEMENT_*.md

### 📊 Reports
- FINAL_SUMMARY_*.md
- SESSION_SUMMARY_*.md
- ENHANCEMENTS_SUMMARY.md

---

**Last Updated:** {0}
'@
$projectReadme = $projectReadme -f $timestamp

$reusableReadme = @'
# 🌍 Reusable Knowledge Base

เอกสารความรู้ทั่วไปที่สามารถนำไปใช้กับโปรเจกต์อื่นได้

## 📚 Categories

### 🏗️ Architecture & Design
- **ARCHITECTURE_ANALYSIS.md** - การวิเคราะห์สถาปัตยกรรมระบบ
- **CODE_OPTIMIZATION_REPORT.md** - เทคนิคการ optimize โค้ด

### 💾 Backup & Recovery
- **BACKUP_STRATEGY.md** - กลยุทธ์การ backup
- **BACKUP_RECOVERY_INFO.md** - วิธีการ recovery

### 🔧 Development Practices
- **VERSION_CONTROL_GUIDE.md** - คู่มือ Git & version control
- **CONTRIBUTING.md** - แนวทางการ contribute

---

**Last Updated:** {0}

## 🎯 How to Use

คัดลอกเอกสารเหล่านี้ไปใช้กับโปรเจกต์อื่น:
```bash
xcopy /E /I "docs_reusable_knowledge" "D:\Code\other-project\docs"
```
'@
$reusableReadme = $reusableReadme -f $timestamp

Set-Content -Path "$projectDocs\README.md" -Value $projectReadme
Set-Content -Path "$reusableDocs\README.md" -Value $reusableReadme

Write-Host "✅ Index files created" -ForegroundColor Green
Write-Host ""

# สรุปผลลัพธ์
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  ✅ ORGANIZATION COMPLETE!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Project-Specific Docs: $projectDocs\" -ForegroundColor Yellow
$projectCount = (Get-ChildItem $projectDocs -File).Count
Write-Host "   Files: $projectCount" -ForegroundColor White
Write-Host ""
Write-Host "🌍 Reusable Knowledge: $reusableDocs\" -ForegroundColor Yellow
$reusableCount = (Get-ChildItem $reusableDocs -File).Count
Write-Host "   Files: $reusableCount" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Review organized files" -ForegroundColor White
Write-Host "2. Update .gitignore if needed" -ForegroundColor White
Write-Host "3. Commit: git add . ; git commit -m 'docs: Organize documentation'" -ForegroundColor White
Write-Host "4. Deploy!" -ForegroundColor White
Write-Host ""
