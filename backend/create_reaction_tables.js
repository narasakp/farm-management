/**
 * Create Emoji Reactions Tables
 * สำหรับระบบรีแอคชั่นด้วย emoji
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

console.log('😊 Creating Emoji Reactions Tables...');
console.log('Database:', DB_PATH);

const db = new sqlite3.Database(DB_PATH);

db.serialize(() => {
  // ==========================================
  // Forum Reactions Table
  // ==========================================
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_reactions (
      id TEXT PRIMARY KEY,
      content_type TEXT NOT NULL,
      content_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      user_name TEXT NOT NULL,
      emoji TEXT NOT NULL,
      created_at DATETIME DEFAULT (datetime('now')),
      UNIQUE(content_type, content_id, user_id, emoji)
    )
  `, (err) => {
    if (err) {
      console.error('❌ Error creating forum_reactions:', err);
    } else {
      console.log('✅ Table: forum_reactions');
    }
  });

  // ==========================================
  // Create Indexes
  // ==========================================
  console.log('\n📑 Creating indexes...');

  db.run('CREATE INDEX IF NOT EXISTS idx_reactions_content ON forum_reactions(content_type, content_id)', (err) => {
    if (err) console.error('❌ Error creating idx_reactions_content:', err);
    else console.log('✅ Index: idx_reactions_content');
  });

  db.run('CREATE INDEX IF NOT EXISTS idx_reactions_user ON forum_reactions(user_id)', (err) => {
    if (err) console.error('❌ Error creating idx_reactions_user:', err);
    else console.log('✅ Index: idx_reactions_user');
  });
});

db.close((err) => {
  if (err) {
    console.error('\n❌ Error closing database:', err);
  } else {
    console.log('\n✅ All tables and indexes created successfully!');
    console.log('🎉 Emoji Reactions System ready!');
  }
});
