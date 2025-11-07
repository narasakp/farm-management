/**
 * Script: Change User Role
 * Purpose: เปลี่ยนบทบาทของผู้ใช้ (เหมาะสำหรับ Social Login users)
 * Usage: node change_user_role.js <email> <new_role>
 * Example: node change_user_role.js user@example.com RESEARCHER
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Database path
const dbPath = path.join(__dirname, 'database.db');
const db = new sqlite3.Database(dbPath);

// Get command line arguments
const email = process.argv[2];
const newRole = process.argv[3];

// Valid roles
const VALID_ROLES = ['FARMER', 'OFFICER', 'RESEARCHER', 'ADMIN', 'SUPER_ADMIN'];

if (!email || !newRole) {
  console.log('❌ Usage: node change_user_role.js <email> <new_role>');
  console.log('');
  console.log('Available roles:');
  console.log('  - FARMER (เกษตรกร)');
  console.log('  - OFFICER (เจ้าหน้าที่)');
  console.log('  - RESEARCHER (นักวิจัย)');
  console.log('  - ADMIN (ผู้ดูแลระบบ)');
  console.log('  - SUPER_ADMIN (ผู้ดูแลระบบสูงสุด)');
  console.log('');
  console.log('Example:');
  console.log('  node change_user_role.js user@example.com RESEARCHER');
  process.exit(1);
}

if (!VALID_ROLES.includes(newRole.toUpperCase())) {
  console.log(`❌ Invalid role: ${newRole}`);
  console.log(`Valid roles: ${VALID_ROLES.join(', ')}`);
  process.exit(1);
}

const roleUpper = newRole.toUpperCase();

console.log('🔍 Searching for user...');
console.log(`📧 Email: ${email}`);
console.log(`🎭 New Role: ${roleUpper}`);
console.log('');

// First, check if user exists
db.get('SELECT id, username, email, role FROM users WHERE email = ?', [email], (err, user) => {
  if (err) {
    console.error('❌ Database error:', err);
    db.close();
    process.exit(1);
  }

  if (!user) {
    console.log('❌ User not found with email:', email);
    console.log('');
    console.log('💡 Tip: List all users with:');
    console.log('   node list_all_users.js');
    db.close();
    process.exit(1);
  }

  console.log('✅ User found:');
  console.log(`   ID: ${user.id}`);
  console.log(`   Username: ${user.username}`);
  console.log(`   Email: ${user.email}`);
  console.log(`   Current Role: ${user.role}`);
  console.log('');

  if (user.role === roleUpper) {
    console.log(`ℹ️  User already has role: ${roleUpper}`);
    console.log('No changes needed.');
    db.close();
    process.exit(0);
  }

  // Update role
  console.log(`🔄 Changing role from ${user.role} to ${roleUpper}...`);
  
  db.run(
    'UPDATE users SET role = ? WHERE id = ?',
    [roleUpper, user.id],
    function(err) {
      if (err) {
        console.error('❌ Failed to update role:', err);
        db.close();
        process.exit(1);
      }

      if (this.changes === 0) {
        console.log('❌ No changes made (user might not exist)');
        db.close();
        process.exit(1);
      }

      console.log('✅ Role updated successfully!');
      console.log('');
      console.log('Updated user info:');
      
      // Verify update
      db.get('SELECT id, username, email, role FROM users WHERE id = ?', [user.id], (err, updatedUser) => {
        if (err) {
          console.error('❌ Error verifying update:', err);
        } else {
          console.log(`   ID: ${updatedUser.id}`);
          console.log(`   Username: ${updatedUser.username}`);
          console.log(`   Email: ${updatedUser.email}`);
          console.log(`   New Role: ${updatedUser.role}`);
        }
        
        console.log('');
        console.log('⚠️  Important:');
        console.log('   - User needs to LOGOUT and LOGIN again to see changes');
        console.log('   - For web users: Clear browser cache or use Incognito mode');
        console.log('');
        
        db.close();
        process.exit(0);
      });
    }
  );
});
