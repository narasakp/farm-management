# 📁 Farm Scripts Directory - คู่มือไฟล์ทั้งหมด

**Last Updated:** 2025-10-07 17:25  
**Total Files:** 19 files (ลบ 4 ไฟล์ที่ไม่ใช้แล้ว)

---

## 🎯 Quick Reference - ไฟล์สำคัญบน Desktop

| Desktop Icon | ไฟล์ที่เรียก | ทำอะไร | เวลา |
|--------------|--------------|---------|------|
| **BACKUP_FARM** | `BACKUP_FARM.bat` → `backup-simple.ps1` | Backup ทั้งหมด (build + source + config) | 10-30s |
| **SAFE_BUILD** | `SAFE_BUILD.bat` → `safe-build-v2.ps1` | Build แบบปลอดภัย (auto-verify + auto-fix) | 45-55s |

---

## 📦 Backup Scripts (6 files)

### ✅ ใช้งานหลัก:
| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `BACKUP_FARM.bat` | Batch | 489 B | **Double-click เพื่อ backup** (เรียก backup-simple.ps1) |
| `backup-simple.ps1` | PowerShell | 4.3 KB | Script หลักสำหรับ backup |
| `restore-backup.ps1` | PowerShell | 5.6 KB | Script สำหรับกู้คืน backup |

### ✅ ใช้งานเสริม:
| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `CREATE_BACKUP_SHORTCUT_FINAL.bat` | Batch | 1.9 KB | สร้าง shortcut BACKUP_FARM บน Desktop (รองรับ OneDrive) |
| `README_BACKUP.md` | Markdown | 5.6 KB | คู่มือใช้งาน backup ครบถ้วน |

---

## 🔨 Build Scripts (5 files)

### ✅ ใช้งานหลัก:
| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `SAFE_BUILD.bat` | Batch | 543 B | **Double-click เพื่อ build** (เรียก safe-build-v2.ps1) |
| `safe-build-v2.ps1` | PowerShell | 5.2 KB | Script หลักสำหรับ safe build |

### ✅ ใช้งานเสริม:
| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `CREATE_BUILD_SHORTCUT.bat` | Batch | 1.9 KB | สร้าง shortcut SAFE_BUILD บน Desktop |
| `README_SAFE_BUILD.md` | Markdown | 6.8 KB | คู่มือใช้งาน safe-build |
| `TEST_SAFE_BUILD.md` | Markdown | 8.1 KB | วิธีทดสอบว่า safe-build ทำงานได้ดี |

---

## 🗄️ Database/Survey Scripts (3 files)

| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `check_surveys.js` | JavaScript | 4.5 KB | ตรวจสอบข้อมูล surveys ใน database |
| `seed_surveys.js` | JavaScript | 11 KB | เพิ่มข้อมูล surveys ตัวอย่าง |
| `health-check.js` | JavaScript | 6.5 KB | ตรวจสอบสุขภาพของ database |

---

## 🚀 Server Management Scripts (5 files)

| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `start-farm-system.bat` | Batch | 1.7 KB | เริ่มระบบทั้งหมด (backend + frontend) |
| `quick-restart.bat` | Batch | 1.9 KB | Restart server อย่างรวดเร็ว |
| `simple-health-check.bat` | Batch | 1.4 KB | ตรวจสอบว่า server ทำงานไหม |
| `server-monitor.js` | JavaScript | 8.7 KB | Monitor server อัตโนมัติ |
| `server-monitor.log` | Log | 265 B | Log ของ server monitor |

---

## 🎨 UI/Desktop Scripts (1 file)

| File | Type | ขนาด | ทำอะไร |
|------|------|------|---------|
| `create-shortcuts.bat` | Batch | 1.4 KB | สร้าง shortcuts อื่นๆ บน Desktop |

---

## 🗂️ การจัดกลุ่มตามการใช้งาน

### 🔥 ใช้บ่อย (Desktop Icons):
```
BACKUP_FARM.bat          ← Double-click บน Desktop
SAFE_BUILD.bat           ← Double-click บน Desktop
```

### ⚙️ Setup/Configuration (ใช้ครั้งเดียว):
```
CREATE_BACKUP_SHORTCUT_FINAL.bat  ← สร้าง BACKUP_FARM icon
CREATE_BUILD_SHORTCUT.bat         ← สร้าง SAFE_BUILD icon
create-shortcuts.bat              ← สร้าง shortcuts อื่นๆ
```

