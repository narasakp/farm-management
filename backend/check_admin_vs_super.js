const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const DB_PATH = path.join(__dirname, 'farm_auth.db');
const db = new sqlite3.Database(DB_PATH);

console.log(`📂 Using database: ${DB_PATH}`);
console.log('');
console.log('🔍 Checking ADMIN vs SUPER_ADMIN permissions...\n');

const rolesToCompare = ['SUPER_ADMIN', 'ADMIN', 'AMPHOE_OFFICER', 'RESEARCHER'];
const rolePermissions = {};
let completed = 0;

rolesToCompare.forEach(roleCode => {
  db.all(`
    SELECT p.permission_code, p.permission_name, p.resource, p.action, r.level
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

    rolePermissions[roleCode] = {
      permissions: permissions || [],
      level: permissions[0]?.level || 0
    };
    completed++;

    if (completed === rolesToCompare.length) {
      displayAnalysis();
    }
  });
});

function displayAnalysis() {
  console.log('═'.repeat(80));
  console.log('\n📊 Roles Summary:\n');

  rolesToCompare.forEach(roleCode => {
    const data = rolePermissions[roleCode];
    const count = data.permissions.length;
    const level = data.level;
    console.log(`🔐 ${roleCode.padEnd(20)} Level ${level}    ${count} permissions`);
  });

  // Check hierarchy
  console.log('\n' + '═'.repeat(80));
  console.log('\n🎯 Hierarchy Check:\n');

  const superPerms = new Set(rolePermissions['SUPER_ADMIN'].permissions.map(p => p.permission_code));
  const adminPerms = new Set(rolePermissions['ADMIN'].permissions.map(p => p.permission_code));
  const amphoePerms = new Set(rolePermissions['AMPHOE_OFFICER'].permissions.map(p => p.permission_code));
  const researcherPerms = new Set(rolePermissions['RESEARCHER'].permissions.map(p => p.permission_code));

  // ADMIN should NOT have all SUPER_ADMIN permissions
  const superOnlyPerms = [...superPerms].filter(p => !adminPerms.has(p));
  const adminHasSuperPerms = [...adminPerms].filter(p => superPerms.has(p));

  console.log(`1️⃣  SUPER_ADMIN only (ADMIN shouldn't have these):`);
  if (superOnlyPerms.length > 0) {
    console.log(`   ✅ ${superOnlyPerms.length} permissions are exclusive to SUPER_ADMIN`);
    superOnlyPerms.forEach(p => console.log(`      • ${p}`));
  } else {
    console.log(`   ⚠️  No exclusive permissions - ADMIN has everything!`);
  }

  console.log(`\n2️⃣  Shared between SUPER_ADMIN and ADMIN:`);
  if (adminHasSuperPerms.length > 0) {
    console.log(`   ℹ️  ${adminHasSuperPerms.length} shared permissions (OK if appropriate)`);
  }

  // ADMIN should have MORE than AMPHOE_OFFICER and RESEARCHER
  const adminVsAmphoe = [...adminPerms].filter(p => !amphoePerms.has(p));
  const adminVsResearcher = [...adminPerms].filter(p => !researcherPerms.has(p));

  console.log(`\n3️⃣  ADMIN vs AMPHOE_OFFICER:`);
  console.log(`   ADMIN: ${adminPerms.size} permissions`);
  console.log(`   AMPHOE: ${amphoePerms.size} permissions`);
  if (adminPerms.size > amphoePerms.size) {
    console.log(`   ✅ ADMIN > AMPHOE_OFFICER (+${adminPerms.size - amphoePerms.size} more)`);
  } else {
    console.log(`   ❌ ADMIN should have more permissions!`);
  }

  console.log(`\n4️⃣  ADMIN vs RESEARCHER:`);
  console.log(`   ADMIN: ${adminPerms.size} permissions`);
  console.log(`   RESEARCHER: ${researcherPerms.size} permissions`);
  if (adminPerms.size > researcherPerms.size) {
    console.log(`   ✅ ADMIN > RESEARCHER (+${adminPerms.size - researcherPerms.size} more)`);
  } else {
    console.log(`   ❌ ADMIN should have more permissions!`);
  }

  // Check if ADMIN has inappropriate super powers
  console.log('\n' + '═'.repeat(80));
  console.log('\n⚠️  Checking for inappropriate SUPER permissions in ADMIN:\n');

  const dangerousPerms = [
    'users.create', 'users.update', 'users.delete',
    'roles.create', 'roles.update', 'roles.delete'
  ];

  const adminDangerous = dangerousPerms.filter(p => adminPerms.has(p));
  
  if (adminDangerous.length > 0) {
    console.log(`❌ ADMIN has ${adminDangerous.length} potentially dangerous permissions:`);
    adminDangerous.forEach(p => console.log(`   • ${p} (should be hierarchical only)`));
    console.log('');
    console.log('💡 These are OK if used with hierarchical middleware');
    console.log('   (ADMIN can only manage users/roles with lower level)');
  } else {
    console.log('✅ ADMIN does not have user/role management permissions');
  }

  console.log('\n' + '═'.repeat(80));
  console.log('\n📋 Recommendation:\n');

  if (superPerms.size === adminPerms.size) {
    console.log('❌ PROBLEM: ADMIN has ALL permissions from SUPER_ADMIN');
    console.log('   ADMIN should NOT be a super role!');
  } else if (adminPerms.size > researcherPerms.size && adminPerms.size > amphoePerms.size && adminPerms.size < superPerms.size) {
    console.log('✅ CORRECT: SUPER_ADMIN > ADMIN > (AMPHOE & RESEARCHER)');
  } else {
    console.log('⚠️  Permission hierarchy may need adjustment');
  }

  db.close();
}
