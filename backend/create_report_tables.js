/**
 * Create Report System Tables
 * สำหรับระบบรายงานเนื้อหาที่ไม่เหมาะสม
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

console.log('🚨 Creating Report System Tables...');
console.log('Database:', DB_PATH);

const db = new sqlite3.Database(DB_PATH);

db.serialize(() => {
  // ==========================================
  // Content Reports Table
  // ==========================================
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_reports (
      id TEXT PRIMARY KEY,
      reporter_id TEXT NOT NULL,
      reporter_name TEXT NOT NULL,
      content_type TEXT NOT NULL,
      content_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      description TEXT,
      status TEXT DEFAULT 'pending',
      reviewed_by TEXT,
      reviewed_at DATETIME,
      admin_note TEXT,
      created_at DATETIME DEFAULT (datetime('now'))
    )
  `, (err) => {
    if (err) {
      console.error('❌ Error creating forum_reports:', err);
    } else {
      console.log('✅ Table: forum_reports');
    }
  });

  // ==========================================
  // Create Indexes
  // ==========================================
  console.log('\n📑 Creating indexes...');

  db.run('CREATE INDEX IF NOT EXISTS idx_reports_content ON forum_reports(content_type, content_id)', (err) => {
    if (err) console.error('❌ Error creating idx_reports_content:', err);
    else console.log('✅ Index: idx_reports_content');
  });

  db.run('CREATE INDEX IF NOT EXISTS idx_reports_status ON forum_reports(status)', (err) => {
    if (err) console.error('❌ Error creating idx_reports_status:', err);
    else console.log('✅ Index: idx_reports_status');
  });

  db.run('CREATE INDEX IF NOT EXISTS idx_reports_reporter ON forum_reports(reporter_id)', (err) => {
    if (err) console.error('❌ Error creating idx_reports_reporter:', err);
    else console.log('✅ Index: idx_reports_reporter');
  });
});

db.close((err) => {
  if (err) {
    console.error('\n❌ Error closing database:', err);
  } else {
    console.log('\n✅ All tables and indexes created successfully!');
    console.log('🎉 Report System ready!');
  }
});
