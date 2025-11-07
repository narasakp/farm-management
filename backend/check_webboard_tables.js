/**
 * Check Webboard Tables
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

const db = new sqlite3.Database(DB_PATH);

console.log('🔍 Checking Webboard tables...\n');

db.all("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'forum%' ORDER BY name", (err, tables) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }
  
  console.log(`✅ Found ${tables.length} Webboard tables:\n`);
  
  tables.forEach((table, index) => {
    console.log(`  ${index + 1}. ${table.name}`);
  });
  
  console.log('\n📊 Checking table structures...\n');
  
  let completed = 0;
  tables.forEach((table) => {
    db.all(`PRAGMA table_info(${table.name})`, (err, columns) => {
      if (err) {
        console.error(`❌ Error checking ${table.name}:`, err);
      } else {
        console.log(`📋 ${table.name}:`);
        columns.forEach(col => {
          console.log(`   - ${col.name} (${col.type})`);
        });
        console.log();
      }
      
      completed++;
      if (completed === tables.length) {
        db.close();
        console.log('✅ Check complete!');
      }
    });
  });
});
