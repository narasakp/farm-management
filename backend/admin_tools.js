const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const readline = require('readline');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

/**
 * Admin Tools สำหรับจัดการ RBAC
 */

function showMenu() {
  console.log('\n' + '='.repeat(80));
  console.log('🔧 RBAC Admin Tools');
  console.log('='.repeat(80));
  console.log('\n1. ดู Roles ทั้งหมด');
  console.log('2. ดู Permissions ทั้งหมด');
  console.log('3. เปลี่ยน Role ของ User');
  console.log('4. ดู Permissions ของ Role');
  console.log('5. ดู Users ทั้งหมด');
  console.log('6. ดูข้อมูล User');
  console.log('0. ออก');
  console.log('\n' + '='.repeat(80) + '\n');
}

// 1. View all roles
function viewRoles(db, callback) {
  db.all('SELECT * FROM roles ORDER BY level', [], (err, roles) => {
    if (err) {
      console.error('❌ Error:', err);
      callback();
      return;
    }

    console.log('\n📋 Roles ทั้งหมด:\n');
    roles.forEach((role, i) => {
      console.log(`${i + 1}. ${role.role_name} (${role.role_code}) - Level ${role.level}`);
      console.log(`   ${role.description}\n`);
    });
    callback();
  });
}

// 2. View all permissions
function viewPermissions(db, callback) {
  db.all('SELECT * FROM permissions ORDER BY resource, action', [], (err, perms) => {
    if (err) {
      console.error('❌ Error:', err);
      callback();
      return;
    }

    console.log(`\n📝 Permissions ทั้งหมด (${perms.length} permissions):\n`);
    
    const grouped = {};
    perms.forEach(p => {
      if (!grouped[p.resource]) grouped[p.resource] = [];
      grouped[p.resource].push(p);
    });

    Object.keys(grouped).forEach(resource => {
      console.log(`\n${resource.toUpperCase()}:`);
      grouped[resource].forEach(p => {
        console.log(`  - ${p.permission_code} (${p.description})`);
      });
    });

    callback();
  });
}

// 3. Change user role
function changeUserRole(db, callback) {
  rl.question('\nUsername ที่ต้องการเปลี่ยน Role: ', (username) => {
    if (!username) {
      console.log('❌ กรุณาระบุ username');
      callback();
      return;
    }

    // ดู user ก่อน
    db.get('SELECT * FROM users WHERE username = ?', [username], (err, user) => {
      if (err) {
        console.error('❌ Error:', err);
        callback();
        return;
      }

      if (!user) {
        console.log(`❌ ไม่พบ user: ${username}`);
        callback();
        return;
      }

      console.log(`\n✅ พบ user: ${user.display_name} (${user.username})`);
      console.log(`   Role ปัจจุบัน: ${user.role}\n`);

      // แสดง roles ให้เลือก
      db.all('SELECT * FROM roles ORDER BY level', [], (err, roles) => {
        if (err) {
          console.error('❌ Error:', err);
          callback();
          return;
        }

        console.log('Roles ที่มี:');
        roles.forEach((role, i) => {
          console.log(`${i + 1}. ${role.role_code} - ${role.role_name}`);
        });

        rl.question('\nRole ใหม่ (ใส่ role_code): ', (newRole) => {
          if (!newRole) {
            console.log('❌ ยกเลิก');
            callback();
            return;
          }

          // Update role
          db.run(
            'UPDATE users SET role = ?, updated_at = datetime("now") WHERE username = ?',
            [newRole, username],
            function (err) {
              if (err) {
                console.error('❌ Error:', err);
              } else {
                console.log(`\n✅ เปลี่ยน role สำเร็จ!`);
                console.log(`   ${username}: ${user.role} → ${newRole}`);
              }
              callback();
            }
          );
        });
      });
    });
  });
}

