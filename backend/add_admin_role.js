const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// ใช้ __dirname เพื่อให้รันจาก directory ไหนก็ได้
const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);

console.log('🔐 Adding ADMIN role to system...\n');

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
    console.log('\n📋 Adding permissions to existing ADMIN role...\n');
    
    // ใช้ role_id ที่มีอยู่
    const roleId = existingRole.role_id;
    addPermissionsToRole(roleId);
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

    // Step 3: Get all permissions for ADMIN role
    console.log('📋 Adding permissions to ADMIN role...\n');
    
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

    db.all('SELECT permission_id, permission_code FROM permissions', (permErr, allPermissions) => {
      if (permErr) {
        console.error('❌ Error getting permissions:', permErr);
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
        console.log('⚠️  No permissions found to add');
        db.close();
        return;
      }

      // Step 4: Insert role_permissions
      const stmt = db.prepare(`
        INSERT INTO role_permissions (role_id, permission_id)
        VALUES (?, ?)
      `);

      let completed = 0;
      permissionsToAdd.forEach(perm => {
        stmt.run(roleId, perm.permission_id, (stmtErr) => {
          if (stmtErr) {
            console.error(`❌ Error adding permission ${perm.permission_code}:`, stmtErr);
          } else {
            console.log(`✅ Added: ${perm.permission_code}`);
          }
          
          completed++;
          if (completed === permissionsToAdd.length) {
            stmt.finalize();
            
            console.log('');
            console.log('═'.repeat(60));
            console.log('✅ ADMIN role setup completed!');
            console.log(`   Total permissions: ${permissionsToAdd.length}`);
            console.log('');
            console.log('💡 Next steps:');
            console.log('   1. สร้าง user ใหม่ให้มี role เป็น ADMIN');
            console.log('   2. หรืออัปเดต user ที่มีอยู่ให้เป็น ADMIN:');
            console.log('      UPDATE users SET role = \'ADMIN\' WHERE username = \'xxx\'');
            console.log('═'.repeat(60));
            
            db.close();
          }
        });
      });
    });
  });
});
