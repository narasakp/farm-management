const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);

console.log('🔍 Checking database tables...\n');

db.all(`
  SELECT name, type 
  FROM sqlite_master 
  WHERE type IN ('table', 'view')
  ORDER BY name
`, (err, tables) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }

  if (tables.length === 0) {
    console.log('⚠️  Database is empty! No tables found.');
    console.log('\n💡 Solution:');
    console.log('   Start the server to initialize database:');
    console.log('   node backend/server.js');
  } else {
    console.log(`✅ Found ${tables.length} tables:\n`);
    
    const hasRoles = tables.find(t => t.name === 'roles');
    const hasPermissions = tables.find(t => t.name === 'permissions');
    const hasRolePermissions = tables.find(t => t.name === 'role_permissions');
    
    tables.forEach((table, index) => {
      const icon = table.type === 'table' ? '📋' : '👁️';
      console.log(`${icon} ${index + 1}. ${table.name} (${table.type})`);
    });
    
    console.log('\n' + '═'.repeat(60));
    console.log('\n🎯 RBAC Tables Status:');
    console.log(`   roles: ${hasRoles ? '✅ Found' : '❌ Missing'}`);
    console.log(`   permissions: ${hasPermissions ? '✅ Found' : '❌ Missing'}`);
    console.log(`   role_permissions: ${hasRolePermissions ? '✅ Found' : '❌ Missing'}`);
    
    if (!hasRoles || !hasPermissions || !hasRolePermissions) {
      console.log('\n⚠️  RBAC tables are missing!');
      console.log('\n💡 Solution:');
      console.log('   Start the server to initialize RBAC tables:');
      console.log('   node backend/server.js');
    } else {
      console.log('\n✅ RBAC tables are ready!');
      console.log('   You can now run: node backend/add_admin_role.js');
    }
  }
  
  db.close();
});
