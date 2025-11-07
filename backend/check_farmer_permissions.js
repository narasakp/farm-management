const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

console.log('🔍 Checking FARMER permissions in database...\n');

const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('❌ Database connection failed:', err.message);
    process.exit(1);
  }
});

// Check FARMER role permissions count
db.get(`
  SELECT COUNT(*) as count 
  FROM role_permissions 
  WHERE role_id = (SELECT role_id FROM roles WHERE role_code = 'FARMER')
`, (err, row) => {
  if (err) {
    console.error('❌ Query failed:', err.message);
    db.close();
    process.exit(1);
  }
  
  console.log(`📊 FARMER has ${row.count} permissions in database`);
  console.log(`Expected: 19 permissions after migrations\n`);
  
  if (row.count < 19) {
    console.log('⚠️  WARNING: FARMER is missing permissions!');
    console.log('❌ Migrations have NOT been applied properly\n');
  } else {
    console.log('✅ FARMER has correct number of permissions\n');
  }
  
  // List all permissions
  db.all(`
    SELECT p.permission_code, p.description
    FROM role_permissions rp
    JOIN roles r ON rp.role_id = r.role_id
    JOIN permissions p ON rp.permission_id = p.permission_id
    WHERE r.role_code = 'FARMER'
    ORDER BY p.permission_code
  `, (err, permissions) => {
    if (err) {
      console.error('❌ Query failed:', err.message);
    } else {
      console.log('📋 FARMER Permissions List:');
      console.log('─'.repeat(70));
      permissions.forEach((perm, index) => {
        console.log(`${(index + 1).toString().padStart(2)}. ${perm.permission_code.padEnd(25)} - ${perm.description}`);
      });
      console.log('─'.repeat(70));
    }
    
    // Check specific user permissions
    db.all(`
      SELECT u.username, u.role, COUNT(rp.permission_id) as perm_count
      FROM users u
      JOIN roles r ON u.role = r.role_code
      LEFT JOIN role_permissions rp ON r.role_id = rp.role_id
      WHERE u.role = 'FARMER'
      GROUP BY u.user_id
      ORDER BY u.created_at DESC
      LIMIT 5
    `, (err, users) => {
      if (err) {
        console.error('❌ Query failed:', err.message);
      } else {
        console.log('\n👥 Recent FARMER users:');
        console.log('─'.repeat(70));
        users.forEach(user => {
          console.log(`${user.username.padEnd(20)} → ${user.perm_count} permissions`);
        });
      }
      
      db.close();
    });
  });
});
