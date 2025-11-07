const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

/**
 * เพิ่ม geographic columns ใน users table
 * สำหรับ RBAC geographic scope (tambon, amphoe, province)
 */
function addGeographicColumns() {
  const db = new sqlite3.Database(DB_PATH);

  console.log('🔧 Adding geographic columns to users table...\n');

  return new Promise((resolve, reject) => {
    db.serialize(() => {
      db.run('BEGIN TRANSACTION');

      const columns = [
        {
          name: 'tambon_code',
          sql: 'ALTER TABLE users ADD COLUMN tambon_code TEXT',
        },
        {
          name: 'amphoe_code',
          sql: 'ALTER TABLE users ADD COLUMN amphoe_code TEXT',
        },
        {
          name: 'province_code',
          sql: 'ALTER TABLE users ADD COLUMN province_code TEXT',
        },
      ];

      let completed = 0;
      let errors = [];

      columns.forEach((col) => {
        // เช็คว่ามี column นี้แล้วหรือยัง
        db.get(
          `SELECT COUNT(*) as count FROM pragma_table_info('users') WHERE name = ?`,
          [col.name],
          (err, row) => {
            if (err) {
              errors.push(`Error checking ${col.name}: ${err.message}`);
              completed++;
              if (completed === columns.length) {
                finishProcess();
              }
              return;
            }

            if (row.count > 0) {
              console.log(`⏭️  Skip: ${col.name} (already exists)`);
              completed++;
              if (completed === columns.length) {
                finishProcess();
              }
            } else {
              // Add column
              db.run(col.sql, (err) => {
                if (err) {
                  errors.push(`Error adding ${col.name}: ${err.message}`);
                } else {
                  console.log(`✅ Added: ${col.name}`);
                }

                completed++;
                if (completed === columns.length) {
                  finishProcess();
                }
              });
            }
          }
        );
      });

      function finishProcess() {
        if (errors.length > 0) {
          console.error('\n❌ Errors occurred:');
          errors.forEach((err) => console.error(`  - ${err}`));
          db.run('ROLLBACK', () => {
            db.close();
            reject(new Error('Failed to add columns'));
          });
        } else {
          db.run('COMMIT', (err) => {
            if (err) {
              console.error('❌ Commit failed:', err);
              db.close();
              reject(err);
            } else {
              console.log('\n✅ Geographic columns added successfully!');
              console.log('\nColumns added:');
              console.log('  - tambon_code (TEXT)');
              console.log('  - amphoe_code (TEXT)');
              console.log('  - province_code (TEXT)');
              
              db.close();
              resolve();
            }
          });
        }
      }
    });
  });
}

// Run if called directly
if (require.main === module) {
  addGeographicColumns()
    .then(() => {
      console.log('\n🎉 Done! You can now create test users.');
      process.exit(0);
    })
    .catch((err) => {
      console.error('\n💥 Fatal error:', err);
      process.exit(1);
    });
}

module.exports = { addGeographicColumns };