### 📚 Documentation (อ่านเมื่อต้องการ):
```
README_BACKUP.md         ← คู่มือ backup
README_SAFE_BUILD.md     ← คู่มือ safe-build
TEST_SAFE_BUILD.md       ← วิธีทดสอบ
README_SCRIPTS.md        ← ไฟล์นี้
```

### 🛠️ Core Scripts (ถูกเรียกใช้อัตโนมัติ):
```
backup-simple.ps1        ← Backup engine
restore-backup.ps1       ← Restore engine
safe-build-v2.ps1        ← Build engine
```

### 🗄️ Database/Server (ใช้เมื่อต้องการ):
```
check_surveys.js         ← ตรวจสอบ database
seed_surveys.js          ← เพิ่มข้อมูลตัวอย่าง
health-check.js          ← ตรวจสุขภาพ
server-monitor.js        ← Monitor server
start-farm-system.bat    ← Start ทั้งระบบ
quick-restart.bat        ← Restart server
simple-health-check.bat  ← Health check แบบง่าย
```

---

## 🗑️ ไฟล์ที่ลบไปแล้ว (2025-10-07)

| ไฟล์ที่ลบ | เหตุผล |
|----------|--------|
| `backup-complete.ps1` | มี syntax error |
| `CREATE_BACKUP_SHORTCUT.bat` | มี emoji ทำให้ไม่ทำงาน |
| `CREATE_BACKUP_SHORTCUT_V2.bat` | ไม่รองรับ OneDrive Desktop |
| `safe-build.ps1` | มี encoding error |

**ทั้งหมดถูกแทนที่ด้วย version ที่ทำงานได้**

---

## 💡 Quick Start Guide

### ครั้งแรก (Setup):
```batch
1. Double-click: CREATE_BACKUP_SHORTCUT_FINAL.bat
2. Double-click: CREATE_BUILD_SHORTCUT.bat
```
**ผลลัพธ์:** Desktop จะมี BACKUP_FARM และ SAFE_BUILD icons

---

### การใช้งานปกติ:

#### หลังแก้โค้ด:
```
1. Double-click: SAFE_BUILD (บน Desktop)
2. รอ ~50 วินาที
3. คลิก Test URL ที่แสดง
```

#### ก่อน Deploy:
```
1. Double-click: BACKUP_FARM (บน Desktop)
2. รอ ~20 วินาที
3. Push to GitHub
```

---

## 📊 สถิติไฟล์

```
Total Files:        19 files
Total Size:         ~80 KB
Deleted:            4 files (2025-10-07)
Active Scripts:     15 files
Documentation:      4 files (.md)

Breakdown:
├── Backup Scripts:     5 files (+ 1 doc)
├── Build Scripts:      2 files (+ 3 docs)
├── Database Scripts:   3 files
├── Server Scripts:     4 files (+ 1 log)
└── UI Scripts:         1 file
```

---

## 🎯 File Naming Convention

```
UPPERCASE.bat          → User-facing (Double-click)
lowercase.ps1          → Core scripts (Called by .bat)
kebab-case.js          → Node.js scripts
README_*.md            → Documentation
TEST_*.md              → Testing guides
```

---

## ⚠️ ข้อควรระวัง

### ❌ อย่าลบไฟล์เหล่านี้:
- `backup-simple.ps1` - BACKUP_FARM ใช้
- `safe-build-v2.ps1` - SAFE_BUILD ใช้
- `restore-backup.ps1` - กู้คืน backup

### ✅ ลบได้ถ้าไม่ใช้:
- `server-monitor.log` - log file (สร้างใหม่ได้)
- Documentation files - แต่แนะนำเก็บไว้

---

## 🔄 Maintenance

### ตรวจสอบไฟล์ที่ไม่ใช้:
```powershell
# ดูไฟล์ที่ไม่ได้เปิดนานแล้ว
Get-ChildItem "D:\Code\farm\scripts\" | 
    Where-Object { $_.LastAccessTime -lt (Get-Date).AddMonths(-3) } |
    Select-Object Name, LastAccessTime
```

### Cleanup:
```powershell
# ลบ log files เก่า
Remove-Item "D:\Code\farm\scripts\*.log" -Force
```

---

**Status:** ✅ Clean and organized  
**Last Cleanup:** 2025-10-07  
**Next Review:** 2026-01-07 (3 months)
