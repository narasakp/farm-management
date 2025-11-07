const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

/**
 * สร้าง test users สำหรับทดสอบ RBAC ทุก role
 */
async function createTestUsers() {
  const db = new sqlite3.Database(DB_PATH);

  console.log('🔧 Creating test users for RBAC testing...\n');

  // Password: test123 (same for all test users)
  const password = 'test123';
  const salt = await bcrypt.genSalt(12);
  const hashedPassword = await bcrypt.hash(password, salt);

  const testUsers = [
    {
      username: 'farmer_test',
      email: 'farmer@test.com',
      display_name: 'เกษตรกรทดสอบ',
      role: 'FARMER',
      tambon_code: '510101',
      amphoe_code: '5101',
      province_code: '51',
    },
    {
      username: 'officer_amphoe',
      email: 'amphoe@test.com',
      display_name: 'เจ้าหน้าที่อำเภอทดสอบ',
      role: 'AMPHOE_OFFICER',
      amphoe_code: '5101',
      province_code: '51',
    },
    {
      username: 'officer_tambon',
      email: 'tambon@test.com',
      display_name: 'เจ้าหน้าที่ตำบลทดสอบ',
      role: 'TAMBON_OFFICER',
      tambon_code: '510101',
      amphoe_code: '5101',
      province_code: '51',
    },
    {
      username: 'researcher_test',
      email: 'research@test.com',
      display_name: 'นักวิจัยทดสอบ',
      role: 'RESEARCHER',
      province_code: '51',
    },
    {
      username: 'trader_test',
      email: 'trader@test.com',
      display_name: 'พ่อค้าทดสอบ',
      role: 'TRADER',
      tambon_code: '510101',
      amphoe_code: '5101',
      province_code: '51',
    },
    {
      username: 'transport_test',
      email: 'transport@test.com',
      display_name: 'ผู้ขนส่งทดสอบ',
      role: 'TRANSPORTER',
      tambon_code: '510101',
      amphoe_code: '5101',
      province_code: '51',
    },
    {
      username: 'leader_test',
      email: 'leader@test.com',
      display_name: 'ผู้นำกลุ่มทดสอบ',
      role: 'GROUP_LEADER',
      tambon_code: '510101',
      amphoe_code: '5101',
      province_code: '51',
    },
    {
      username: 'admin_test',
      email: 'admin@test.com',
      display_name: 'ผู้ดูแลระบบทดสอบ',
      role: 'SUPER_ADMIN',
    },
  ];

  return new Promise((resolve, reject) => {
    db.serialize(() => {
      // เริ่ม transaction
      db.run('BEGIN TRANSACTION');

      let completed = 0;
      let errors = [];

      testUsers.forEach((user) => {
        // เช็คว่ามี user นี้แล้วหรือยัง
        db.get(
          'SELECT id FROM users WHERE username = ? OR email = ?',
          [user.username, user.email],
          (err, row) => {
            if (err) {
              errors.push(`Error checking ${user.username}: ${err.message}`);
              completed++;
              if (completed === testUsers.length) {
                finishProcess();
              }
              return;
            }

            if (row) {
              console.log(`⏭️  Skip: ${user.username} (already exists)`);
              completed++;
              if (completed === testUsers.length) {
                finishProcess();
              }
            } else {
              // Insert user
              db.run(
                `INSERT INTO users (
                  username, email, password_hash, salt, display_name, role,
                  tambon_code, amphoe_code, province_code,
                  is_active, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, datetime('now'), datetime('now'))`,
                [
                  user.username,
                  user.email,
                  hashedPassword,
                  salt,
                  user.display_name,
                  user.role,
                  user.tambon_code || null,
                  user.amphoe_code || null,
                  user.province_code || null,
                ],
                function (err) {
                  if (err) {
                    errors.push(`Error creating ${user.username}: ${err.message}`);
                  } else {
                    console.log(`✅ Created: ${user.username} (${user.role}) - ID: ${this.lastID}`);
                  }

                  completed++;
                  if (completed === testUsers.length) {
                    finishProcess();
                  }
                }
              );
            }
          }
        );
      });

      function finishProcess() {
        if (errors.length > 0) {
          console.error('\n❌ Errors occurred:');
          errors.forEach((err) => console.error(`  - ${err}`));
          db.run('ROLLBACK', () => {
            db.close();
            reject(new Error('Failed to create test users'));
          });
        } else {
          db.run('COMMIT', (err) => {
            if (err) {
              console.error('❌ Commit failed:', err);
              db.close();
              reject(err);
            } else {
              console.log('\n✅ All test users created successfully!');
              console.log('\n📝 Login Credentials:');
              console.log('Username: [any of the above]');
              console.log('Password: test123');
              console.log('\n🧪 Test RBAC at: http://localhost:8096/#/rbac-test');
              
              db.close();
              resolve();
            }
          });
        }
      }
    });
  });
}

// Run if called directly
if (require.main === module) {
  createTestUsers()
    .then(() => {
      console.log('\n🎉 Done!');
      process.exit(0);
    })
    .catch((err) => {
      console.error('\n💥 Fatal error:', err);
      process.exit(1);
    });
}

module.exports = { createTestUsers };
