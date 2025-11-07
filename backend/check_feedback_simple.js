const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

db.all("SELECT name FROM sqlite_master WHERE type='table'", (err, tables) => {
  if (err) {
    console.error('Error:', err);
  } else {
    console.log('📋 All tables in database:');
    tables.forEach(t => console.log(`  - ${t.name}`));
    
    const hasFeedback = tables.some(t => t.name === 'feedback');
    console.log(`\n🔍 Feedback table exists: ${hasFeedback ? '✅ YES' : '❌ NO'}`);
  }
  db.close();
});
