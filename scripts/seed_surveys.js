/**
 * ⚠️ IMPORTANT: Run this script from project root directory only!
 * Usage: node scripts/seed_surveys.js
 * Database: ./backend/farm_auth.db
 */

const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const fs = require('fs');

// Validate we're running from correct directory
if (!fs.existsSync('./backend/farm_auth.db')) {
  console.error('❌ ERROR: Database not found at ./backend/farm_auth.db');
  console.error('📁 Please run this script from project root: D:\\Code\\farm');
  console.error('💡 Command: node scripts/seed_surveys.js');
  process.exit(1);
}

const sampleSurveys = [
  {
    prefix: 'นาย',
    first_name: 'สมชาย',
    last_name: 'ใจดี',
    id_card_number: '1234567890123',
    phone_number: '0812345678',
    address_number: '15',
    address_village: 'บ้านโคก',
    address_moo: '3',
    address_tambon: 'ในเมือง',
    address_amphoe: 'เมืองชัยภูมิ',
    address_province: 'ชัยภูมิ',
    animal_type: 'วัว',
    animal_count: 25,
    notes: 'วัวพันธุ์ดี สุขภาพแข็งแรง'
  },
  {
    prefix: 'นาง',
    first_name: 'สมศรี',
    last_name: 'รักไทย',
    id_card_number: '2345678901234',
    phone_number: '0823456789',
    address_number: '42',
    address_village: 'บ้านนา',
    address_moo: '1',
    address_tambon: 'บ้านเขว้า',
    address_amphoe: 'บ้านเขว้า',
    address_province: 'ชัยภูมิ',
    animal_type: 'ควาย',
    animal_count: 18,
    notes: 'เลี้ยงแบบปล่อยทุ่ง'
  },
  {
    prefix: 'นาย',
    first_name: 'ประเสริฐ',
    last_name: 'มีสุข',
    id_card_number: '3456789012345',
    phone_number: '0834567890',
    address_number: '112',
    address_village: 'บ้านหินตั้ง',
    address_moo: '7',
    address_tambon: 'หินตั้ง',
    address_amphoe: 'ภูเขียว',
    address_province: 'ชัยภูมิ',
    animal_type: 'แพะ',
    animal_count: 50,
    notes: 'ฟาร์มแพะนม'
  },
    {
    prefix: 'นางสาว',
    first_name: 'มานี',
    last_name: 'ศรีเจริญ',
    id_card_number: '4567890123456',
    phone_number: '0845678901',
    address_number: '88',
    address_village: 'บ้านหนองบัว',
    address_moo: '5',
    address_tambon: 'หนองบัวแดง',
    address_amphoe: 'หนองบัวแดง',
    address_province: 'ชัยภูมิ',
    animal_type: 'วัว',
    animal_count: 32,
    notes: 'ต้องการคำแนะนำเรื่องอาหารเสริม'
  },
  {
    prefix: 'นาย',
    first_name: 'วิชัย',
    last_name: 'รุ่งเรือง',
    id_card_number: '5678901234567',
    phone_number: '0856789012',
    address_number: '210',
    address_village: 'บ้านโนน',
    address_moo: '9',
    address_tambon: 'แก้งคร้อ',
    address_amphoe: 'แก้งคร้อ',
    address_province: 'ชัยภูมิ',
    animal_type: 'วัว',
    animal_count: 15,
    notes: 'เพิ่งเริ่มเลี้ยง'
  },
  {
    prefix: 'นาง',
    first_name: 'อรทัย',
    last_name: 'งามยิ่ง',
    id_card_number: '6789012345678',
    phone_number: '0867890123',
    address_number: '55/1',
    address_village: 'บ้านป่า',
    address_moo: '2',
    address_tambon: 'ช่องสามหมอ',
    address_amphoe: 'คอนสวรรค์',
    address_province: 'ชัยภูมิ',
    animal_type: 'ควาย',
    animal_count: 8,
    notes: 'ควายเผือก 1 ตัว'
  },
  {
    prefix: 'นาย',
    first_name: 'อำนาจ',
    last_name: 'คงมั่น',
    id_card_number: '7890123456789',
    phone_number: '0878901234',
    address_number: '123',
    address_village: 'บ้านดอน',
    address_moo: '11',
    address_tambon: 'ในเมือง',
    address_amphoe: 'เมืองนครราชสีมา',
    address_province: 'นครราชสีมา',
    animal_type: 'วัว',
    animal_count: 45,
    notes: 'ฟาร์มขนาดใหญ่'
  },
  {
    prefix: 'นาง',
    first_name: 'สุพรรษา',
    last_name: 'โพธิ์งาม',
    id_card_number: '8901234567890',
    phone_number: '0889012345',
    address_number: '78',
    address_village: 'บ้านใหม่',
    address_moo: '4',
    address_tambon: 'จอหอ',
    address_amphoe: 'เมืองนครราชสีมา',
    address_province: 'นครราชสีมา',
    animal_type: 'แพะ',
    animal_count: 30,
    notes: ''
  },
  {
    prefix: 'นาย',
    first_name: 'เกรียงไกร',
    last_name: 'ชนะศึก',
    id_card_number: '9012345678901',
    phone_number: '0890123456',
    address_number: '333',
    address_village: 'บ้านสวน',
    address_moo: '8',
    address_tambon: 'ในเมือง',
    address_amphoe: 'เมืองขอนแก่น',
    address_province: 'ขอนแก่น',
    animal_type: 'วัว',
    animal_count: 100,
    notes: 'ส่งออกวัวมีชีวิต'
  },
  {
    prefix: 'นางสาว',
    first_name: 'ทิพวรรณ',
    last_name: 'จันทร',
    id_card_number: '1122334455667',
    phone_number: '0911223344',
    address_number: '9/10',
    address_village: 'บ้านมอ',
    address_moo: '12',
    address_tambon: 'ศิลา',
    address_amphoe: 'เมืองขอนแก่น',
    address_province: 'ขอนแก่น',
    animal_type: 'แกะ',
    animal_count: 40,
    notes: 'ฟาร์มแกะท่องเที่ยว'
  },
  {
    prefix: 'นาย',
    first_name: 'มนตรี',
    last_name: 'พงษ์สุวรรณ',
    id_card_number: '2233445566778',
    phone_number: '0922334455',
    address_number: '456',
    address_village: 'บ้านไร่',
    address_moo: '6',
    address_tambon: 'หนองไผ่',
    address_amphoe: 'หนองไผ่',
    address_province: 'เพชรบูรณ์',
    animal_type: 'วัว',
    animal_count: 12,
    notes: 'เลี้ยงวัวขุน'
  },
  {
    prefix: 'นาง',
    first_name: 'บุญเรือน',
    last_name: 'อมต',
    id_card_number: '3344556677889',
    phone_number: '0933445566',
    address_number: '789',
    address_village: 'บ้านกลาง',
    address_moo: '10',
    address_tambon: 'ท่าพล',
    address_amphoe: 'เมืองเพชรบูรณ์',
    address_province: 'เพชรบูรณ์',
    animal_type: 'ควาย',
    animal_count: 22,
    notes: 'ควายงาม'
  }
];

