const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('farm_auth.db');

console.log('🔍 Checking Google OAuth users...\n');

// Find users with google_oauth_user password (Google login)
db.all(`
  SELECT username, email, role, display_name, created_at
  FROM users
  WHERE password_hash = 'google_oauth_user'
  ORDER BY created_at DESC
`, (err, users) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }
  
  if (users.length === 0) {
    console.log('❌ No Google OAuth users found');
    db.close();
    return;
  }
  
  console.log(`👥 Found ${users.length} Google OAuth user(s):\n`);
  console.log('─'.repeat(80));
  
  let processed = 0;
  
  users.forEach((user, index) => {
    console.log(`\n${index + 1}. ${user.display_name} (@${user.username})`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Role: ${user.role}`);
    console.log(`   Created: ${user.created_at}`);
    
    // Get permissions for this user
    db.all(`
      SELECT p.permission_code
      FROM users u
      JOIN roles r ON u.role = r.role_code
      JOIN role_permissions rp ON r.role_id = rp.role_id
      JOIN permissions p ON rp.permission_id = p.permission_id
      WHERE u.username = ?
      ORDER BY p.permission_code
    `, [user.username], (err, perms) => {
      if (!err && perms) {
        console.log(`   Permissions: ${perms.length} items`);
        if (perms.length > 0) {
          const permsList = perms.map(p => p.permission_code).join(', ');
          console.log(`   → ${permsList}`);
        }
      }
      
      processed++;
      if (processed === users.length) {
        console.log('\n' + '─'.repeat(80));
        db.close();
      }
    });
  });
});
