const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);
console.log('🔐 Adding Feedback, Users, and Roles permissions...\n');

const newPermissions = [
  // Feedback permissions
  { name: 'Feedback (Create)', code: 'feedback.create', resource: 'feedback', action: 'create', description: 'สร้างข้อเสนอแนะใหม่' },
  { name: 'Feedback (Read)', code: 'feedback.read', resource: 'feedback', action: 'read', description: 'ดูข้อเสนอแนะ' },
  { name: 'Feedback (Update)', code: 'feedback.update', resource: 'feedback', action: 'update', description: 'แก้ไขข้อเสนอแนะ' },
  { name: 'Feedback (Delete)', code: 'feedback.delete', resource: 'feedback', action: 'delete', description: 'ลบข้อเสนอแนะ' },
  { name: 'Feedback (Approve)', code: 'feedback.approve', resource: 'feedback', action: 'approve', description: 'อนุมัติข้อเสนอแนะ' },
  { name: 'Feedback (Reject)', code: 'feedback.reject', resource: 'feedback', action: 'reject', description: 'ปฏิเสธข้อเสนอแนะ' },
  { name: 'Feedback (Reply)', code: 'feedback.reply', resource: 'feedback', action: 'reply', description: 'ตอบกลับข้อเสนอแนะ' },
  
  // Users permissions (hierarchical)
  { name: 'Users (Create)', code: 'users.create', resource: 'users', action: 'create', description: 'สร้างผู้ใช้ใหม่ (Hierarchical)' },
  { name: 'Users (Read)', code: 'users.read', resource: 'users', action: 'read', description: 'ดูข้อมูลผู้ใช้' },
  { name: 'Users (Update)', code: 'users.update', resource: 'users', action: 'update', description: 'แก้ไขข้อมูลผู้ใช้ (Hierarchical)' },
  { name: 'Users (Delete)', code: 'users.delete', resource: 'users', action: 'delete', description: 'ลบผู้ใช้ (Hierarchical)' },
  
  // Roles permissions (hierarchical)
  { name: 'Roles (Read)', code: 'roles.read', resource: 'roles', action: 'read', description: 'ดูข้อมูล roles' },
  { name: 'Roles (Create)', code: 'roles.create', resource: 'roles', action: 'create', description: 'สร้าง role ใหม่ (Hierarchical)' },
  { name: 'Roles (Update)', code: 'roles.update', resource: 'roles', action: 'update', description: 'แก้ไข role (Hierarchical)' },
  { name: 'Roles (Delete)', code: 'roles.delete', resource: 'roles', action: 'delete', description: 'ลบ role (Hierarchical)' },
];

console.log(`📊 Adding ${newPermissions.length} permissions:\n`);

let added = 0;
let skipped = 0;
let completed = 0;

newPermissions.forEach(perm => {
  // Check if permission already exists
  db.get('SELECT * FROM permissions WHERE permission_code = ?', [perm.code], (err, existing) => {
    if (err) {
      console.error(`❌ Error checking ${perm.code}:`, err.message);
      completed++;
      return;
    }

    if (existing) {
      console.log(`⏭️  Skipped: ${perm.code} (already exists)`);
      skipped++;
      completed++;
      checkCompletion();
      return;
    }

    // Insert new permission
    db.run(`
      INSERT INTO permissions (permission_name, permission_code, resource, action, description)
      VALUES (?, ?, ?, ?, ?)
    `, [perm.name, perm.code, perm.resource, perm.action, perm.description], (insertErr) => {
      if (insertErr) {
        console.error(`❌ Error adding ${perm.code}:`, insertErr.message);
      } else {
        console.log(`✅ Added: ${perm.code}`);
        added++;
      }
      
      completed++;
      checkCompletion();
    });
  });
});

function checkCompletion() {
  if (completed === newPermissions.length) {
    console.log('');
    console.log('═'.repeat(60));
    console.log('✅ Permissions added successfully!');
    console.log(`   Added: ${added}`);
    console.log(`   Skipped: ${skipped}`);
    console.log('');
    console.log('💡 Next step:');
    console.log('   Run again: node backend/add_admin_role_fixed.js');
    console.log('═'.repeat(60));
    
    db.close();
  }
}
