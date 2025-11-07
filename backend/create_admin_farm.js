const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

async function createAdminFarm() {
  console.log('🔧 กำลังสร้าง user admin.farm...\n');
  
  const username = 'admin.farm';
  const password = 'admin123';
  const email = 'admin@farm.com';
  const displayName = 'Farm Administrator';
  const role = 'SUPER_ADMIN';
  
  // Generate salt and hash password
  const salt = await bcrypt.genSalt(12);
  const passwordHash = await bcrypt.hash(password, salt);
  
  db.run(`
    INSERT INTO users (
      username, 
      email, 
      password_hash, 
      salt, 
      display_name, 
      role,
      is_active,
      is_verified,
      created_at,
      updated_at
    ) VALUES (?, ?, ?, ?, ?, ?, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
  `, [username, email, passwordHash, salt, displayName, role], function(err) {
    if (err) {
      if (err.message.includes('UNIQUE constraint failed')) {
        console.log('⚠️  User admin.farm มีอยู่แล้ว');
        console.log('');
        console.log('💡 ถ้าต้องการ reset password ให้ลบ user เก่าก่อน:');
        console.log('   DELETE FROM users WHERE username = "admin.farm";');
      } else {
        console.error('❌ Error:', err);
      }
    } else {
      console.log('✅ สร้าง user admin.farm สำเร็จ!');
      console.log('');
      console.log('📋 รายละเอียด:');
      console.log(`   Username: ${username}`);
      console.log(`   Password: ${password}`);
      console.log(`   Email: ${email}`);
      console.log(`   Display Name: ${displayName}`);
      console.log(`   Role: ${role}`);
      console.log('');
      console.log('🎯 สามารถ login ได้แล้ว!');
    }
    
    db.close();
  });
}

createAdminFarm().catch(err => {
  console.error('Error:', err);
  db.close();
});
