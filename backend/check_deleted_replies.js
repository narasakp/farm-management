const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('🔍 Checking deleted replies...\n');

// Check replies with deleted_at
db.all(
  `SELECT id, feedback_id, message, deleted_at, deleted_by 
   FROM feedback_replies 
   WHERE deleted_at IS NOT NULL 
   ORDER BY deleted_at DESC 
   LIMIT 10`,
  [],
  (err, rows) => {
    if (err) {
      console.error('❌ Error:', err);
      db.close();
      return;
    }

    console.log(`✅ Found ${rows.length} deleted reply(s):\n`);
    
    if (rows.length === 0) {
      console.log('⚠️ No deleted replies found!');
    } else {
      rows.forEach(row => {
        console.log(`  - Reply ID: ${row.id}`);
        console.log(`    Feedback ID: ${row.feedback_id}`);
        console.log(`    Message: ${row.message.substring(0, 50)}...`);
        console.log(`    Deleted At: ${row.deleted_at}`);
        console.log(`    Deleted By: ${row.deleted_by}`);
        console.log('');
      });
    }
    db.close();
  }
);
