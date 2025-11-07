/**
 * ⚠️ IMPORTANT: Run this script from project root directory only!
 * Usage: node scripts/check_surveys.js
 * Database: ./backend/farm_auth.db
 */

const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const fs = require('fs');

// Validate we're running from correct directory
if (!fs.existsSync('./backend/farm_auth.db')) {
  console.error('❌ ERROR: Database not found at ./backend/farm_auth.db');
  console.error('📁 Please run this script from project root: D:\\Code\\farm');
  console.error('💡 Command: node scripts/check_surveys.js');
  process.exit(1);
}

async function checkDatabase() {
  let db;
  try {
    console.log('🔍 Checking livestock surveys database...');

    db = await open({
      filename: './backend/farm_auth.db',  // ✅ FIXED: Use correct path
      driver: sqlite3.Database
    });

    // Check if tables exist
    const farmSurveysExists = await db.get(`
      SELECT name FROM sqlite_master 
      WHERE type='table' AND name='farm_surveys'
    `);

    const livestockExists = await db.get(`
      SELECT name FROM sqlite_master 
      WHERE type='table' AND name='survey_livestock'
    `);

    if (!farmSurveysExists || !livestockExists) {
      console.log('❌ Required tables do not exist.');
      console.log(`   farm_surveys: ${farmSurveysExists ? '✓' : '✗'}`);
      console.log(`   survey_livestock: ${livestockExists ? '✓' : '✗'}`);
      return;
    }

    console.log('✅ All required tables exist.');

    // Count total records
    const surveyCount = await db.get('SELECT COUNT(*) as count FROM farm_surveys');
    const livestockCount = await db.get('SELECT COUNT(*) as count FROM survey_livestock');
    console.log(`📊 Total farm surveys: ${surveyCount.count}`);
    console.log(`📊 Total livestock records: ${livestockCount.count}`);

    if (surveyCount.count > 0) {
      console.log('\n📋 Sample farm surveys:');
      console.log('─'.repeat(80));
      
      // Get farm survey records
      const surveys = await db.all(`
        SELECT id, farmer_title, farmer_first_name, farmer_last_name, 
               address_province, created_at
        FROM farm_surveys 
        ORDER BY created_at DESC
        LIMIT 10
      `);

      for (const survey of surveys) {
        console.log(`${survey.farmer_title}${survey.farmer_first_name} ${survey.farmer_last_name}`);
        console.log(`    📍 ${survey.address_province}`);
        
        // Get livestock for this survey
        const livestock = await db.all(`
          SELECT livestock_type, count
          FROM survey_livestock
          WHERE survey_id = ?
        `, [survey.id]);
        
        livestock.forEach(animal => {
          console.log(`    🐄 ${animal.livestock_type}: ${animal.count} ตัว`);
        });
        console.log('');
      }

      // Summary by livestock type
      console.log('📈 Summary by Livestock Type:');
      console.log('─'.repeat(40));
      
      const summary = await db.all(`
        SELECT livestock_type, 
               COUNT(DISTINCT survey_id) as farm_count,
               SUM(count) as total_animals
        FROM survey_livestock 
        GROUP BY livestock_type 
        ORDER BY total_animals DESC
      `);

      summary.forEach(item => {
        console.log(`🐄 ${item.livestock_type.padEnd(20)} | ${item.farm_count.toString().padStart(2)} ฟาร์ม | ${item.total_animals.toString().padStart(4)} ตัว`);
      });

      // Summary by province
      console.log('\n🗺️ Summary by Province:');
      console.log('─'.repeat(40));
      
      const provinceSummary = await db.all(`
        SELECT fs.address_province as province, 
               COUNT(DISTINCT fs.id) as farm_count,
               SUM(sl.count) as total_animals
        FROM farm_surveys fs
        LEFT JOIN survey_livestock sl ON fs.id = sl.survey_id
        GROUP BY fs.address_province 
        ORDER BY total_animals DESC
      `);

      provinceSummary.forEach(item => {
        console.log(`📍 ${(item.province || 'ไม่ระบุ').padEnd(12)} | ${item.farm_count.toString().padStart(2)} ฟาร์ม | ${(item.total_animals || 0).toString().padStart(4)} ตัว`);
      });

    } else {
      console.log('📭 No records found in the database.');
    }

  } catch (error) {
    console.error('❌ Error checking database:', error);
  } finally {
    if (db) {
      await db.close();
      console.log('\n🔗 Database connection closed.');
    }
  }
}

checkDatabase();
