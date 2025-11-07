# 🔐 Hierarchical RBAC Documentation

## 📚 **Overview**

Hierarchical Role-Based Access Control (RBAC) คือระบบควบคุมสิทธิ์แบบลำดับชั้น ที่ไม่เพียงแค่เช็ค **permissions** แต่ยังเช็ค **role level** อีกด้วย

---

## 🎯 **Role Hierarchy**

```
Level 1 (สูงสุด)
    ├─ SUPER_ADMIN 🛡️ (Protected)
    │  ✅ จัดการทุกอย่างได้
    │  ❌ ลบไม่ได้
    │
Level 2 (Admin)
    ├─ ADMIN
    │  ✅ จัดการ level 3-4 ได้
    │  ❌ จัดการ level 1-2 ไม่ได้
    │
Level 3 (Officers)
    ├─ AMPHOE_OFFICER
    ├─ TAMBON_OFFICER
    ├─ RESEARCHER
    └─ GROUP_LEADER
    │  ❌ ไม่มีสิทธิ์จัดการผู้อื่น
    │
Level 4 (End Users)
    ├─ FARMER
    ├─ TRADER
    └─ TRANSPORTER
       ❌ ไม่มีสิทธิ์จัดการผู้อื่น
```

---

## 📊 **Level Comparison Rules**

| Current Level | Target Level | Can Manage? | Reason |
|---------------|--------------|-------------|---------|
| 1 (SUPER_ADMIN) | Any | ✅ Yes | สูงสุด |
| 2 (ADMIN) | 3-4 | ✅ Yes | Target level > Current level |
| 2 (ADMIN) | 2 | ❌ No | เท่ากัน |
| 2 (ADMIN) | 1 | ❌ No | Target สูงกว่า |
| 3 (OFFICER) | 4 | ❌ No | ไม่มี permission |
| 4 (FARMER) | Any | ❌ No | ไม่มี permission |

**Rule:** `target_level > current_level` → **Allow**

---

## 🔧 **Implementation**

### **1. Setup ADMIN Role**

```bash
# สร้าง ADMIN role พร้อม permissions
node backend/add_admin_role.js
```

### **2. ใช้งาน Middleware**

```javascript
const { authenticateToken } = require('./middleware/auth');
const { requirePermission } = require('./middleware/rbac');
const { requireCanDeleteUser } = require('./middleware/hierarchical-rbac');

// ✅ Hierarchical User Delete
router.delete('/users/:userId', 
  authenticateToken,              // 1. เช็ค authentication
  requirePermission('users.delete'), // 2. เช็ค permission
  requireCanDeleteUser,           // 3. ✅ เช็ค hierarchy
  async (req, res) => {
    // Safe to delete - ผ่านทั้ง 3 checks แล้ว
  }
);
```

### **3. Error Responses**

**กรณีไม่มี permission:**
```json
{
  "error": "Forbidden",
  "message": "ไม่มีสิทธิ์ในการลบผู้ใช้"
}
```

**กรณีมี permission แต่ level ไม่ผ่าน:**
```json
{
  "error": "Forbidden",
  "message": "ไม่สามารถจัดการผู้ใช้ที่มีสิทธิ์เท่ากันหรือสูงกว่าได้\nคุณ: ผู้ดูแลระบบ (Level 2)\nเป้าหมาย: Super Admin (Level 1)",
  "details": {
    "currentLevel": 2,
    "targetLevel": 1
  }
}
```

---

## 🧪 **Test Scenarios**

### **Test 1: ADMIN ลบ FARMER ✅**
```
Current: ADMIN (level 2)
Target: FARMER (level 4)
Result: ✅ สำเร็จ (4 > 2)
```

### **Test 2: ADMIN ลบ ADMIN ❌**
```
Current: ADMIN (level 2)
Target: ADMIN (level 2)
Result: ❌ ล้มเหลว (2 == 2) - สิทธิ์เท่ากัน
```

### **Test 3: ADMIN ลบ SUPER_ADMIN ❌**
```
Current: ADMIN (level 2)
Target: SUPER_ADMIN (level 1)
Result: ❌ ล้มเหลว (1 < 2) - สิทธิ์สูงกว่า
```

### **Test 4: ADMIN แก้ไข FARMER role ✅**
```
Current: ADMIN (level 2)
Target: FARMER role (level 4)
Result: ✅ สำเร็จ (4 > 2)
```

### **Test 5: ADMIN แก้ไข SUPER_ADMIN role ❌**
```
Current: ADMIN (level 2)
Target: SUPER_ADMIN role (level 1, protected)
Result: ❌ ล้มเหลว (Protected Role)
```

---

## 📋 **ADMIN Permissions**

### **✅ Hierarchical Permissions (เฉพาะ level ต่ำกว่า)**

