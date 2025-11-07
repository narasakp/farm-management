# 💾 Farm Management Backup - Development Mode

**Created:** 2025-10-12  
**Purpose:** Quick and easy backup for development mode (flutter run)

---

## 🎯 Quick Start

### **Option 1: Desktop Shortcut (Easiest)**

1. **Create shortcut:**
   ```
   Double-click: D:\Code\farm\scripts\CREATE_DESKTOP_BACKUP_SHORTCUT.bat
   ```

2. **Use shortcut:**
   ```
   Double-click: Desktop\Backup Farm (Dev).lnk
   ```

---

### **Option 2: Direct Run**

```powershell
# Double-click this file:
D:\Code\farm\scripts\BACKUP_FARM_DEV.bat
```

---

### **Option 3: Command Line**

```powershell
cd D:\Code\farm
.\scripts\BACKUP_FARM_DEV.bat
```

---

## 📦 What Gets Backed Up?

### **Source Code:**
- ✅ `lib/` - Flutter Dart code
- ✅ `backend/` - Node.js server code
- ✅ `web/` - Web assets (index.html, etc.)
- ✅ `assets/` - Images, fonts, etc.

### **Database:**
- ✅ `backend/farm_auth.db` - User accounts & data

### **Configuration:**
- ✅ `pubspec.yaml` - Flutter dependencies
- ✅ `package.json` - Backend dependencies
- ✅ `.env` - Environment variables

### **Documentation:**
- ✅ All `.md` files

### **NOT Backed Up (Saves Space):**
- ❌ `build/` - Compiled files (can rebuild)
- ❌ `node_modules/` - Dependencies (can reinstall)
- ❌ `.dart_tool/` - Build cache

---

## 📍 Backup Location

```
D:\Code\_BACKUPS\farm_dev_YYYY-MM-DD_HHMMSS\
├── lib/               # Flutter source code
├── backend/           # Backend server
├── config/            # Configuration files
├── web/               # Web assets
├── assets/            # Static assets
├── docs/              # Documentation
└── README.md          # Backup information
```

---

## 🔄 How to Restore

### **Full Restore:**

1. **Copy backup back:**
   ```powershell
   # From backup folder:
   xcopy /E /I /Y lib D:\Code\farm\lib
   xcopy /E /I /Y backend D:\Code\farm\backend
   xcopy /E /I /Y web D:\Code\farm\web
   xcopy /E /I /Y assets D:\Code\farm\assets
   ```

2. **Install dependencies:**
   ```powershell
   # Flutter
   cd D:\Code\farm
   flutter pub get

   # Backend
   cd D:\Code\farm\backend
   npm install
   ```

3. **Start servers:**
   ```powershell
   cd D:\Code\farm
   # Terminal 1: node backend\server.js
   # Terminal 2: flutter run -d chrome --web-port=8096
   ```

---

### **Quick Database Restore:**

```powershell
copy "backup\backend\farm_auth.db" "D:\Code\farm\backend\farm_auth.db"
```

---

## ⚙️ Backup Frequency

### **Recommended:**
- ✅ **Daily:** Before major changes
- ✅ **Before:** Deployment
- ✅ **After:** Major features complete

### **Automatic (Optional):**
```powershell
# Create scheduled task to backup daily at 6 PM
schtasks /create /tn "Farm Backup" /tr "D:\Code\farm\scripts\BACKUP_FARM_DEV.bat" /sc daily /st 18:00
```

---

## 🎯 Differences: Dev vs Production Backup

| Feature | Dev Backup | Production Backup |
|---------|------------|-------------------|
| **Source Code** | ✅ Yes | ✅ Yes |
| **Build Files** | ❌ No | ✅ Yes (build/web) |
| **Database** | ✅ Yes | ✅ Yes |
| **node_modules** | ❌ No | ❌ No |
| **Size** | ~5-10 MB | ~10-20 MB |
| **Purpose** | Development | Deployment |

---

## 📊 Backup Script Files

| File | Purpose |
|------|---------|
| `BACKUP_FARM_DEV.bat` | Main backup script (double-click this) |
| `backup-dev.ps1` | PowerShell backup logic |
| `CREATE_DESKTOP_BACKUP_SHORTCUT.bat` | Create desktop shortcut |
| `README_BACKUP_DEV.md` | This file |

---

## 💡 Tips

### **Before Backup:**
- ✅ Save all files (`Ctrl + K, S`)
- ✅ Commit to git (optional)
- ✅ Close unnecessary programs

### **After Backup:**
- ✅ Verify backup folder exists
- ✅ Check README.md in backup
- ✅ Test restore if critical

### **Disk Space:**
- Each backup: ~5-10 MB
- Keep last 5-10 backups
- Delete old backups monthly

---

## 🚀 Quick Commands

```powershell
# Backup
.\scripts\BACKUP_FARM_DEV.bat

# Create desktop shortcut
.\scripts\CREATE_DESKTOP_BACKUP_SHORTCUT.bat

# View backups
explorer D:\Code\_BACKUPS

# Delete old backups (keep last 5)
Get-ChildItem "D:\Code\_BACKUPS" | 
  Sort-Object CreationTime -Descending | 
  Select-Object -Skip 5 | 
  Remove-Item -Recurse -Force
```

---

## ✅ Success Indicators

**After running backup, you should see:**

```
=====================================
 Farm Management Backup (Dev Mode)
=====================================

Starting backup...

Backing up source code (lib\)...
  Source code saved: 150 files

Backing up backend...
  Backend saved: 25 files

Backing up database...
  Database saved: 42.5 KB

Backing up configuration...
  Configuration saved

Creating metadata...
  Metadata created

=====================================
Backup Complete!
=====================================

Summary:
  Location: D:\Code\_BACKUPS\farm_dev_2025-10-12_153000
  Total files: 200
  Total size: 8.5 MB

Verification:
  lib/ folder: 150 files
  backend/ folder: 25 files
  Database: Backed up
```

---

**Created with ❤️ for easy development backup!** 🚀
