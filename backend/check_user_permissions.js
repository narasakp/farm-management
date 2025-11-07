const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

// ตรวจสอบ permissions ของ user
async function checkUserPermissions(username) {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(DB_PATH);
    
    db.all(`
      SELECT 
        u.id,
        u.username,
        u.display_name,
        u.role,
        r.role_name,
        r.level,
        p.permission_code,
        p.resource,
        p.action,
        p.description
      FROM users u
      JOIN roles r ON u.role = r.role_code
      LEFT JOIN role_permissions rp ON r.role_id = rp.role_id
      LEFT JOIN permissions p ON rp.permission_id = p.permission_id
      WHERE u.username = ?
      ORDER BY p.permission_code
    `, [username], (err, rows) => {
      db.close();
      if (err) {
        reject(err);
      } else {
        resolve(rows);
      }
    });
  });
}

// Main
(async () => {
  try {
    const username = process.argv[2] || 'admin_test';
    console.log(`🔍 กำลังตรวจสอบ permissions ของ: ${username}\n`);
    
    const permissions = await checkUserPermissions(username);
    
    if (permissions.length === 0) {
      console.log('❌ ไม่พบ user นี้ในระบบ');
      return;
    }
    
    const user = permissions[0];
    console.log(`👤 User: ${user.username} (${user.display_name})`);
    console.log(`🎭 Role: ${user.role} - ${user.role_name} (Level ${user.level})`);
    console.log(`\n📋 Permissions (${permissions.filter(p => p.permission_code).length} รายการ):\n`);
    
    permissions.forEach((row, index) => {
      if (row.permission_code) {
        console.log(`${index + 1}. ${row.permission_code}`);
        console.log(`   Resource: ${row.resource} | Action: ${row.action}`);
        console.log(`   ${row.description || '-'}\n`);
      }
    });
    
    // ตรวจสอบว่ามี permission ที่ต้องการหรือไม่
    const hasDashboardAll = permissions.some(p => p.permission_code === 'dashboard.all');
    const hasUsersManage = permissions.some(p => p.permission_code === 'users.manage');
    
    console.log('🔐 สถานะ Permissions สำคัญ:');
    console.log(`   dashboard.all: ${hasDashboardAll ? '✅' : '❌'}`);
    console.log(`   users.manage: ${hasUsersManage ? '✅' : '❌'}`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
})();