| Permission | Description |
|------------|-------------|
| `users.create` | สร้าง user ใหม่ (level 3-4 เท่านั้น) |
| `users.read` | ดูข้อมูล user |
| `users.update` | แก้ไขข้อมูล user (level 3-4 เท่านั้น) |
| `users.delete` | ลบ user (level 3-4 เท่านั้น) |
| `roles.read` | ดูข้อมูล roles |
| `roles.create` | สร้าง role ใหม่ (level 3-4 เท่านั้น) |
| `roles.update` | แก้ไข role (level 3-4 เท่านั้น) |
| `roles.delete` | ลบ role (level 3-4 เท่านั้น) |

### **✅ Non-Hierarchical Permissions**

| Permission | Description |
|------------|-------------|
| `feedback.create` | สร้างข้อเสนอแนะ |
| `feedback.read` | ดูข้อเสนอแนะ |
| `feedback.update` | แก้ไขข้อเสนอแนะ |
| `feedback.delete` | ลบข้อเสนอแนะ |
| `reports.own` | ดูรายงานของตัวเอง |
| `reports.all` | ดูรายงานทั้งหมด |
| `dashboard.own` | ดู dashboard ของตัวเอง |
| `dashboard.all` | ดู dashboard ทั้งหมด |

---

## 🔍 **API Examples**

### **ลบผู้ใช้ (Hierarchical)**

```bash
DELETE /api/users/12345
Authorization: Bearer <admin_token>

# Response (Success)
{
  "success": true,
  "message": "ลบผู้ใช้สำเร็จ"
}

# Response (Forbidden - Same Level)
{
  "error": "Forbidden",
  "message": "ไม่สามารถจัดการผู้ใช้ที่มีสิทธิ์เท่ากันหรือสูงกว่าได้",
  "details": {
    "currentLevel": 2,
    "targetLevel": 2
  }
}
```

### **จัดการ Role (Hierarchical)**

```bash
PUT /api/roles/FARMER
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "role_name": "เกษตรกร (แก้ไข)",
  "description": "คำอธิบายใหม่"
}

# Response (Success)
{
  "success": true,
  "message": "อัปเดต role FARMER สำเร็จ"
}

# Response (Forbidden - Protected)
{
  "error": "Forbidden",
  "message": "ไม่สามารถจัดการ \"Super Admin\" ได้ (Protected Role)",
  "details": {
    "currentLevel": 2,
    "targetLevel": 1
  }
}
```

---

## 🚀 **Quick Start**

### **1. Setup**
```bash
# 1. เพิ่ม ADMIN role
node backend/add_admin_role.js

# 2. สร้าง ADMIN user
node backend/create_admin_user.js

# 3. Test hierarchical RBAC
node backend/test_hierarchical_rbac.js
```

### **2. ใช้งานใน Routes**
```javascript
const { requireCanDeleteUser } = require('./middleware/hierarchical-rbac');

router.delete('/users/:userId', 
  authenticateToken,
  requirePermission('users.delete'),
  requireCanDeleteUser,  // ← เพิ่มบรรทัดนี้
  async (req, res) => {
    // Your delete logic
  }
);
```

---

## ⚠️ **Important Notes**

1. **Protected Roles** (เช่น SUPER_ADMIN) ลบไม่ได้ไม่ว่ากรณีใด
2. **Level ต่ำ = สิทธิ์สูง** (1 = สูงสุด, 4 = ต่ำสุด)
3. **Hierarchical check** ทำงานหลังจาก permission check
4. **ADMIN** สามารถจัดการได้เฉพาะ level 3-4 เท่านั้น
5. **SUPER_ADMIN** จัดการได้ทุก level

---

## 📚 **Related Files**

- `backend/middleware/hierarchical-rbac.js` - Middleware สำหรับ hierarchical check
- `backend/add_admin_role.js` - Script สร้าง ADMIN role
- `backend/test_hierarchical_rbac.js` - Test script
- `backend/examples/hierarchical-rbac-example.js` - ตัวอย่างการใช้งาน

---

## 🆘 **Troubleshooting**

### ❓ ADMIN ลบผู้ใช้ไม่ได้
**สาเหตุ:** Target user อาจมี level เท่ากันหรือต่ำกว่า

**แก้ไข:** เช็ค level ของทั้ง 2 ฝ่าย
```bash
node backend/test_hierarchical_rbac.js
```

### ❓ ไม่มี ADMIN role
**แก้ไข:** รัน add_admin_role.js
```bash
node backend/add_admin_role.js
```

### ❓ ADMIN ไม่มี permissions
**แก้ไข:** ADMIN role อาจสร้างไว้แล้วแต่ยังไม่ได้ add permissions
```bash
node backend/add_admin_role.js  # จะ skip การสร้าง role และเพิ่ม permissions
```

---

**Last Updated:** 2025-10-29
**Version:** 1.0.0
