const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

db.all('PRAGMA table_info(farm_surveys)', (err, rows) => {
  if (err) {
    console.error('❌ Error:', err);
  } else {
    console.log('📋 farm_surveys schema:');
    rows.forEach(row => {
      console.log(`  ${row.name} (${row.type})`);
    });
  }
  db.close();
});
