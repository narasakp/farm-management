const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

async function addImagePermissions() {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(DB_PATH);

    db.serialize(() => {
      console.log('🔧 เริ่มเพิ่ม Permissions สำหรับจัดการรูปภาพ...\n');

      // 1. เพิ่ม permissions ใหม่
      db.run(`
        INSERT OR IGNORE INTO permissions (permission_code, resource, action, description)
        VALUES 
          ('livestock.upload_image', 'livestock', 'upload_image', 'อัปโหลดรูปภาพสินค้าปศุสัตว์'),
          ('livestock.edit_image', 'livestock', 'edit_image', 'แก้ไขรูปภาพสินค้าปศุสัตว์'),
          ('livestock.delete_image', 'livestock', 'delete_image', 'ลบรูปภาพสินค้าปศุสัตว์')
      `, function(err) {
        if (err) {
          console.error('❌ Error adding permissions:', err.message);
        } else {
          console.log('✅ เพิ่ม Permissions สำเร็จ');
        }
      });

      // 2. ให้สิทธิ์กับ FARMER role (role_id = 4)
      db.run(`
        INSERT OR IGNORE INTO role_permissions (role_id, permission_id)
        SELECT 4, permission_id 
        FROM permissions 
        WHERE permission_code IN (
          'livestock.upload_image',
          'livestock.edit_image',
          'livestock.delete_image'
        )
      `, function(err) {
        if (err) {
          console.error('❌ Error adding FARMER permissions:', err.message);
        } else {
          console.log('✅ ให้สิทธิ์ FARMER สำเร็จ (upload, edit, delete)');
        }
      });

      // 3. ให้สิทธิ์กับ VETERINARIAN role (role_id = 5)
      db.run(`
        INSERT OR IGNORE INTO role_permissions (role_id, permission_id)
        SELECT 5, permission_id 
        FROM permissions 
        WHERE permission_code IN (
          'livestock.upload_image',
          'livestock.edit_image'
        )
      `, function(err) {
        if (err) {
          console.error('❌ Error adding VETERINARIAN permissions:', err.message);
        } else {
          console.log('✅ ให้สิทธิ์ VETERINARIAN สำเร็จ (upload, edit)');
        }
      });

      // 4. ให้สิทธิ์กับ RESEARCHER role (role_id = 3)
      db.run(`
        INSERT OR IGNORE INTO role_permissions (role_id, permission_id)
        SELECT 3, permission_id 
        FROM permissions 
        WHERE permission_code IN (
          'livestock.upload_image',
          'livestock.edit_image'
        )
      `, function(err) {
        if (err) {
          console.error('❌ Error adding RESEARCHER permissions:', err.message);
        } else {
          console.log('✅ ให้สิทธิ์ RESEARCHER สำเร็จ (upload, edit)');
        }
      });

      // 5. ตรวจสอบผลลัพธ์
      db.all(`
        SELECT 
          r.role_name,
          r.role_code,
          p.permission_code,
          p.description
        FROM roles r
        JOIN role_permissions rp ON r.role_id = rp.role_id
        JOIN permissions p ON rp.permission_id = p.permission_id
        WHERE p.resource = 'livestock' AND p.action IN ('upload_image', 'edit_image', 'delete_image')
        ORDER BY r.level, p.permission_code
      `, [], (err, rows) => {
        if (err) {
          console.error('❌ Error fetching results:', err.message);
          db.close();
          reject(err);
        } else {
          console.log('\n📋 สรุปสิทธิ์การจัดการรูปภาพ:\n');
          
          const rolePermissions = {};
          rows.forEach(row => {
            if (!rolePermissions[row.role_name]) {
              rolePermissions[row.role_name] = [];
            }
            rolePermissions[row.role_name].push(row.permission_code);
          });

          Object.keys(rolePermissions).forEach(roleName => {
            console.log(`👤 ${roleName}:`);
            rolePermissions[roleName].forEach(perm => {
              console.log(`   ✅ ${perm}`);
            });
            console.log('');
          });

          console.log('✅ เสร็จสมบูรณ์!\n');
          console.log('📊 สถิติ:');
          console.log(`   - Permissions ใหม่: 3 รายการ`);
          console.log(`   - Roles ที่ได้รับสิทธิ์: ${Object.keys(rolePermissions).length} roles`);
          console.log(`   - ความสัมพันธ์ทั้งหมด: ${rows.length} รายการ\n`);

          db.close();
          resolve(rows);
        }
      });
    });
  });
}

// Main
(async () => {
  try {
    await addImagePermissions();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
})();
