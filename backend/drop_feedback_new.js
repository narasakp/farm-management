const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('Dropping feedback_new table if exists...');

db.run('DROP TABLE IF EXISTS feedback_new', (err) => {
  if (err) {
    console.error('Error:', err);
  } else {
    console.log('✅ Table feedback_new dropped successfully!');
  }
  db.close();
});
