const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('🔍 Checking deleted feedback...\n');

// Check feedback with deleted_at
db.all(
  `SELECT id, subject, deleted_at, deleted_by 
   FROM feedback 
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

    console.log(`✅ Found ${rows.length} deleted feedback(s):\n`);
    
    if (rows.length === 0) {
      console.log('⚠️ No deleted feedback found!');
      console.log('\n📊 Checking all feedback...');
      
      // Check all feedback
      db.all(
        `SELECT id, subject, deleted_at, deleted_by 
         FROM feedback 
         ORDER BY id DESC 
         LIMIT 5`,
        [],
        (err2, allRows) => {
          if (err2) {
            console.error('❌ Error:', err2);
          } else {
            console.log(`\n📋 Recent feedback (${allRows.length}):`);
            allRows.forEach(row => {
              console.log(`  - ID: ${row.id}`);
              console.log(`    Subject: ${row.subject}`);
              console.log(`    deleted_at: ${row.deleted_at || 'NULL'}`);
              console.log(`    deleted_by: ${row.deleted_by || 'NULL'}`);
              console.log('');
            });
          }
          db.close();
        }
      );
    } else {
      rows.forEach(row => {
        console.log(`  - ID: ${row.id}`);
        console.log(`    Subject: ${row.subject}`);
        console.log(`    Deleted At: ${row.deleted_at}`);
        console.log(`    Deleted By: ${row.deleted_by}`);
        console.log('');
      });
      db.close();
    }
  }
);
