const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('📊 Checking all tables in farm_auth.db...\n');

// Get all tables
db.all(`
  SELECT name FROM sqlite_master 
  WHERE type='table' 
  ORDER BY name
`, (err, tables) => {
  if (err) {
    console.error('Error:', err);
    db.close();
    return;
  }
  
  console.log('✅ Tables found:');
  console.log('='.repeat(60));
  
  let processed = 0;
  tables.forEach((table, index) => {
    db.get(`SELECT COUNT(*) as count FROM ${table.name}`, (err, result) => {
      if (!err) {
        console.log(`${(index + 1).toString().padStart(2)}. ${table.name.padEnd(30)} : ${result.count.toLocaleString()} records`);
      }
      
      processed++;
      if (processed === tables.length) {
        console.log('='.repeat(60));
        console.log(`\n✅ Total tables: ${tables.length}`);
        db.close();
      }
    });
  });
});
