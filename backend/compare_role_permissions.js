const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);
console.log('');
console.log('🔍 Comparing permissions...\n');

const rolesToCompare = ['ADMIN', 'RESEARCHER', 'AMPHOE_OFFICER'];

// Get permissions for each role
const rolePermissions = {};

let completed = 0;

rolesToCompare.forEach(roleCode => {
  db.all(`
    SELECT p.permission_code, p.permission_name, p.resource, p.action
    FROM permissions p
    JOIN role_permissions rp ON p.permission_id = rp.permission_id
    JOIN roles r ON rp.role_id = r.role_id
    WHERE r.role_code = ?
    ORDER BY p.resource, p.action
  `, [roleCode], (err, permissions) => {
    if (err) {
      console.error(`❌ Error getting ${roleCode} permissions:`, err);
      completed++;
      return;
    }

    rolePermissions[roleCode] = permissions || [];
    completed++;

    if (completed === rolesToCompare.length) {
      displayComparison();
    }
  });
});

function displayComparison() {
  console.log('═'.repeat(80));
  console.log('\n📊 Permissions Comparison:\n');

  rolesToCompare.forEach(roleCode => {
    const perms = rolePermissions[roleCode];
    console.log(`\n🔐 ${roleCode}: ${perms.length} permissions`);
    
    // Group by resource
    const byResource = {};
    perms.forEach(p => {
      if (!byResource[p.resource]) {
        byResource[p.resource] = [];
      }
      byResource[p.resource].push(p);
    });

    Object.keys(byResource).sort().forEach(resource => {
      console.log(`   📦 ${resource}:`);
      byResource[resource].forEach(p => {
        console.log(`      • ${p.permission_code}`);
      });
    });
  });

  // Find missing permissions in ADMIN
  console.log('\n' + '═'.repeat(80));
  console.log('\n🔍 Missing in ADMIN:\n');

  const adminPerms = new Set(rolePermissions['ADMIN'].map(p => p.permission_code));
  const researcherPerms = rolePermissions['RESEARCHER'].map(p => p.permission_code);
  const amphoePerms = rolePermissions['AMPHOE_OFFICER'].map(p => p.permission_code);

  const missingFromResearcher = researcherPerms.filter(p => !adminPerms.has(p));
  const missingFromAmphoe = amphoePerms.filter(p => !adminPerms.has(p));

  if (missingFromResearcher.length > 0) {
    console.log('❌ Missing from RESEARCHER:');
    missingFromResearcher.forEach(p => console.log(`   • ${p}`));
    console.log('');
  }

  if (missingFromAmphoe.length > 0) {
    console.log('❌ Missing from AMPHOE_OFFICER:');
    missingFromAmphoe.forEach(p => console.log(`   • ${p}`));
    console.log('');
  }

  // Combine all missing
  const allMissing = [...new Set([...missingFromResearcher, ...missingFromAmphoe])];

  if (allMissing.length === 0) {
    console.log('✅ ADMIN has all permissions from RESEARCHER and AMPHOE_OFFICER!');
  } else {
    console.log('═'.repeat(80));
    console.log(`\n📋 Total missing permissions: ${allMissing.length}\n`);
    
    // Get full permission details
    const placeholders = allMissing.map(() => '?').join(',');
    db.all(`
      SELECT permission_id, permission_code, permission_name, resource, action
      FROM permissions
      WHERE permission_code IN (${placeholders})
    `, allMissing, (err, fullPerms) => {
      if (err) {
        console.error('❌ Error:', err);
        db.close();
        return;
      }

      console.log('💡 Run this to add missing permissions:\n');
      console.log('```javascript');
      console.log('// Add these permissions to ADMIN role');
      console.log('const missingPermissions = [');
      fullPerms.forEach((p, i) => {
        const comma = i < fullPerms.length - 1 ? ',' : '';
        console.log(`  '${p.permission_code}'${comma}`);
      });
      console.log('];');
      console.log('```');

      db.close();
    });
  }
}
