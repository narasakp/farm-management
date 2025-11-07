/**
 * Create Webboard (Q&A Forum) Tables
 * สร้างตารางสำหรับ Webboard
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const SQL_FILE = path.join(__dirname, 'create_webboard_tables.sql');

console.log('🗄️ Creating Webboard tables...');
console.log('📂 Database:', DB_PATH);
console.log('📄 SQL file:', SQL_FILE);

const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('❌ Error opening database:', err);
    process.exit(1);
  }
  console.log('✅ Connected to database');
});

// Execute SQL statements directly
db.serialize(() => {
  // Create forum_threads table
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_threads (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      author_id TEXT NOT NULL,
      author_name TEXT NOT NULL,
      author_avatar TEXT,
      email TEXT,
      phone TEXT,
      category TEXT NOT NULL,
      tags TEXT,
      status TEXT DEFAULT 'open',
      view_count INTEGER DEFAULT 0,
      reply_count INTEGER DEFAULT 0,
      upvote_count INTEGER DEFAULT 0,
      downvote_count INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      last_reply_at DATETIME,
      last_reply_by TEXT,
      is_pinned BOOLEAN DEFAULT 0,
      is_locked BOOLEAN DEFAULT 0,
      is_featured BOOLEAN DEFAULT 0,
      has_accepted_answer BOOLEAN DEFAULT 0,
      accepted_answer_id TEXT,
      allow_reply BOOLEAN DEFAULT 1,
      attachments TEXT
    )
  `, (err) => {
    if (err) console.error('❌ Error creating forum_threads:', err);
    else console.log('✅ Created: forum_threads');
  });

  // Create forum_replies table
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_replies (
      id TEXT PRIMARY KEY,
      thread_id TEXT NOT NULL,
      content TEXT NOT NULL,
      author_id TEXT NOT NULL,
      author_name TEXT NOT NULL,
      author_avatar TEXT,
      is_answer BOOLEAN DEFAULT 0,
      is_staff_reply BOOLEAN DEFAULT 0,
      is_expert_reply BOOLEAN DEFAULT 0,
      parent_reply_id TEXT,
      level INTEGER DEFAULT 0,
      upvote_count INTEGER DEFAULT 0,
      downvote_count INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      edited_at DATETIME,
      is_edited BOOLEAN DEFAULT 0,
      is_hidden BOOLEAN DEFAULT 0,
      hidden_reason TEXT,
      attachments TEXT,
      FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
    )
  `, (err) => {
    if (err) console.error('❌ Error creating forum_replies:', err);
    else console.log('✅ Created: forum_replies');
  });

  // Create forum_thread_votes table
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_thread_votes (
      id TEXT PRIMARY KEY,
      thread_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      vote_type TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(thread_id, user_id),
      FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
    )
  `, (err) => {
    if (err) console.error('❌ Error creating forum_thread_votes:', err);
    else console.log('✅ Created: forum_thread_votes');
  });

  // Create forum_reply_votes table
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_reply_votes (
      id TEXT PRIMARY KEY,
      reply_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      vote_type TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(reply_id, user_id),
      FOREIGN KEY (reply_id) REFERENCES forum_replies(id) ON DELETE CASCADE
    )
  `, (err) => {
    if (err) console.error('❌ Error creating forum_reply_votes:', err);
    else console.log('✅ Created: forum_reply_votes');
  });

  // Create forum_bookmarks table
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_bookmarks (
      id TEXT PRIMARY KEY,
      thread_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(thread_id, user_id),
      FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
    )
  `, (err) => {
    if (err) console.error('❌ Error creating forum_bookmarks:', err);
    else console.log('✅ Created: forum_bookmarks');
  });

  // Create forum_follows table
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_follows (
      id TEXT PRIMARY KEY,
      thread_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      notify_on_reply BOOLEAN DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(thread_id, user_id),
      FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
    )
  `, (err) => {
    if (err) console.error('❌ Error creating forum_follows:', err);
    else console.log('✅ Created: forum_follows');
  });

  // Create indexes
  db.run('CREATE INDEX IF NOT EXISTS idx_threads_category ON forum_threads(category)');
  db.run('CREATE INDEX IF NOT EXISTS idx_threads_status ON forum_threads(status)');
  db.run('CREATE INDEX IF NOT EXISTS idx_threads_author ON forum_threads(author_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_threads_created ON forum_threads(created_at DESC)');
  db.run('CREATE INDEX IF NOT EXISTS idx_threads_pinned ON forum_threads(is_pinned DESC)');
  db.run('CREATE INDEX IF NOT EXISTS idx_replies_thread ON forum_replies(thread_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_replies_author ON forum_replies(author_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_replies_parent ON forum_replies(parent_reply_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_votes_thread ON forum_thread_votes(thread_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_votes_reply ON forum_reply_votes(reply_id)', (err) => {
    if (!err) console.log('✅ Created: All indexes');
  });
});

db.close((err) => {
  if (err) {
    console.error('❌ Error closing database:', err);
  } else {
    console.log('\n🎉 Webboard tables created successfully!');
    console.log('\n📊 Tables created:');
    console.log('  - forum_threads');
    console.log('  - forum_replies');
    console.log('  - forum_thread_votes');
    console.log('  - forum_reply_votes');
    console.log('  - forum_bookmarks');
    console.log('  - forum_follows');
    console.log('\n✅ Ready to use Webboard features!');
  }
});
