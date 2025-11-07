const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('🔍 Checking auth_logs table schema...\n');

db.all(`PRAGMA table_info(auth_logs)`, (err, columns) => {
  if (err) {
    console.error('Error:', err);
    db.close();
    return;
  }
  
  console.log('✅ auth_logs columns:');
  console.log('='.repeat(60));
  columns.forEach(col => {
    console.log(`  ${col.name.padEnd(20)} - ${col.type}`);
  });
  console.log('='.repeat(60));
  
  // Get sample data
  db.all(`SELECT * FROM auth_logs LIMIT 3`, (err, rows) => {
    if (!err && rows.length > 0) {
      console.log('\n📊 Sample data:');
      console.log(JSON.stringify(rows[0], null, 2));
    }
    db.close();
  });
});
