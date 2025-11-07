const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Database path: ${DB_PATH}`);

console.log('🔍 Checking feedback table...\n');

// Check if table exists
db.all("SELECT name FROM sqlite_master WHERE type='table' AND name='feedback'", (err, tables) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }
  
  if (tables.length === 0) {
    console.log('❌ Table "feedback" does NOT exist');
    db.close();
    return;
  }
  
  console.log('✅ Table "feedback" exists');
  
  // Get table schema
  db.all('PRAGMA table_info(feedback)', (err, columns) => {
    if (err) {
      console.error('❌ Error:', err);
      db.close();
      return;
    }
    
    console.log('\n📋 Table schema:');
    columns.forEach(col => {
      console.log(`  ${col.name} (${col.type})`);
    });
    
    // Get row count
    db.get('SELECT COUNT(*) as count FROM feedback', (err, row) => {
      if (err) {
        console.error('❌ Error:', err);
      } else {
        console.log(`\n📊 Total rows: ${row.count}`);
      }
      db.close();
    });
  });
});
