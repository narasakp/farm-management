const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('Creating feedback table...');

const createTableSQL = `
CREATE TABLE IF NOT EXISTS feedback (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  rating INTEGER NOT NULL DEFAULT 5,
  attachments TEXT,
  priority TEXT NOT NULL DEFAULT 'medium',
  status TEXT NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME,
  admin_response TEXT,
  responded_at DATETIME
)`;

db.run(createTableSQL, (err) => {
  if (err) {
    console.error('Error creating table:', err);
  } else {
    console.log('Table feedback created successfully!');
    
    db.all('PRAGMA table_info(feedback)', (err, columns) => {
      if (err) {
        console.error('Error:', err);
      } else {
        console.log('Table schema:');
        columns.forEach(col => {
          console.log(`  ${col.name} (${col.type})`);
        });
      }
      db.close();
    });
  }
});
