const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log('📋 Checking survey_livestock schema and data\n');

// Check schema
db.all(`PRAGMA table_info(survey_livestock)`, (err, columns) => {
  if (err) {
    console.error('❌ Error:', err);
  } else {
    console.log('✅ survey_livestock columns:');
    columns.forEach(col => {
      console.log(`  - ${col.name} (${col.type})`);
    });
    console.log('');
  }
  
  // Check data with JOIN
  db.all(`
    SELECT 
      sl.*,
      fs.farmer_first_name,
      fs.farmer_last_name,
      fs.farmer_phone,
      fs.address_tambon,
      fs.address_amphoe,
      fs.address_province
    FROM survey_livestock sl
    LEFT JOIN farm_surveys fs ON sl.survey_id = fs.id
    LIMIT 5
  `, (err2, rows) => {
    if (err2) {
      console.error('❌ Error:', err2);
    } else {
      console.log(`✅ Sample data (${rows.length} rows):\n`);
      rows.forEach((row, i) => {
        const farmerName = `${row.farmer_first_name || ''} ${row.farmer_last_name || ''}`.trim();
        console.log(`${i+1}. Farmer: ${farmerName || 'N/A'}`);
        console.log(`   Type: ${row.livestock_type || 'N/A'}`);
        console.log(`   Count: ${row.total_count || 0}`);
        console.log(`   Location: ${row.address_tambon}, ${row.address_amphoe}`);
        console.log('');
      });
    }
    
    // Count total
    db.get(`SELECT COUNT(*) as total FROM survey_livestock`, (err3, result) => {
      if (err3) {
        console.error('❌ Error:', err3);
      } else {
        console.log(`📊 Total livestock records: ${result.total}`);
      }
      
      db.close();
    });
  });
});
