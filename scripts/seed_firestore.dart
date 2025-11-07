import 'package:cloud_firestore/cloud_firestore.dart';

/// 🚀 Script เพิ่มข้อมูล Sample อัตโนมัติ
/// 
/// วิธีใช้:
/// 1. เปิด Flutter app ที่ localhost:8096
/// 2. เปิด Browser Console (F12)
/// 3. Copy โค้ดด้านล่างไป Paste ใน Console
/// 4. กด Enter
/// 
/// ข้อมูลจะถูกเพิ่มเข้า Firestore ทันที!

void main() {
  print('ใช้วิธี Browser Console แทน - ดูด้านล่าง');
}

/// 📋 COPY โค้ดนี้ไป PASTE ใน Browser Console (F12):

/*

// ⚡ Script เพิ่มข้อมูล Firestore อัตโนมัติ
(async function() {
  console.log('🔥 เริ่มเพิ่มข้อมูล Sample...');
  
  const db = firebase.firestore();
  
  const sampleData = [
    {
      farmId: 'farm001',
      livestockId: 'cattle001',
      askingPrice: 45000,
      minPrice: 42000,
      description: 'โคเนื้อบราห์มันคุณภาพดี อายุ 2 ปี น้ำหนัก 450 กก.',
      isNegotiable: true,
      status: 'active',
      viewCount: 15,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm002',
      livestockId: 'pig001',
      askingPrice: 8500,
      minPrice: 8000,
      description: 'สุกรพันธุ์แลนด์เรซ น้ำหนัก 95 กก. พร้อมขาย',
      isNegotiable: true,
      status: 'active',
      viewCount: 8,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm001',
      livestockId: 'chicken001',
      askingPrice: 150,
      minPrice: 140,
      description: 'ไก่ไข่สายพันธุ์ดี ให้ไข่ดี อายุ 6 เดือน',
      isNegotiable: true,
      status: 'active',
      viewCount: 23,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm003',
      livestockId: 'duck001',
      askingPrice: 180,
      description: 'เป็ดไข่เทศ อายุ 7 เดือน ให้ไข่ดีมาก',
      isNegotiable: false,
      status: 'active',
      viewCount: 12,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm002',
      livestockId: 'goat001',
      askingPrice: 6500,
      minPrice: 6000,
      description: 'แพะนมพันธุ์ดี ให้นมดี อายุ 1.5 ปี',
      isNegotiable: true,
      status: 'active',
      viewCount: 19,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm001',
      livestockId: 'cattle002',
      askingPrice: 38000,
      minPrice: 35000,
      description: 'โคนมโฮลสไตน์ ให้นม 25 ลิตร/วัน',
      isNegotiable: true,
      status: 'active',
      viewCount: 31,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm004',
      livestockId: 'pig002',
      askingPrice: 7800,
      minPrice: 7500,
      description: 'สุกรดูรอค น้ำหนัก 88 กก.',
      isNegotiable: true,
      status: 'active',
      viewCount: 5,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
    {
      farmId: 'farm003',
      livestockId: 'chicken002',
      askingPrice: 120,
      description: 'ไก่เนื้อพร้อมขาย น้ำหนัก 2.5 กก./ตัว',
      isNegotiable: false,
      status: 'active',
      viewCount: 17,
      listedDate: firebase.firestore.Timestamp.now(),
      createdAt: firebase.firestore.Timestamp.now(),
    },
  ];
  
  const batch = db.batch();
  const collectionRef = db.collection('market_listings');
  
  sampleData.forEach((data) => {
    const docRef = collectionRef.doc();
    batch.set(docRef, data);
  });
  
  await batch.commit();
  
  console.log('✅ เพิ่มข้อมูล ' + sampleData.length + ' รายการสำเร็จ!');
  console.log('🔄 กำลัง Reload หน้าเว็บ...');
  
  setTimeout(() => {
    window.location.reload();
  }, 1000);
})();

*/
