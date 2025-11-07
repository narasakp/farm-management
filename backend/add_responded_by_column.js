const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('Adding responded_by_user_name column to feedback table...');

const alterTableSQL = `
ALTER TABLE feedback ADD COLUMN responded_by_user_name TEXT
`;

db.run(alterTableSQL, (err) => {
  if (err) {
    if (err.message.includes('duplicate column name')) {
      console.log('✅ Column already exists!');
    } else {
      console.error('❌ Error adding column:', err);
    }
  } else {
    console.log('✅ Column responded_by_user_name added successfully!');
  }
  
  // Show table schema
  db.all('PRAGMA table_info(feedback)', (err, columns) => {
    if (err) {
      console.error('Error:', err);
    } else {
      console.log('\nCurrent table schema:');
      columns.forEach(col => {
        console.log(`  ${col.name} (${col.type})`);
      });
    }
    db.close();
  });
});
