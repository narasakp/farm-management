# 🛡️ Progressive Lock Testing Guide

**Created:** 2025-10-22  
**Status:** ✅ Production Ready  
**Test Scripts Location:** `D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\`

---

## 📑 Table of Contents

1. [Overview](#-overview)
2. [Progressive Lock Levels](#-progressive-lock-levels)
3. [Testing Scripts](#-testing-scripts)
   - [Check Lock Status](#1-check-lock-status)
   - [Simulate Lock Levels](#2-simulate-lock-levels)
   - [Unlock Account](#3-unlock-account)
4. [Testing Workflow](#-testing-workflow)
5. [Expected Error Messages](#-expected-error-messages)
6. [Troubleshooting](#-troubleshooting)
7. [Database Schema](#-database-schema)
8. [Success Criteria](#-success-criteria)

---

## 🎯 Overview

Progressive Lock เป็นระบบป้องกัน Brute Force Attack ที่เพิ่มระยะเวลา Lock ขึ้นทุกครั้งที่ถูก Lock ซ้ำ

**Test Scripts:** ไฟล์ทดสอบถูกย้ายไปที่ `D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\` เพื่อความเป็นระเบียบ

## 📊 Progressive Lock Levels

| Lock Count | Duration | Use Case |
|------------|----------|----------|
| **1st Lock** | 15 minutes | ผู้ใช้ลืมรหัสผ่าน |
| **2nd Lock** | 30 minutes | ยังอาจเป็นผู้ใช้จริง |
| **3rd Lock** | 1 hour | น่าสงสัย |
| **4th+ Lock** | 24 hours | แน่นอนว่าเป็น Attack |

---

## 🧪 Testing Scripts

### 1. **Check Lock Status**
```bash
# ใน backend directory
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\test_progressive_lock.js <username>

# หรือ cd ไปที่ test scripts directory
cd D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts
node test_progressive_lock.js <username>
```

**Example:**
```bash
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\test_progressive_lock.js nara
```

**Output:**
```
══════════════════════════════════════════════════════════════════════
👤 Username: nara
🔢 Failed Attempts: 5/5
🔒 Lock Status: LOCKED
📊 Lock Count: 2 (Progressive Level)
📅 Locked Until: 2025-10-22T01:30:00.000Z
⏰ Current Time: 2025-10-22T01:15:00.000Z
⏳ Time Remaining: 15 นาที

❌ Account is LOCKED (Level 2)

📈 Progressive Lock Levels:
   Level 1: 15 minutes ✅
   Level 2: 30 minutes ✅
   Level 3: 1 hour     ⬜
   Level 4+: 24 hours  ⬜
══════════════════════════════════════════════════════════════════════
```

---

### 2. **Simulate Lock Levels**
```bash
# ใน backend directory
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\simulate_locks.js <username> <lock_level>

# หรือ cd ไปที่ test scripts directory
cd D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts
node simulate_locks.js <username> <lock_level>
```

**Examples:**
```bash
# Simulate 1st lock (15 minutes)
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\simulate_locks.js nara 1

# Simulate 2nd lock (30 minutes)
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\simulate_locks.js nara 2

# Simulate 3rd lock (1 hour)
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\simulate_locks.js nara 3

# Simulate 4th lock (24 hours)
node D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\simulate_locks.js nara 4
```

**Output:**
```
🧪 Simulating Lock Level 2 for: nara

✅ Lock simulation applied successfully!

📋 Lock Details:
   Username: nara
   Lock Level: 2
   Duration: 30 minutes
   Locked Until: 2025-10-22T01:30:00.000Z

📝 Next Steps:
   1. Try to login as "nara" to see the lock message
   2. Check status: node test_progressive_lock.js nara
   3. Unlock: node unlock_account.js nara
```

---

### 3. **Unlock Account**
```bash
node unlock_account.js <username>
```

**Example:**
```bash
node unlock_account.js nara
```

**Output:**
```
🔓 Unlocking account: nara

✅ Account unlocked successfully!
   - Failed attempts reset to 0
   - Lock removed
   - Lock count reset to 0 (Progressive lock cleared)

✅ User "nara" can now login.
```

---

## 🔄 Testing Workflow

### **Scenario 1: Test All Lock Levels**

```bash
# Set test scripts path for convenience
cd D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts

# 1. Simulate 1st lock (15 min)
node simulate_locks.js testuser 1
node test_progressive_lock.js testuser
# Try login → See "ครั้งที่ 1, รออีก 15 นาที"

# 2. Simulate 2nd lock (30 min)
node simulate_locks.js testuser 2
# Try login → See "ครั้งที่ 2, รออีก 30 นาที"

# 3. Simulate 3rd lock (1 hour)
node simulate_locks.js testuser 3
# Try login → See "ครั้งที่ 3, รออีก 1 ชั่วโมง"

# 4. Simulate 4th lock (24 hours)
node simulate_locks.js testuser 4
# Try login → See "ครั้งที่ 4, รออีก 24 ชั่วโมง, ติดต่อผู้ดูแลระบบ"

# 5. Reset everything (unlock_account.js still in backend directory)
cd D:\Code\farm\backend
node unlock_account.js testuser
```

---

### **Scenario 2: Test Real Login Flow**

```bash
# 1. Make sure account is unlocked
node unlock_account.js testuser

# 2. Login with wrong password 5 times
# → Account locked for 15 minutes (Level 1)

# 3. Wait 15 minutes OR unlock manually
node unlock_account.js testuser

