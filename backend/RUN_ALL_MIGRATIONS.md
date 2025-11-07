# Run All Migrations - Quick Guide

## 🚀 Quick Start

### Windows (PowerShell):
```powershell
cd d:\Code\farm\backend

# Migration 1: Mentions
node migrations/create_mentions_tables.js

# Migration 2: Activities
node migrations/create_user_activities.js

# Migration 3: FTS
node migrations/create_fts_tables.js

# Restart Server
node server.js
```

---

## ✅ Expected Output

### Migration 1: Mentions
```
🔧 Creating mentions tables...
✅ thread_mentions table created successfully
✅ reply_mentions table created successfully
✅ Mentions migration completed
✅ Migration successful
```

### Migration 2: Activities
```
🔧 Creating user_activities table...
✅ user_activities table created successfully
✅ Index created on user_activities(user_id)
✅ Index created on user_activities(activity_type)
✅ Index created on user_activities(created_at)
✅ User activities migration completed
✅ Migration successful
```

### Migration 3: FTS
```
🔍 Creating FTS virtual tables...
✅ forum_threads_fts virtual table created
✅ forum_replies_fts virtual table created
📊 Populating FTS tables with existing data...
✅ forum_threads_fts populated
✅ forum_replies_fts populated
🔗 Creating triggers for automatic FTS sync...
✅ Trigger: forum_threads_ai created
✅ Trigger: forum_threads_au created
✅ Trigger: forum_threads_ad created
✅ Trigger: forum_replies_ai created
✅ Trigger: forum_replies_au created
✅ Trigger: forum_replies_ad created
✅ FTS migration completed
✅ FTS Migration successful
```

---

## 🔍 Verify Migrations

```bash
# Open SQLite database
sqlite3 farm_auth.db

# Check tables
.tables

# Expected output includes:
# - thread_mentions
# - reply_mentions
# - user_activities
# - forum_threads_fts
# - forum_replies_fts

# Check triggers
SELECT name FROM sqlite_master WHERE type='trigger';

# Expected: 6 triggers
# - forum_threads_ai, forum_threads_au, forum_threads_ad
# - forum_replies_ai, forum_replies_au, forum_replies_ad

# Exit SQLite
.quit
```

---

## ⚠️ Troubleshooting

### Migration Already Run:
If you see "table already exists" errors, that's OK! The migrations use `CREATE TABLE IF NOT EXISTS`.

### FTS Tables Empty:
```sql
-- Check count
SELECT COUNT(*) FROM forum_threads_fts;
SELECT COUNT(*) FROM forum_replies_fts;

-- If zero, manually populate:
DELETE FROM forum_threads_fts;
INSERT INTO forum_threads_fts (id, title, content, author_name, tags, category)
SELECT id, title, content, author_name, tags, category FROM forum_threads;

DELETE FROM forum_replies_fts;
INSERT INTO forum_replies_fts (id, content, author_name, thread_id)
SELECT id, content, author_name, thread_id FROM forum_replies;
```

### Server Won't Start:
- Check port 3000 is not in use
- Kill existing node processes: `taskkill /F /IM node.exe`
- Run server again: `node server.js`

---

## 🧹 Reset Migrations (If Needed)

**⚠️ WARNING: This will delete ALL data in these tables!**

```sql
-- Open database
sqlite3 farm_auth.db

-- Drop tables
DROP TABLE IF EXISTS thread_mentions;
DROP TABLE IF EXISTS reply_mentions;
DROP TABLE IF EXISTS user_activities;
DROP TABLE IF EXISTS forum_threads_fts;
DROP TABLE IF EXISTS forum_replies_fts;

-- Drop triggers
DROP TRIGGER IF EXISTS forum_threads_ai;
DROP TRIGGER IF EXISTS forum_threads_au;
DROP TRIGGER IF EXISTS forum_threads_ad;
DROP TRIGGER IF EXISTS forum_replies_ai;
DROP TRIGGER IF EXISTS forum_replies_au;
DROP TRIGGER IF EXISTS forum_replies_ad;

-- Exit
.quit

-- Re-run migrations
node migrations/create_mentions_tables.js
node migrations/create_user_activities.js
node migrations/create_fts_tables.js
```

---

## 📝 Migration Files

1. `migrations/create_mentions_tables.js` - Mention system tables
2. `migrations/create_user_activities.js` - Activity tracking table
3. `migrations/create_fts_tables.js` - Full-text search tables & triggers

---

**Quick Command Copy-Paste:**
```powershell
cd d:\Code\farm\backend && node migrations/create_mentions_tables.js && node migrations/create_user_activities.js && node migrations/create_fts_tables.js && node server.js
```
