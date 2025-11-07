const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('📋 Checking tables in farm_auth.db\n');

db.all(`
  SELECT name FROM sqlite_master 
  WHERE type='table' 
  ORDER BY name
`, (err, tables) => {
  if (err) {
    console.error('❌ Error:', err);
  } else {
    console.log(`✅ Found ${tables.length} tables:\n`);
    tables.forEach((table, i) => {
      console.log(`  ${i+1}. ${table.name}`);
    });
  }
  
  db.close();
});
