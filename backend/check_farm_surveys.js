const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('📋 Checking farm_surveys schema and data\n');

// Check schema
db.all(`PRAGMA table_info(farm_surveys)`, (err, columns) => {
  if (err) {
    console.error('❌ Error:', err);
  } else {
    console.log('✅ farm_surveys columns:');
    columns.forEach(col => {
      console.log(`  - ${col.name} (${col.type})`);
    });
    console.log('');
  }
  
  // Check data
  db.all(`SELECT * FROM farm_surveys LIMIT 5`, (err2, rows) => {
    if (err2) {
      console.error('❌ Error:', err2);
    } else {
      console.log(`✅ Sample data (${rows.length} rows):\n`);
      rows.forEach((row, i) => {
        console.log(`${i+1}. ID: ${row.id || row.survey_id}`);
        console.log(`   Farmer: ${row.farmer_name || row.name || 'N/A'}`);
        console.log(`   Created: ${row.created_at}`);
        console.log('');
      });
    }
    
    // Count total
    db.get(`SELECT COUNT(*) as total FROM farm_surveys`, (err3, result) => {
      if (err3) {
        console.error('❌ Error:', err3);
      } else {
        console.log(`📊 Total farm_surveys: ${result.total}`);
      }
      
      db.close();
    });
  });
});