// 4. View role permissions
function viewRolePermissions(db, callback) {
  rl.question('\nRole Code (เช่น FARMER, OFFICER): ', (roleCode) => {
    if (!roleCode) {
      console.log('❌ กรุณาระบุ role code');
      callback();
      return;
    }

    db.all(
      `SELECT p.permission_code, p.resource, p.action, p.description
       FROM permissions p
       JOIN role_permissions rp ON p.permission_id = rp.permission_id
       JOIN roles r ON rp.role_id = r.role_id
       WHERE r.role_code = ?
       ORDER BY p.resource, p.action`,
      [roleCode],
      (err, perms) => {
        if (err) {
          console.error('❌ Error:', err);
          callback();
          return;
        }

        if (perms.length === 0) {
          console.log(`\n⚠️  ไม่พบ permissions สำหรับ role: ${roleCode}`);
          callback();
          return;
        }

        console.log(`\n📋 Permissions ของ ${roleCode} (${perms.length} permissions):\n`);
        
        const grouped = {};
        perms.forEach(p => {
          if (!grouped[p.resource]) grouped[p.resource] = [];
          grouped[p.resource].push(p);
        });

        Object.keys(grouped).forEach(resource => {
          console.log(`\n${resource.toUpperCase()}:`);
          grouped[resource].forEach(p => {
            console.log(`  - ${p.permission_code}`);
          });
        });

        callback();
      }
    );
  });
}

// 5. View all users
function viewUsers(db, callback) {
  db.all(
    'SELECT id, username, display_name, role, is_active FROM users ORDER BY role, username',
    [],
    (err, users) => {
      if (err) {
        console.error('❌ Error:', err);
        callback();
        return;
      }

      console.log(`\n👥 Users ทั้งหมด (${users.length} คน):\n`);
      
      const byRole = {};
      users.forEach(u => {
        if (!byRole[u.role]) byRole[u.role] = [];
        byRole[u.role].push(u);
      });

      Object.keys(byRole).forEach(role => {
        console.log(`\n${role}:`);
        byRole[role].forEach(u => {
          const status = u.is_active ? '✅' : '❌';
          console.log(`  ${status} ${u.username} (${u.display_name}) - ID: ${u.id}`);
        });
      });

      callback();
    }
  );
}

// 6. View user details
function viewUserDetails(db, callback) {
  rl.question('\nUsername: ', (username) => {
    if (!username) {
      console.log('❌ กรุณาระบุ username');
      callback();
      return;
    }

    db.get('SELECT * FROM users WHERE username = ?', [username], (err, user) => {
      if (err) {
        console.error('❌ Error:', err);
        callback();
        return;
      }

      if (!user) {
        console.log(`❌ ไม่พบ user: ${username}`);
        callback();
        return;
      }

      console.log('\n' + '='.repeat(80));
      console.log(`👤 User: ${user.display_name}`);
      console.log('='.repeat(80));
      console.log(`\nUsername: ${user.username}`);
      console.log(`Email: ${user.email || 'ไม่มี'}`);
      console.log(`Phone: ${user.phone || 'ไม่มี'}`);
      console.log(`Role: ${user.role}`);
      console.log(`Active: ${user.is_active ? 'Yes' : 'No'}`);
      console.log(`Verified: ${user.is_verified ? 'Yes' : 'No'}`);
      console.log(`\nLocation:`);
      console.log(`  Province: ${user.province_code || 'ไม่ระบุ'}`);
      console.log(`  Amphoe: ${user.amphoe_code || 'ไม่ระบุ'}`);
      console.log(`  Tambon: ${user.tambon_code || 'ไม่ระบุ'}`);
      console.log(`\nCreated: ${user.created_at}`);
      console.log(`Updated: ${user.updated_at}`);
      console.log(`Last Login: ${user.last_login_at || 'Never'}`);
      console.log(`Failed Attempts: ${user.failed_login_attempts}`);

      callback();
    });
  });
}

// Main loop
function main() {
  const db = new sqlite3.Database(DB_PATH);

  function promptMenu() {
    showMenu();
    rl.question('เลือก (0-6): ', (choice) => {
      console.log('');

      switch (choice) {
        case '1':
          viewRoles(db, promptMenu);
          break;
        case '2':
          viewPermissions(db, promptMenu);
          break;
        case '3':
          changeUserRole(db, promptMenu);
          break;
        case '4':
          viewRolePermissions(db, promptMenu);
          break;
        case '5':
          viewUsers(db, promptMenu);
          break;
        case '6':
          viewUserDetails(db, promptMenu);
          break;
        case '0':
          console.log('👋 Goodbye!\n');
          db.close();
          rl.close();
          break;
        default:
          console.log('❌ Invalid choice');
          promptMenu();
      }
    });
  }

  promptMenu();
}

// Run
main();
