-- ===============================================
-- Webboard (Q&A Forum) Database Schema
-- Created: 2025-10-31
-- ===============================================

-- ============ THREADS TABLE ============
CREATE TABLE IF NOT EXISTS forum_threads (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id TEXT NOT NULL,
  author_name TEXT NOT NULL,
  author_avatar TEXT,
  
  -- Guest contact (for non-logged-in users)
  email TEXT,
  phone TEXT,
  
  -- Category & Tags
  category TEXT NOT NULL,
  tags TEXT,  -- JSON array
  
  -- Status & Stats
  status TEXT DEFAULT 'open',  -- open, answered, solved, closed
  view_count INTEGER DEFAULT 0,
  reply_count INTEGER DEFAULT 0,
  upvote_count INTEGER DEFAULT 0,
  downvote_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  last_reply_at DATETIME,
  last_reply_by TEXT,
  
  -- Features
  is_pinned BOOLEAN DEFAULT 0,
  is_locked BOOLEAN DEFAULT 0,
  is_featured BOOLEAN DEFAULT 0,
  has_accepted_answer BOOLEAN DEFAULT 0,
  accepted_answer_id TEXT,
  
  -- Permissions
  allow_reply BOOLEAN DEFAULT 1,
  
  -- Attachments
  attachments TEXT  -- JSON array
);

-- ============ REPLIES TABLE ============
CREATE TABLE IF NOT EXISTS forum_replies (
  id TEXT PRIMARY KEY,
  thread_id TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id TEXT NOT NULL,
  author_name TEXT NOT NULL,
  author_avatar TEXT,
  
  -- Reply Features
  is_answer BOOLEAN DEFAULT 0,
  is_staff_reply BOOLEAN DEFAULT 0,
  is_expert_reply BOOLEAN DEFAULT 0,
  
  -- Nested Reply
  parent_reply_id TEXT,
  level INTEGER DEFAULT 0,  -- 0 = top-level, 1 = nested
  
  -- Stats
  upvote_count INTEGER DEFAULT 0,
  downvote_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  edited_at DATETIME,
  is_edited BOOLEAN DEFAULT 0,
  
  -- Moderation
  is_hidden BOOLEAN DEFAULT 0,
  hidden_reason TEXT,
  
  -- Attachments
  attachments TEXT,  -- JSON array
  
  FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
);

-- ============ VOTES TABLE (THREADS) ============
CREATE TABLE IF NOT EXISTS forum_thread_votes (
  id TEXT PRIMARY KEY,
  thread_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  vote_type TEXT NOT NULL,  -- 'up' or 'down'
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(thread_id, user_id),
  FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
);

-- ============ VOTES TABLE (REPLIES) ============
CREATE TABLE IF NOT EXISTS forum_reply_votes (
  id TEXT PRIMARY KEY,
  reply_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  vote_type TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(reply_id, user_id),
  FOREIGN KEY (reply_id) REFERENCES forum_replies(id) ON DELETE CASCADE
);

-- ============ BOOKMARKS TABLE ============
CREATE TABLE IF NOT EXISTS forum_bookmarks (
  id TEXT PRIMARY KEY,
  thread_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(thread_id, user_id),
  FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
);

-- ============ FOLLOWS TABLE ============
CREATE TABLE IF NOT EXISTS forum_follows (
  id TEXT PRIMARY KEY,
  thread_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  notify_on_reply BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(thread_id, user_id),
  FOREIGN KEY (thread_id) REFERENCES forum_threads(id) ON DELETE CASCADE
);

-- ============ INDEXES ============
CREATE INDEX IF NOT EXISTS idx_threads_category ON forum_threads(category);
CREATE INDEX IF NOT EXISTS idx_threads_status ON forum_threads(status);
CREATE INDEX IF NOT EXISTS idx_threads_author ON forum_threads(author_id);
CREATE INDEX IF NOT EXISTS idx_threads_created ON forum_threads(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_threads_pinned ON forum_threads(is_pinned DESC);

CREATE INDEX IF NOT EXISTS idx_replies_thread ON forum_replies(thread_id);
CREATE INDEX IF NOT EXISTS idx_replies_author ON forum_replies(author_id);
CREATE INDEX IF NOT EXISTS idx_replies_parent ON forum_replies(parent_reply_id);

CREATE INDEX IF NOT EXISTS idx_votes_thread ON forum_thread_votes(thread_id);
CREATE INDEX IF NOT EXISTS idx_votes_reply ON forum_reply_votes(reply_id);
