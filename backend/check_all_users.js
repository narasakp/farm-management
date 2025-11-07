const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('farm_auth.db');

console.log('👥 All Users in Database:\n');

db.all(`
  SELECT username, email, role, display_name, 
         CASE WHEN password_hash = 'google_oauth_user' THEN 'Google'
              WHEN password_hash = 'facebook_oauth_user' THEN 'Facebook'
              ELSE 'Password'
         END as auth_type,
         created_at
  FROM users
  ORDER BY created_at DESC
`, (err, users) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }
  
  console.log(`Found ${users.length} users:\n`);
  console.log('─'.repeat(90));
  
  let processed = 0;
  
  users.forEach((user, index) => {
    console.log(`\n${(index + 1).toString().padStart(2)}. ${user.display_name || user.username} (@${user.username})`);
    console.log(`    Email: ${user.email}`);
    console.log(`    Role: ${user.role}`);
    console.log(`    Auth: ${user.auth_type}`);
    console.log(`    Created: ${user.created_at || 'N/A'}`);
    
    // Get permissions count
    db.get(`
      SELECT COUNT(*) as count
      FROM users u
      JOIN roles r ON u.role = r.role_code
      JOIN role_permissions rp ON r.role_id = rp.role_id
      WHERE u.username = ?
    `, [user.username], (err, result) => {
      if (!err && result) {
        console.log(`    Permissions: ${result.count}`);
      }
      
      processed++;
      if (processed === users.length) {
        console.log('\n' + '─'.repeat(90));
        db.close();
      }
    });
  });
});
