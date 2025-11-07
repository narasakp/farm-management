const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// ใช้ __dirname เพื่อให้รันจาก directory ไหนก็ได้
const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);
console.log('🔐 Adding ADMIN role to system...\n');

// ADMIN permissions list
const adminPermissions = [
  // Feedback permissions
  'feedback.create',
  'feedback.read',
  'feedback.update',
  'feedback.delete',
  
  // Reports permissions
  'reports.own',
  'reports.all',
  'reports.tambon',
  'reports.amphoe',
  
  // Dashboard permissions
  'dashboard.own',
  'dashboard.all',
  
  // User management permissions (hierarchical - can only manage lower levels)
  'users.create',
  'users.read',
  'users.update',
  'users.delete',  // ✅ ลบผู้ใช้ได้ (แต่เฉพาะ level ต่ำกว่า)
  
  // Role management permissions (hierarchical - can only manage lower levels)
  'roles.read',
  'roles.create',
  'roles.update',
  'roles.delete',  // ✅ จัดการ roles ได้ (แต่เฉพาะ level ต่ำกว่า)
];

// Function: Add permissions to role
function addPermissionsToRole(roleId) {
  console.log(`📋 Adding permissions to ADMIN role (ID: ${roleId})...\n`);
  
  db.all('SELECT permission_id, permission_code FROM permissions', (permErr, allPermissions) => {
    if (permErr) {
      console.error('❌ Error getting permissions:', permErr);
      db.close();
      return;
    }

    if (!allPermissions || allPermissions.length === 0) {
      console.log('⚠️  No permissions found in database');
      console.log('💡 Permissions table may be empty. Initialize permissions first.');
      db.close();
      return;
    }

    // Filter permissions for ADMIN
    const permissionsToAdd = allPermissions.filter(p => 
      adminPermissions.includes(p.permission_code) ||
      p.permission_code.startsWith('feedback.') ||
      p.permission_code.startsWith('reports.')
    );

    if (permissionsToAdd.length === 0) {
      console.log('⚠️  No matching permissions found to add');
      console.log(`   Available permissions: ${allPermissions.length}`);
      console.log(`   Requested permissions: ${adminPermissions.length}`);
      db.close();
      return;
    }

    console.log(`📊 Found ${permissionsToAdd.length} permissions to add\n`);

    // Delete existing permissions first
    db.run('DELETE FROM role_permissions WHERE role_id = ?', [roleId], (delErr) => {
      if (delErr) {
        console.error('❌ Error deleting old permissions:', delErr);
        db.close();
        return;
      }

      // Insert role_permissions
      const stmt = db.prepare(`
        INSERT INTO role_permissions (role_id, permission_id)
        VALUES (?, ?)
      `);

      let completed = 0;
      let added = 0;
      let failed = 0;

      permissionsToAdd.forEach(perm => {
        stmt.run(roleId, perm.permission_id, (stmtErr) => {
          if (stmtErr) {
            console.error(`❌ Error adding permission ${perm.permission_code}:`, stmtErr.message);
            failed++;
          } else {
            console.log(`✅ Added: ${perm.permission_code}`);
            added++;
          }
          
          completed++;
          if (completed === permissionsToAdd.length) {
            stmt.finalize();
            
            console.log('');
            console.log('═'.repeat(60));
            console.log('✅ ADMIN role setup completed!');
            console.log(`   Total permissions added: ${added}`);
            if (failed > 0) {
              console.log(`   Failed: ${failed}`);
            }
            console.log('');
            console.log('💡 Next steps:');
            console.log('   1. สร้าง user ใหม่ให้มี role เป็น ADMIN:');
            console.log('      node backend/create_admin_user.js');
            console.log('   2. หรืออัปเดต user ที่มีอยู่ให้เป็น ADMIN:');
            console.log('      UPDATE users SET role = \'ADMIN\' WHERE username = \'xxx\'');
            console.log('   3. ทดสอบ hierarchical RBAC:');
            console.log('      node backend/test_hierarchical_rbac.js');
            console.log('═'.repeat(60));
            
            db.close();
          }
        });
      });
    });
  });
}

// Step 1: Check if ADMIN role already exists
db.get('SELECT * FROM roles WHERE role_code = ?', ['ADMIN'], (err, existingRole) => {
  if (err) {
    console.error('❌ Error checking role:', err);
    db.close();
    return;
  }

  if (existingRole) {
    console.log('⚠️  ADMIN role already exists!');
    console.log(`   Role ID: ${existingRole.role_id}`);
    console.log(`   Role Name: ${existingRole.role_name}`);
    console.log(`   Level: ${existingRole.level}`);
    console.log('');
    
    // ใช้ role_id ที่มีอยู่
    addPermissionsToRole(existingRole.role_id);
    return;
  }

  // Step 2: Insert ADMIN role
  db.run(`
    INSERT INTO roles (
      role_code, role_name, level, description, is_active
    ) VALUES (?, ?, ?, ?, ?)
  `, [
    'ADMIN',
    'ผู้ดูแลระบบ',
    2,
    'ผู้ดูแลระบบ - จัดการข้อเสนอแนะ, ตอบกลับผู้ใช้, ดูรายงาน',
    1   // active
  ], function(insertErr) {
    if (insertErr) {
      console.error('❌ Error inserting role:', insertErr);
      db.close();
      return;
    }

    const roleId = this.lastID;
    console.log('✅ ADMIN role created successfully!');
    console.log(`   Role ID: ${roleId}`);
    console.log(`   Role Code: ADMIN`);
    console.log(`   Level: 2 (Provincial Admin)`);
    console.log('');

    // Add permissions to new role
    addPermissionsToRole(roleId);
  });
});
