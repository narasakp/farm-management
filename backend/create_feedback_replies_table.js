const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('Creating feedback_replies table...');

const createTableSQL = `
CREATE TABLE IF NOT EXISTS feedback_replies (
  id TEXT PRIMARY KEY,
  feedback_id TEXT NOT NULL,
  parent_reply_id TEXT,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_reply_id) REFERENCES feedback_replies(id) ON DELETE CASCADE
)`;

db.run(createTableSQL, (err) => {
  if (err) {
    console.error('❌ Error creating table:', err);
  } else {
    console.log('✅ Table feedback_replies created successfully!');
    
    // Create index for faster queries
    db.run('CREATE INDEX IF NOT EXISTS idx_replies_feedback_id ON feedback_replies(feedback_id)', (err) => {
      if (err) {
        console.error('❌ Error creating index:', err);
      } else {
        console.log('✅ Index created successfully!');
      }
      
      // Show table schema
      db.all('PRAGMA table_info(feedback_replies)', (err, columns) => {
        if (err) {
          console.error('Error:', err);
        } else {
          console.log('\n📋 Table schema:');
          columns.forEach(col => {
            console.log(`  ${col.name} (${col.type})`);
          });
        }
        db.close();
      });
    });
  }
});
