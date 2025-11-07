/**
 * Create User Reputation & Statistics Tables
 * สำหรับระบบคะแนนและสถิติผู้ใช้ในกระทู้
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');

console.log('📊 Creating User Reputation & Statistics Tables...');
console.log('Database:', DB_PATH);

const db = new sqlite3.Database(DB_PATH);

db.serialize(() => {
  // ==========================================
  // 1. User Statistics Table
  // ==========================================
  db.run(`
    CREATE TABLE IF NOT EXISTS user_forum_stats (
      user_id TEXT PRIMARY KEY,
      reputation_points INTEGER DEFAULT 0,
      reputation_level TEXT DEFAULT 'beginner',
      threads_created INTEGER DEFAULT 0,
      replies_posted INTEGER DEFAULT 0,
      answers_accepted INTEGER DEFAULT 0,
      votes_received INTEGER DEFAULT 0,
      upvotes_received INTEGER DEFAULT 0,
      downvotes_received INTEGER DEFAULT 0,
      best_answers INTEGER DEFAULT 0,
      helpful_votes INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT (datetime('now')),
      updated_at DATETIME DEFAULT (datetime('now'))
    )
  `, (err) => {
    if (err) {
      console.error('❌ Error creating user_forum_stats:', err);
    } else {
      console.log('✅ Table: user_forum_stats');
    }
  });

  // ==========================================
  // 2. User Badges Table
  // ==========================================
  db.run(`
    CREATE TABLE IF NOT EXISTS user_badges (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      badge_type TEXT NOT NULL,
      badge_name TEXT NOT NULL,
      badge_description TEXT,
      earned_at DATETIME DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `, (err) => {
    if (err) {
      console.error('❌ Error creating user_badges:', err);
    } else {
      console.log('✅ Table: user_badges');
    }
  });

  // ==========================================
  // 3. Activity Log Table
  // ==========================================
  db.run(`
    CREATE TABLE IF NOT EXISTS forum_activity_log (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      activity_type TEXT NOT NULL,
      related_id TEXT,
      points_earned INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT (datetime('now'))
    )
  `, (err) => {
    if (err) {
      console.error('❌ Error creating forum_activity_log:', err);
    } else {
      console.log('✅ Table: forum_activity_log');
    }
  });

  // ==========================================
  // Create Indexes
  // ==========================================
  console.log('\n📑 Creating indexes...');

  db.run('CREATE INDEX IF NOT EXISTS idx_user_badges_user ON user_badges(user_id)', (err) => {
    if (err) console.error('❌ Error creating idx_user_badges_user:', err);
    else console.log('✅ Index: idx_user_badges_user');
  });

  db.run('CREATE INDEX IF NOT EXISTS idx_activity_log_user ON forum_activity_log(user_id)', (err) => {
    if (err) console.error('❌ Error creating idx_activity_log_user:', err);
    else console.log('✅ Index: idx_activity_log_user');
  });

  db.run('CREATE INDEX IF NOT EXISTS idx_activity_log_type ON forum_activity_log(activity_type)', (err) => {
    if (err) console.error('❌ Error creating idx_activity_log_type:', err);
    else console.log('✅ Index: idx_activity_log_type');
  });
});

db.close((err) => {
  if (err) {
    console.error('\n❌ Error closing database:', err);
  } else {
    console.log('\n✅ All tables and indexes created successfully!');
    console.log('🎉 User Reputation System ready!');
  }
});
