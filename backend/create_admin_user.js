const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);

async function createAdminUser() {
  console.log('🔐 Creating admin user...\n');
  
  const username = 'admin';
  const password = 'admin123';
  const email = 'admin@farm.com';
  const displayName = 'ผู้ดูแลระบบ';
  const role = 'ADMIN';
  
  try {
    // Generate salt and hash password
    const saltRounds = 12;
    const salt = await bcrypt.genSalt(saltRounds);
    const passwordHash = await bcrypt.hash(password, salt);
    
    // Insert admin user
    db.run(`
      INSERT INTO users (
        id, username, email, password_hash, salt, role, display_name, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
    `, [
      Date.now(),
      username,
      email,
      passwordHash,
      salt,
      role,
      displayName
    ], function(err) {
      if (err) {
        if (err.message.includes('UNIQUE constraint failed')) {
          console.log('⚠️ Admin user already exists!');
          
          // Update existing user to ADMIN role
          db.run(`
            UPDATE users 
            SET role = ?, password_hash = ?, salt = ?, display_name = ?
            WHERE username = ? OR email = ?
          `, [role, passwordHash, salt, displayName, username, email], function(updateErr) {
            if (updateErr) {
              console.error('❌ Error updating user:', updateErr);
            } else {
              console.log('✅ Updated existing user to ADMIN role');
              console.log('\n📋 Login credentials:');
              console.log(`   Username: ${username}`);
              console.log(`   Email: ${email}`);
              console.log(`   Password: ${password}`);
              console.log(`   Role: ${role}`);
            }
            db.close();
          });
        } else {
          console.error('❌ Error:', err);
          db.close();
        }
      } else {
        console.log('✅ Admin user created successfully!');
        console.log('\n📋 Login credentials:');
        console.log(`   Username: ${username}`);
        console.log(`   Email: ${email}`);
        console.log(`   Password: ${password}`);
        console.log(`   Role: ${role}`);
        db.close();
      }
    });
  } catch (error) {
    console.error('❌ Error:', error);
    db.close();
  }
}

createAdminUser();