# 4. Login with wrong password 5 times AGAIN
# → Account locked for 30 minutes (Level 2)

# 5. Continue pattern...
```

---

## 📋 Expected Error Messages

### **Lock Level 1 (15 min):**
```
❌ เข้าสู่ระบบไม่สำเร็จ

บัญชีถูกล็อคชั่วคราว (ครั้งที่ 1)
กรุณารออีก 15 นาที แล้วลองใหม่อีกครั้ง

[  ตกลง  ]
```

### **Lock Level 2 (30 min):**
```
❌ เข้าสู่ระบบไม่สำเร็จ

บัญชีถูกล็อคชั่วคราว (ครั้งที่ 2)
กรุณารออีก 30 นาที แล้วลองใหม่อีกครั้ง

[  ตกลง  ]
```

### **Lock Level 3 (1 hour):**
```
❌ เข้าสู่ระบบไม่สำเร็จ

บัญชีถูกล็อคชั่วคราว (ครั้งที่ 3)
กรุณารออีก 1 ชั่วโมง แล้วลองใหม่อีกครั้ง

[  ตกลง  ]
```

### **Lock Level 4+ (24 hours):**
```
❌ เข้าสู่ระบบไม่สำเร็จ

บัญชีถูกล็อค 24 ชั่วโมง (ครั้งที่ 4)

กรุณารออีก 24 ชั่วโมง หรือติดต่อผู้ดูแลระบบ:
📧 อีเมล: admin@farm.com
📱 โทร: 02-xxx-xxxx
💬 LINE: @farmadmin

[  ตกลง  ]
```

**Note:** ข้อมูลติดต่อผู้ดูแลระบบสามารถแก้ไขได้ที่ `.env` file:
```env
ADMIN_EMAIL=admin@farm.com
ADMIN_PHONE=02-xxx-xxxx
ADMIN_LINE=@farmadmin
```

---

## 🛠️ Troubleshooting

### **Problem: lock_count column doesn't exist**
```bash
# Solution: Restart server (auto-migration will run)
node server.js
```

### **Problem: Lock not expiring**
```bash
# Check current time vs locked_until
node test_progressive_lock.js <username>

# Manual unlock if needed
node unlock_account.js <username>
```

### **Problem: Lock count not increasing**
```bash
# Check database
sqlite3 farm_auth.db "SELECT username, lock_count, locked_until FROM users WHERE username='<username>'"

# Try simulate to test
node simulate_locks.js <username> 2
```

---

## 📊 Database Schema

```sql
-- users table (relevant columns)
CREATE TABLE users (
  ...
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until DATETIME,
  lock_count INTEGER DEFAULT 0,  -- Progressive lock counter
  ...
);
```

---

## 🎯 Success Criteria

- ✅ Lock Level 1: 15 minutes
- ✅ Lock Level 2: 30 minutes  
- ✅ Lock Level 3: 1 hour
- ✅ Lock Level 4+: 24 hours
- ✅ Message shows correct lock count
- ✅ Time displayed correctly (นาที vs ชั่วโมง)
- ✅ Unlock resets lock_count to 0

---

**Status:** ✅ READY FOR TESTING  
**Date:** 2025-10-22  
**Version:** 1.0

---

## 📂 Files Location

### **Test Scripts** (Archived)
```
D:\Code\_UNNECESSARY_FILES_FARM\backend_test_scripts\
├── test_progressive_lock.js   # Check lock status
└── simulate_locks.js           # Simulate lock levels
```

### **Production Scripts** (Active)
```
D:\Code\farm\backend\
├── server.js                   # Backend with Progressive Lock logic
├── unlock_account.js           # Manual unlock tool
├── check_lock_status.js        # Quick status check
└── PROGRESSIVE_LOCK_TESTING.md # This documentation
```

### **Implementation Files**
```
D:\Code\farm\backend\server.js
├── Lines 17-29:   In-memory IP rate limiting store
├── Lines 114:     Database schema (lock_count column)
├── Lines 208-217: Auto-migration for existing databases
├── Lines 523-554: Account lock check with progressive messages
├── Lines 560-607: Progressive lock mechanism
└── Lines 642-653: Reset lock_count on successful login
```

---

## 📝 Notes

- **Test scripts** ถูกย้ายไปที่ `_UNNECESSARY_FILES_FARM` เพราะใช้เฉพาะตอนทดสอบครั้งเดียว
- **unlock_account.js** ยังอยู่ใน `backend/` เพราะอาจต้องใช้บ่อยสำหรับ admin
- **check_lock_status.js** ยังอยู่ใน `backend/` สำหรับ quick check
- **PROGRESSIVE_LOCK_TESTING.md** (เอกสารนี้) อยู่ใน `backend/` เพื่อ reference ง่าย

---

## 🔧 Configuration

### **Admin Contact Information**

แก้ไขข้อมูลติดต่อผู้ดูแลระบบที่ไฟล์ `.env`:

```env
# Admin Contact Information (for locked accounts)
ADMIN_EMAIL=support@yourfarm.com
ADMIN_PHONE=02-123-4567
ADMIN_LINE=@yourfarmadmin
```

**Default Values** (ถ้าไม่ได้ตั้งค่าใน .env):
- Email: `admin@farm.com`
- Phone: `02-xxx-xxxx`
- LINE: `@farmadmin`

**ข้อมูลติดต่อจะแสดงเฉพาะใน Lock Level 4+ (24 ชั่วโมง)**
