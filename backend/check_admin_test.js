const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('🔍 ตรวจสอบ user admin_test...\n');

db.get(`
  SELECT 
    u.id,
    u.username,
    u.display_name,
    u.role,
    r.role_name,
    u.is_active,
    u.is_verified
  FROM users u
  LEFT JOIN roles r ON u.role = r.role_code
  WHERE u.username = ?
`, ['admin_test'], (err, row) => {
  if (err) {
    console.error('❌ Error:', err);
  } else if (row) {
    console.log('✅ พบ user admin_test:');
    console.log('   ID:', row.id);
    console.log('   Username:', row.username);
    console.log('   Display Name:', row.display_name);
    console.log('   Role Code:', row.role);
    console.log('   Role Name:', row.role_name);
    console.log('   Is Active:', row.is_active === 1 ? 'Active ✅' : 'Inactive ❌');
    console.log('   Is Verified:', row.is_verified === 1 ? 'Verified ✅' : 'Not Verified ❌');
  } else {
    console.log('❌ ไม่พบ user admin_test ในฐานข้อมูล!');
    console.log('');
    console.log('📋 Users ที่มีในระบบ:');
    
    db.all('SELECT username, display_name, role FROM users ORDER BY id', (err, users) => {
      if (err) {
        console.error('Error:', err);
      } else {
        users.forEach(u => {
          console.log(`   - ${u.username} (${u.display_name}) - ${u.role}`);
        });
      }
      db.close();
    });
    return;
  }
  
  db.close();
});