async function seedDatabase() {
  let db;
  try {
    console.log('🌱 Starting to seed the database...');

    db = await open({
      filename: './backend/farm_auth.db',  // ✅ FIXED: Use correct path
      driver: sqlite3.Database
    });

    // Ensure the tables exist before proceeding
    await db.exec(`
      CREATE TABLE IF NOT EXISTS farm_surveys (
        id TEXT PRIMARY KEY,
        farmer_id TEXT NOT NULL,
        surveyor_id TEXT,
        survey_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        farmer_title TEXT,
        farmer_first_name TEXT NOT NULL,
        farmer_last_name TEXT NOT NULL,
        farmer_id_card TEXT,
        farmer_phone TEXT,
        farmer_photo_base64 TEXT,
        address_house_number TEXT,
        address_village TEXT,
        address_moo TEXT,
        address_tambon TEXT,
        address_amphoe TEXT,
        address_province TEXT,
        crop_area REAL,
        notes TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS survey_livestock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        livestock_type TEXT NOT NULL,
        age_group TEXT,
        gender TEXT,
        count INTEGER NOT NULL,
        daily_milk_production REAL,
        notes TEXT,
        FOREIGN KEY (survey_id) REFERENCES farm_surveys(id) ON DELETE CASCADE
      );
    `);

    console.log('✔️ Tables `farm_surveys` and `survey_livestock` are ready.');

    // Check if table is empty before seeding
    const countResult = await db.get('SELECT COUNT(*) as count FROM farm_surveys');
    if (countResult.count > 0) {
      console.log('🟡 Database already contains survey data. Skipping seeding.');
      return;
    }

    // Insert into farm_surveys and survey_livestock
    let insertedCount = 0;
    for (const survey of sampleSurveys) {
      try {
        const surveyId = `survey_${Date.now()}_${insertedCount}`;
        
        // Insert farm survey
        await db.run(`
          INSERT INTO farm_surveys (
            id, farmer_id, surveyor_id, survey_date,
            farmer_title, farmer_first_name, farmer_last_name,
            farmer_id_card, farmer_phone,
            address_house_number, address_village, address_moo,
            address_tambon, address_amphoe, address_province,
            crop_area, notes
          ) VALUES (?, ?, ?, datetime('now'), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
          surveyId,
          `farmer_${survey.id_card_number}`,
          'officer_seed',
          survey.prefix,
          survey.first_name,
          survey.last_name,
          survey.id_card_number,
          survey.phone_number,
          survey.address_number,
          survey.address_village,
          survey.address_moo,
          survey.address_tambon,
          survey.address_amphoe,
          survey.address_province,
          2.5,
          survey.notes
        ]);
        
        // Insert livestock data
        await db.run(`
          INSERT INTO survey_livestock (
            survey_id, livestock_type, count
          ) VALUES (?, ?, ?)
        `, [surveyId, survey.animal_type, survey.animal_count]);
        
        insertedCount++;
      } catch (error) {
        if (error.message.includes('UNIQUE constraint failed')) {
          console.warn(`-  Skipping duplicate entry for ID card: ${survey.id_card_number}`);
        } else {
          console.error(`-  Failed to insert survey for ${survey.first_name}:`, error.message);
        }
      }
    }

    console.log(`✅ Successfully inserted ${insertedCount} out of ${sampleSurveys.length} sample surveys.`);

  } catch (error) {
    console.error('❌ An error occurred during database seeding:', error);
  } finally {
    if (db) {
      await db.close();
      console.log('🔗 Database connection closed.');
    }
  }
}

seedDatabase();
