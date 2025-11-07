# 📦 Farm Management Backup (Build Mode) - วิธีใช้งาน

## 🎯 3 วิธีในการ Backup

### ✅ วิธีที่ 1: Double Click (แนะนำ - ง่ายที่สุด)

#### ขั้นตอน:
1. **สร้าง Shortcut บน Desktop:**
   - Double-click: `D:\Code\farm\scripts\CREATE_BACKUP_SHORTCUT.bat`
   - จะได้ shortcut ชื่อ "🚀 BACKUP FARM" บน Desktop

2. **ใช้งาน:**
   - Double-click shortcut "🚀 BACKUP FARM" บน Desktop
   - รอ 10-30 วินาที
   - เสร็จ! ✅

---

### ✅ วิธีที่ 2: Double Click โดยตรง

**Double-click:**
```
D:\Code\farm\scripts\BACKUP_FARM.bat
```

---

### ✅ วิธีที่ 3: Command Line (สำหรับผู้เชี่ยวชาญ)

**PowerShell:**
```powershell
cd D:\Code\farm
.\scripts\backup-simple.ps1
```

---

## 📁 Backup ไปไหน?

```
D:\Code\_BACKUPS\
├── farm_build_2025-10-12_154500\  # Build Mode Backup
│   ├── build_web\            # Compiled output
│   ├── lib\                  # Source code
│   ├── config\               # Configuration
│   ├── assets\               # Assets
│   └── README.md             # วิธีกู้คืน
├── farm_dev_2025-10-12_154441\    # Dev Mode Backup
└── ...
```

**แต่ละครั้งจะสร้างโฟลเดอร์ใหม่** ด้วย timestamp

---

## 🔄 วิธีกู้คืน

### วิธีที่ 1: ใช้ Script (แนะนำ)
```powershell
cd D:\Code\farm
.\scripts\restore-backup.ps1 -BackupPath "D:\Code\_BACKUPS\farm_build_2025-10-12_154500" -RestoreType build
```

### วิธีที่ 2: Manual (ถ้า Script มีปัญหา)
```powershell
# Copy ทับ build\web
xcopy /E /I /Y "D:\Code\_BACKUPS\farm_build_2025-10-12_154500\build_web" "D:\Code\farm\build\web"
```

---

## ❓ FAQ

### Q: ต้อง Update Script ไหม?
**A: ไม่ต้อง!** ใช้ได้ตลอดไป เพราะ:
- แค่ copy files
- ไม่ depend กับ Flutter version
- ไม่ depend กับโครงสร้างโค้ด

### Q: Backup บ่อยแค่ไหนดี?
**A: แนะนำ:**
- ✅ **ก่อน Deploy:** ทุกครั้ง
- ✅ **ก่อน Update ใหญ่:** เช่น เพิ่ม feature ใหม่
- ✅ **หลัง Fix Bug สำคัญ:** เก็บเวอร์ชันที่แก้แล้ว
- ⚠️ **ไม่แนะนำ:** Backup ทุกวัน (เปลือง disk)

### Q: ลบ Backup เก่าได้ไหม?
**A: ได้!** 
- เก็บแค่ 3-5 เวอร์ชันล่าสุด
- ลบเวอร์ชันเก่าที่ไม่ใช้แล้ว
- หรือย้ายไป External HDD/Cloud

### Q: Backup ไปพร้อมกัน 2 ที่ได้ไหม?
**A: ได้!** แก้ไข script:
```powershell
# แก้ไขบรรทัดนี้ใน backup-simple.ps1
$backupRoot = "D:\Code\_BACKUPS\farm_build_$timestamp"

# เป็น
$backupRoot1 = "D:\Code\_BACKUPS\farm_build_$timestamp"
$backupRoot2 = "E:\Backups\farm_build_$timestamp"  # External drive

# แล้วทำ backup 2 รอบ
```

### Q: ขนาดไฟล์ Backup เท่าไหร่?
**A:** ประมาณ 40-50 MB ต่อครั้ง
- build_web: ~10 MB
- lib: ~500 KB
- assets: ขึ้นอยู่กับรูปภาพ
- config: ~10 KB

### Q: Backup ใช้เวลานานไหม?
**A:** 10-30 วินาที ขึ้นอยู่กับ:
- จำนวนไฟล์
- ความเร็ว HDD/SSD
- CPU load

---

## 🛡️ Best Practices

### ✅ ควรทำ:
- ✅ Backup ก่อน deploy ทุกครั้ง
- ✅ เก็บ 3-5 เวอร์ชันล่าสุด
- ✅ ตั้งชื่อโฟลเดอร์ให้เข้าใจ (timestamp ทำให้แล้ว)
- ✅ ตรวจสอบว่า backup สำเร็จ (ดู file size)

### ❌ ไม่ควรทำ:
- ❌ Backup ทุกวัน (เปลือง disk)
- ❌ เก็บ backup มากกว่า 10 เวอร์ชัน (ถ้าไม่จำเป็น)
- ❌ Backup ไปที่ disk เดียวกับ source (ถ้า disk เสีย หายทั้งคู่)

---

## 📊 เปรียบเทียบวิธี

| วิธี | ความง่าย | ความเร็ว | ความปลอดภัย | แนะนำ |
|------|---------|---------|------------|-------|
| Double-click Desktop Shortcut | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ ดีที่สุด |
| Double-click .bat | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ✅ ดี |
| PowerShell Script | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ✅ สำหรับ Developer |
| Manual Copy | ⭐ | ⭐ | ⭐ | ❌ ไม่แนะนำ |

---

## 🔗 Related Files

- `BACKUP_FARM.bat` - Double-click เพื่อ backup
- `backup-simple.ps1` - Script หลัก
- `CREATE_BACKUP_SHORTCUT.bat` - สร้าง shortcut บน Desktop
- `restore-backup.ps1` - กู้คืน backup

---

**Last Updated:** 2025-10-12  
**Status:** ✅ Ready to use  
**Location:** D:\Code\_BACKUPS  
**Mode:** Build Mode (flutter build web)  
**Maintenance:** ไม่ต้อง update
