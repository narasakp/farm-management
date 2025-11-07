const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./farm_auth.db');

console.log('🔧 Adding vote and views features...\n');

// 1. Add columns to feedback table
const alterFeedback = `
  ALTER TABLE feedback 
  ADD COLUMN votes INTEGER DEFAULT 0,
  ADD COLUMN views INTEGER DEFAULT 0,
  ADD COLUMN last_activity DATETIME
`;

// 2. Create feedback_votes table (track who voted)
const createVotesTable = `
CREATE TABLE IF NOT EXISTS feedback_votes (
  id TEXT PRIMARY KEY,
  feedback_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  vote_type TEXT CHECK(vote_type IN ('up', 'down')) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(feedback_id, user_id),
  FOREIGN KEY (feedback_id) REFERENCES feedback(id) ON DELETE CASCADE
)`;

// 3. Create reply_votes table
const createReplyVotesTable = `
CREATE TABLE IF NOT EXISTS reply_votes (
  id TEXT PRIMARY KEY,
  reply_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  vote_type TEXT CHECK(vote_type IN ('up', 'down')) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(reply_id, user_id),
  FOREIGN KEY (reply_id) REFERENCES feedback_replies(id) ON DELETE CASCADE
)`;

// 4. Add votes column to feedback_replies
const alterReplies = `
  ALTER TABLE feedback_replies 
  ADD COLUMN votes INTEGER DEFAULT 0,
  ADD COLUMN is_best_answer INTEGER DEFAULT 0
`;

async function migrate() {
  return new Promise((resolve, reject) => {
    db.serialize(() => {
      // Check if columns already exist
      db.get("PRAGMA table_info(feedback)", (err, row) => {
        if (err) {
          console.error('❌ Error checking feedback table:', err);
          reject(err);
          return;
        }
        
        // Add columns to feedback (catch error if already exists)
        db.run(`ALTER TABLE feedback ADD COLUMN votes INTEGER DEFAULT 0`, (err) => {
          if (err && !err.message.includes('duplicate column')) {
            console.error('❌ Error adding votes to feedback:', err);
          } else if (!err) {
            console.log('✅ Added votes column to feedback');
          }
        });
        
        db.run(`ALTER TABLE feedback ADD COLUMN views INTEGER DEFAULT 0`, (err) => {
          if (err && !err.message.includes('duplicate column')) {
            console.error('❌ Error adding views to feedback:', err);
          } else if (!err) {
            console.log('✅ Added views column to feedback');
          }
        });
        
        db.run(`ALTER TABLE feedback ADD COLUMN last_activity DATETIME`, (err) => {
          if (err && !err.message.includes('duplicate column')) {
            console.error('❌ Error adding last_activity to feedback:', err);
          } else if (!err) {
            console.log('✅ Added last_activity column to feedback');
          }
        });
        
        // Create votes tables
        db.run(createVotesTable, (err) => {
          if (err) {
            console.error('❌ Error creating feedback_votes table:', err);
          } else {
            console.log('✅ Created feedback_votes table');
          }
        });
        
        db.run(createReplyVotesTable, (err) => {
          if (err) {
            console.error('❌ Error creating reply_votes table:', err);
          } else {
            console.log('✅ Created reply_votes table');
          }
        });
        
        // Add columns to replies
        db.run(`ALTER TABLE feedback_replies ADD COLUMN votes INTEGER DEFAULT 0`, (err) => {
          if (err && !err.message.includes('duplicate column')) {
            console.error('❌ Error adding votes to replies:', err);
          } else if (!err) {
            console.log('✅ Added votes column to feedback_replies');
          }
        });
        
        db.run(`ALTER TABLE feedback_replies ADD COLUMN is_best_answer INTEGER DEFAULT 0`, (err) => {
          if (err && !err.message.includes('duplicate column')) {
            console.error('❌ Error adding is_best_answer to replies:', err);
          } else if (!err) {
            console.log('✅ Added is_best_answer column to feedback_replies');
          }
          
          // Create indexes
          db.run('CREATE INDEX IF NOT EXISTS idx_feedback_votes ON feedback_votes(feedback_id)', (err) => {
            if (!err) console.log('✅ Created index on feedback_votes');
          });
          
          db.run('CREATE INDEX IF NOT EXISTS idx_reply_votes ON reply_votes(reply_id)', (err) => {
            if (!err) console.log('✅ Created index on reply_votes');
          });
          
          // Update last_activity for existing feedbacks
          db.run(`
            UPDATE feedback 
            SET last_activity = created_at 
            WHERE last_activity IS NULL
          `, (err) => {
            if (!err) console.log('✅ Updated last_activity for existing feedbacks');
            
            console.log('\n🎉 Migration completed!');
            db.close();
            resolve();
          });
        });
      });
    });
  });
}

migrate().catch(console.error);
