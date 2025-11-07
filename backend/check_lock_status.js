const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('farm_auth.db');

const username = process.argv[2] || 'nara';

console.log(`🔍 Checking lock status for: ${username}\n`);

db.get(`
  SELECT 
    username,
    failed_login_attempts,
    locked_until,
    CASE 
      WHEN locked_until IS NULL THEN 'NOT LOCKED'
      WHEN datetime(locked_until) > datetime('now') THEN 'LOCKED'
      ELSE 'LOCK EXPIRED'
    END as lock_status,
    CASE
      WHEN locked_until IS NOT NULL AND datetime(locked_until) > datetime('now')
      THEN CAST((julianday(locked_until) - julianday('now')) * 24 * 60 AS INTEGER)
      ELSE 0
    END as minutes_remaining
  FROM users 
  WHERE username = ?
`, [username], (err, user) => {
  if (err) {
    console.error('❌ Error:', err);
    db.close();
    return;
  }
  
  if (!user) {
    console.log(`❌ User "${username}" not found!`);
    db.close();
    return;
  }
  
  console.log('─'.repeat(60));
  console.log(`👤 Username: ${user.username}`);
  console.log(`🔢 Failed Attempts: ${user.failed_login_attempts || 0}/5`);
  console.log(`🔒 Lock Status: ${user.lock_status}`);
  
  if (user.locked_until) {
    console.log(`📅 Locked Until: ${user.locked_until}`);
    console.log(`⏰ Current Time: ${new Date().toISOString()}`);
    
    if (user.lock_status === 'LOCKED') {
      console.log(`⏳ Time Remaining: ${user.minutes_remaining} minutes`);
      console.log(`\n❌ Account is LOCKED. Please wait ${user.minutes_remaining} minutes.`);
    } else {
      console.log(`\n✅ Lock has EXPIRED. You can login now!`);
    }
  } else {
    console.log(`\n✅ Account is NOT LOCKED. You can login freely.`);
  }
  
  console.log('─'.repeat(60));
  
  db.close();
});
