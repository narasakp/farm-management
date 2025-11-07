const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('farm_auth.db');

console.log('🔍 Checking user: nara\n');

db.get('SELECT username, email, role FROM users WHERE username = ?', ['nara'], (err, user) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }
  
  if (!user) {
    console.log('❌ User "nara" not found!');
    db.close();
    return;
  }
  
  console.log('👤 User Info:');
  console.log(`   Username: ${user.username}`);
  console.log(`   Email: ${user.email}`);
  console.log(`   Role: ${user.role}\n`);
  
  db.all(`
    SELECT p.permission_code, p.description
    FROM users u
    JOIN roles r ON u.role = r.role_code
    JOIN role_permissions rp ON r.role_id = rp.role_id
    JOIN permissions p ON rp.permission_id = p.permission_id
    WHERE u.username = ?
    ORDER BY p.permission_code
  `, ['nara'], (err, perms) => {
    if (err) {
      console.error('❌ Error:', err);
      db.close();
      return;
    }
    
    console.log(`📊 Permissions: ${perms.length} items`);
    console.log('─'.repeat(70));
    perms.forEach((p, i) => {
      console.log(`${(i+1).toString().padStart(2)}. ${p.permission_code.padEnd(25)} - ${p.description}`);
    });
    console.log('─'.repeat(70));
    
    if (perms.length < 19) {
      console.log(`\n⚠️  WARNING: Expected 19 permissions but got ${perms.length}`);
    } else {
      console.log('\n✅ User has correct number of permissions');
    }
    
    db.close();
  });
});
