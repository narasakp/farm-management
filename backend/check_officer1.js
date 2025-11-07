const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('🔍 ตรวจสอบ Schema ของ table users...\n');

// ดู schema ก่อน
db.all("PRAGMA table_info(users)", (err, columns) => {
  if (err) {
    console.error('❌ Error getting schema:', err);
    db.close();
    return;
  }
  
  console.log('📋 Columns in users table:');
  columns.forEach(col => {
    console.log(`   - ${col.name} (${col.type})`);
  });
  
  console.log('\n🔍 ตรวจสอบข้อมูล officer1...\n');
  
  // ใช้ชื่อ column ที่ถูกต้อง
  db.get(`
    SELECT 
      u.id,
      u.username,
      u.display_name,
      u.role,
      r.role_name,
      u.is_active,
      u.updated_at
    FROM users u
    LEFT JOIN roles r ON u.role = r.role_code
    WHERE u.username = ?
  `, ['officer1'], (err, row) => {
    if (err) {
      console.error('❌ Error:', err);
    } else if (row) {
      console.log('✅ ข้อมูลปัจจุบัน:');
      console.log('   ID:', row.id);
      console.log('   Username:', row.username);
      console.log('   Display Name:', row.display_name);
      console.log('   Role Code:', row.role);
      console.log('   Role Name:', row.role_name);
      console.log('   Is Active:', row.is_active === 1 ? 'Active ✅' : 'Inactive ❌');
      console.log('   Updated At:', row.updated_at);
    } else {
      console.log('❌ ไม่พบข้อมูล officer1');
    }
    
    db.close();
  });
});
