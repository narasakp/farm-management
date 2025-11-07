const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

db.get(
  'SELECT id, address_postal_code FROM farm_surveys WHERE id = ?',
  ['1761548400717'],
  (err, row) => {
    if (err) {
      console.error('❌ Error:', err.message);
    } else if (row) {
      console.log('✅ Survey ID:', row.id);
      console.log('📮 Postal Code:', row.address_postal_code || 'NULL');
    } else {
      console.log('❌ Survey not found');
    }
    db.close();
  }
);
