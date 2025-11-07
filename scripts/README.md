# 🏗️ Safe Build Script - Flutter Web Build Bug Solution

## 📋 สารบัญ
- [ปัญหาที่แก้ไข](#ปัญหาที่แก้ไข)
- [วิธีใช้งาน](#วิธีใช้งาน)
- [ทำไมต้องมี Script นี้](#ทำไมต้องมี-script-นี้)
- [การทำงาน](#การทำงาน)
- [การแก้ไขปัญหา](#การแก้ไขปัญหา)

---

## 🔴 ปัญหาที่แก้ไข

### Flutter Web Build Bug
**ลักษณะอาการ:**
1. แก้ไข code แล้ว save ไฟล์
2. รัน `flutter build web --release`
3. Build สำเร็จ ขึ้น `√ Built build\web`
4. **แต่เปิด Browser ยังเห็นโค้ดเก่า**
5. Hard Refresh, Incognito Mode, Clear Cache = ไม่ช่วย
6. Build ซ้ำ 10 ครั้ง = ยังไม่ได้

**สาเหตุจริง:**
Flutter compile โค้ดใหม่สำเร็จ แต่ **ไม่ copy ไฟล์จาก `.dart_tool/flutter_build/` ไปที่ `build/web/`**

**ผลกระทบ:**
- ใช้เวลา Debug 3+ ชั่วโมง (ปกติควรใช้ 10 นาที)
- เสียเวลากับ Browser Cache (ซึ่งไม่ใช่ต้นตอปัญหา)
- ไฟล์เก่า (3-7 ชั่วโมง) ถูก serve ต่อไป

**อ้างอิง:** `D:\Code\_KNOWLEDGE_BASE\TROUBLESHOOTING\FLUTTER_WEB_BUILD_CACHE_NIGHTMARE_2025.md`

---

## ✅ วิธีใช้งาน

### 1. Build แบบปกติ (ไม่แนะนำ)
```powershell
flutter build web --release
```
❌ **ปัญหา:** อาจได้ไฟล์เก่า

---

### 2. Build แบบปลอดภัย (แนะนำ) ⭐
```powershell
cd D:\Code\farm
.\scripts\safe-build.ps1
```

✅ **ข้อดี:**
- ✅ ตรวจสอบ timestamp อัตโนมัติ
- ✅ แก้ bug ด้วย manual copy ถ้าเจอ
- ✅ Restart server ที่ port 8096 (Google OAuth)
- ✅ **Server ทำงาน background (ไม่เปิด PowerShell window)**
- ✅ แสดงสถานะละเอียดทุกขั้นตอน
- ✅ **เสียง Beep เมื่อสำเร็จ** 🔔
- ✅ **Windows Notification แจ้งเตือน** 💬
- ✅ แสดงเวลาที่เสร็จ
- ✅ Success Rate: **100%**

---

### 3. ตรวจสอบด้วยตนเอง (สำหรับ Debug)

#### เช็คว่า Build ได้ไฟล์ใหม่หรือเก่า:
```powershell
# ไฟล์ใหม่ (ที่ควรจะได้)
Get-ChildItem ".dart_tool\flutter_build\*\main.dart.js" -Recurse | 
  Select-Object FullName, Length, LastWriteTime

# ไฟล์ที่กำลังใช้
Get-ChildItem "build\web\main.dart.js" | 
  Select-Object Length, LastWriteTime

# ⚠️ ถ้า LastWriteTime ต่างกัน = เจอ Bug!
```

#### แก้ไขด้วย Manual Copy:
```powershell
# Copy ไฟล์ใหม่มาใช้
$source = Get-ChildItem ".dart_tool\flutter_build\*\main.dart.js" -Recurse | 
          Select-Object -First 1
Copy-Item $source.FullName "build\web\main.dart.js" -Force

# Restart Server
taskkill /f /im python.exe
python -m http.server 8096 --directory build/web
```

---

## 🤔 ทำไมต้องมี Script นี้

### ก่อนมี Script
1. ✏️ แก้ไข code (2 นาที)
2. 🔨 `flutter build web` (2 นาที)
3. 🌐 เปิด Browser → เห็นโค้ดเก่า ❌
4. 🔄 Hard Refresh → ยังเก่า ❌
5. 🧹 Clear Cache → ยังเก่า ❌
6. 👤 Incognito Mode → ยังเก่า ❌
7. 🔨 Build ซ้ำ → ยังเก่า ❌
8. 😵 Debug 3+ ชั่วโมง...

**รวม:** 3+ ชั่วโมง 😱

---

### หลังมี Script
1. ✏️ แก้ไข code (2 นาที)
2. 🚀 `.\scripts\safe-build.ps1` (3 นาที)
3. ✅ Script ตรวจสอบและแก้ไข Bug อัตโนมัติ
4. 🌐 เปิด Browser → เห็นโค้ดใหม่ ✅

**รวม:** 5 นาที 🎉

**ประหยัดเวลา:** 97%

---

## 🔧 การทำงาน (7 Steps)

### Step 1: Clean 🧹
```powershell
flutter clean
```
ลบ cache เก่าทิ้ง

---

### Step 2: Build 🔨
```powershell
flutter build web --release --no-source-maps --tree-shake-icons
```
Build Flutter Web แบบ Production

---

### Step 3: ตรวจสอบไฟล์ใน .dart_tool 🔍
```
พบไฟล์ที่: .dart_tool\flutter_build\xxx\main.dart.js
ขนาด: 3.5 MB
เวลา: 11:00:00 AM (ใหม่ล่าสุด)
```

---

### Step 4: ตรวจสอบไฟล์ใน build/web 🔍
```
พบไฟล์ที่: build\web\main.dart.js
ขนาด: 3.5 MB
เวลา: 11:00:00 AM (หรือเก่ากว่า?)
```

---

### Step 5: เปรียบเทียบ Timestamp ⚠️

#### กรณีปกติ (ไม่มี Bug):
```
.dart_tool: 11:00:00 AM
build/web:  11:00:00 AM
ผลต่าง: 0 วินาที ✅
```
→ ไม่ต้องทำอะไร ผ่านไปขั้นตอนถัดไป

---

#### กรณีเจอ Bug 🐛:
```
.dart_tool: 11:00:00 AM (ใหม่)
build/web:  04:00:00 AM (เก่า 7 ชั่วโมง!)
ผลต่าง: 25,200 วินาที ❌
```
→ **Script ทำ Manual Copy อัตโนมัติ!**

```powershell
Copy-Item .dart_tool\...\main.dart.js → build\web\main.dart.js
```

✅ แก้ไขสำเร็จ!

---

### Step 6: Stop Old Server 🔄
```powershell
Get-Process python | Stop-Process -Force
```
ปิด server เก่า (port 8080, 9000, etc.)

---

### Step 7: Start New Server 🚀
```powershell
python -m http.server 8096 --directory build/web
```

✅ Server พร้อมที่ http://localhost:8096

**ทำไมต้อง Port 8096?**
- Google Cloud Console OAuth configured for port 8096
- ไม่สามารถเปลี่ยน port อื่นได้ (OAuth จะ error)

---

## 🚨 การแก้ไขปัญหา

### ปัญหา: Script ไม่รัน
```
cannot be loaded because running scripts is disabled
```

**วิธีแก้:**
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

### ปัญหา: Port 8096 ถูกใช้แล้ว
```
OSError: [WinError 10048] Only one usage of each socket address
```

**วิธีแก้:**
```powershell
# หา Process ที่ใช้ port 8096
netstat -ano | findstr :8096

# ปิด Process (เปลี่ยน PID ตามที่เจอ)
taskkill /f /pid 12396
```

---

### ปัญหา: Browser ยังเห็นโค้ดเก่า

**วิธีแก้ (ทำตามลำดับ):**

#### 1. Clear Site Data (แนะนำสูงสุด)
```
1. กด F12 เปิด DevTools
2. แท็บ Application
3. Clear site data (ขวามือ)
4. Ctrl + Shift + R
```

---

#### 2. Incognito Mode (ง่ายที่สุด)
```
Ctrl + Shift + N → เปิด localhost:8096
```

---

#### 3. Clear Service Worker
```javascript
// Paste ใน Console
navigator.serviceWorker.getRegistrations()
  .then(regs => regs.forEach(reg => reg.unregister()));
caches.keys()
  .then(keys => keys.forEach(key => caches.delete(key)));
location.reload(true);
```

---

## 📊 สถิติความสำเร็จ

| การใช้งาน | จำนวน | Success Rate |
|-----------|-------|--------------|
| Session 1 (2025-10-07) | 1 | 100% ✅ |
| Session 2 (2025-10-07) | 1 | 100% ✅ |
| Session 3 (2025-10-08) | 1 | 100% ✅ |
| **Total** | **3** | **100%** ✅ |

**เวลาที่ประหยัด:** ~9 ชั่วโมง (3 ครั้ง × 3 ชั่วโมง)

---

## 🎯 Best Practices

### สำหรับทุกครั้งที่ Build:
1. ✅ **ใช้ `safe-build.ps1` เสมอ**
2. ✅ **ตรวจสอบ Output ว่ามี "BUG DETECTED" หรือไม่**
3. ✅ **Clear Browser Cache ก่อนทดสอบ**
4. ✅ **ใช้ Incognito Mode สำหรับทดสอบเร็ว**

### สำหรับ Production:
1. ✅ **Run script อย่างน้อย 2 ครั้ง**
2. ✅ **ทดสอบใน 2 browsers (Chrome + Edge)**
3. ✅ **Verify timestamp หลัง build**
4. ✅ **เก็บ Log ของ script ไว้**

---

## 📚 Related Documentation

- [Flutter Web Build Cache Nightmare](D:\Code\_KNOWLEDGE_BASE\TROUBLESHOOTING\FLUTTER_WEB_BUILD_CACHE_NIGHTMARE_2025.md)
- [Browser Cache Issues](D:\Code\_KNOWLEDGE_BASE\TROUBLESHOOTING\BROWSER_CACHE_ISSUES.md)
- [Development Workflow](D:\Code\_KNOWLEDGE_BASE\BEST_PRACTICES\Development_Workflow.md)

---

## 📞 Support

**หากเจอปัญหา:**
1. เช็ค Log ของ Script
2. เช็ค Timestamp ด้วยตนเอง
3. อ่าน [FLUTTER_WEB_BUILD_CACHE_NIGHTMARE_2025.md](D:\Code\_KNOWLEDGE_BASE\TROUBLESHOOTING\FLUTTER_WEB_BUILD_CACHE_NIGHTMARE_2025.md)
4. Manual Copy ตามขั้นตอนด้านบน

---

**Last Updated:** 2025-10-08  
**Version:** 1.0.0  
**Success Rate:** 100% (3/3 successful builds)
