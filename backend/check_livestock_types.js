const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('🔍 Checking livestock types in database...\n');

db.all(`
  SELECT livestock_type, COUNT(*) as count 
  FROM survey_livestock 
  GROUP BY livestock_type
  ORDER BY count DESC
`, (err, rows) => {
  if (err) {
    console.error('Error:', err);
    db.close();
    return;
  }
  
  console.log('📊 Livestock types found:');
  console.log('='.repeat(40));
  rows.forEach(r => {
    console.log(`  ${r.livestock_type.padEnd(20)} : ${r.count} records`);
  });
  console.log('='.repeat(40));
  console.log(`\n✅ Total types: ${rows.length}`);
  
  db.close();
});
