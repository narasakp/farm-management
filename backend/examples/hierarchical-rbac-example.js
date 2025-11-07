/**
 * ตัวอย่างการใช้งาน Hierarchical RBAC Middleware
 * 
 * วิธีใช้ใน routes:
 */

const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { requirePermission } = require('../middleware/rbac');
const { requireCanDeleteUser, requireCanManageRole } = require('../middleware/hierarchical-rbac');

// ==========================================
// ❌ แบบเดิม (ไม่มี hierarchical check)
// ==========================================
// ADMIN สามารถลบ SUPER_ADMIN ได้! (ผิด)
router.delete('/users/:userId', 
  authenticateToken,
  requirePermission('users.delete'),  // ❌ เช็คแค่ permission อย่างเดียว
  async (req, res) => {
    // Delete user logic...
  }
);

// ==========================================
// ✅ แบบใหม่ (มี hierarchical check)
// ==========================================
// ADMIN สามารถลบได้เฉพาะ users ที่ level ต่ำกว่า (level 3-4) เท่านั้น
router.delete('/users/:userId', 
  authenticateToken,
  requirePermission('users.delete'),      // เช็ค permission ก่อน
  requireCanDeleteUser,                   // ✅ เช็ค hierarchy อีกที
  async (req, res) => {
    // Delete user logic...
    // ถึงจุดนี้แสดงว่า:
    // 1. มี permission users.delete ✅
    // 2. target user มี level ต่ำกว่า ✅
    
    const { userId } = req.params;
    console.log('Hierarchical check result:', req.hierarchicalCheck);
    // {
    //   allowed: true,
    //   currentLevel: 2,  // ADMIN
    //   targetLevel: 4    // FARMER
    // }
    
    res.json({
      success: true,
      message: `ลบผู้ใช้ ${userId} สำเร็จ`
    });
  }
);

// ==========================================
// ✅ จัดการ Roles (Hierarchical)
// ==========================================
router.put('/roles/:roleCode', 
  authenticateToken,
  requirePermission('roles.update'),      // เช็ค permission ก่อน
  requireCanManageRole,                   // ✅ เช็ค hierarchy อีกที
  async (req, res) => {
    // Update role logic...
    const { roleCode } = req.params;
    console.log('Hierarchical check result:', req.hierarchicalCheck);
    
    res.json({
      success: true,
      message: `อัปเดต role ${roleCode} สำเร็จ`
    });
  }
);

router.delete('/roles/:roleCode', 
  authenticateToken,
  requirePermission('roles.delete'),      // เช็ค permission ก่อน
  requireCanManageRole,                   // ✅ เช็ค hierarchy อีกที
  async (req, res) => {
    // Delete role logic...
    const { roleCode } = req.params;
    
    res.json({
      success: true,
      message: `ลบ role ${roleCode} สำเร็จ`
    });
  }
);

// ==========================================
// 📊 Test Cases
// ==========================================

/**
 * Test Case 1: ADMIN ลบ FARMER
 * Current: ADMIN (level 2)
 * Target: FARMER (level 4)
 * Result: ✅ สำเร็จ (4 > 2)
 */

/**
 * Test Case 2: ADMIN ลบ ADMIN
 * Current: ADMIN (level 2)
 * Target: ADMIN (level 2)
 * Result: ❌ ล้มเหลว (2 == 2) - สิทธิ์เท่ากัน
 */

/**
 * Test Case 3: ADMIN ลบ SUPER_ADMIN
 * Current: ADMIN (level 2)
 * Target: SUPER_ADMIN (level 1)
 * Result: ❌ ล้มเหลว (1 < 2) - สิทธิ์สูงกว่า
 */

/**
 * Test Case 4: ADMIN แก้ไข FARMER role
 * Current: ADMIN (level 2)
 * Target: FARMER role (level 4)
 * Result: ✅ สำเร็จ (4 > 2)
 */

/**
 * Test Case 5: ADMIN แก้ไข ADMIN role
 * Current: ADMIN (level 2)
 * Target: ADMIN role (level 2)
 * Result: ❌ ล้มเหลว (2 == 2) - สิทธิ์เท่ากัน
 */

/**
 * Test Case 6: ADMIN ลบ SUPER_ADMIN role
 * Current: ADMIN (level 2)
 * Target: SUPER_ADMIN role (level 1, protected)
 * Result: ❌ ล้มเหลว (Protected Role)
 */

module.exports = router;
