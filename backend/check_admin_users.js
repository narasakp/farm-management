const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);

console.log('🔍 Checking admin users...\n');

db.all('SELECT id, username, email, role, display_name FROM users WHERE role = ? OR role = ?', ['ADMIN', 'admin'], (err, rows) => {
  if (err) {
    console.error('Error:', err);
  } else if (rows.length === 0) {
    console.log('❌ No admin users found!');
    console.log('\n📋 All users:');
    db.all('SELECT id, username, email, role, display_name FROM users', (err, allRows) => {
      if (err) {
        console.error('Error:', err);
      } else {
        console.table(allRows);
      }
      db.close();
    });
  } else {
    console.log('✅ Admin users found:');
    console.table(rows);
    db.close();
  }
});
