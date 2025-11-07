import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script สำหรับเพิ่ม Sample Data ใน Firestore
/// รัน: dart run scripts/add_sample_trading_data.dart

Future<void> main() async {
  print('🔥 กำลังเชื่อมต่อ Firebase...');
  
  // Initialize Firebase (ต้องมี firebase_options.dart)
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  print('📝 กำลังเพิ่ม Sample Market Listings...');
  
  // Sample Market Listings
  final sampleListings = [
    {
      'farmId': 'farm001',
      'livestockId': 'cattle001',
      'askingPrice': 45000.0,
      'minPrice': 42000.0,
      'description': 'โคเนื้อบราห์มันคุณภาพดี อายุ 2 ปี น้ำหนัก 450 กก.',
      'images': [
        'https://via.placeholder.com/400x300/8D6E63/FFFFFF?text=Brahman+Bull',
      ],
      'isNegotiable': true,
      'listedDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
      'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 28))),
      'status': 'active',
      'viewCount': 15,
      'createdAt': Timestamp.now(),
      'shareTitle': '🐂 โคเนื้อบราห์มันคุณภาพ A+',
      'shareDescription': 'โคเนื้อพันธุ์ดี สุขภาพแข็งแรง พร้อมส่งมอบ',
      'shareTags': ['โคเนื้อ', 'บราห์มัน', 'ปศุสัตว์', 'ขายโค'],
    },
    {
      'farmId': 'farm002',
      'livestockId': 'pig001',
      'askingPrice': 8500.0,
      'minPrice': 8000.0,
      'description': 'สุกรพันธุ์แลนด์เรซ น้ำหนัก 95 กก. พร้อมขาย',
      'images': [
        'https://via.placeholder.com/400x300/F8BBD0/FFFFFF?text=Pig',
      ],
      'isNegotiable': true,
      'listedDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
      'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 29))),
      'status': 'active',
      'viewCount': 8,
      'createdAt': Timestamp.now(),
      'shareTitle': '🐷 สุกรพันธุ์ดีพร้อมขาย',
      'shareDescription': 'สุกรแลนด์เรซ น้ำหนักดี สุขภาพดี',
      'shareTags': ['สุกร', 'แลนด์เรซ', 'ปศุสัตว์'],
    },
    {
      'farmId': 'farm001',
      'livestockId': 'chicken001',
      'askingPrice': 150.0,
      'minPrice': 140.0,
      'description': 'ไก่ไข่สายพันธุ์ดี ให้ไข่ดี อายุ 6 เดือน',
      'images': [
        'https://via.placeholder.com/400x300/FFE082/FFFFFF?text=Chicken',
      ],
      'isNegotiable': true,
      'listedDate': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 12))),
      'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
      'status': 'active',
      'viewCount': 23,
      'createdAt': Timestamp.now(),
      'shareTitle': '🐔 ไก่ไข่พันธุ์ดี ให้ผลผลิตสูง',
      'shareDescription': 'ไก่ไข่สายพันธุ์ดี เริ่มให้ไข่แล้ว',
      'shareTags': ['ไก่ไข่', 'ไก่', 'ปศุสัตว์'],
    },
    {
      'farmId': 'farm003',
      'livestockId': 'duck001',
      'askingPrice': 180.0,
      'description': 'เป็ดไข่เทศ อายุ 7 เดือน ให้ไข่ดีมาก',
      'images': [
        'https://via.placeholder.com/400x300/FFF59D/FFFFFF?text=Duck',
      ],
      'isNegotiable': false,
      'listedDate': Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 6))),
      'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 25))),
      'status': 'active',
      'viewCount': 12,
      'createdAt': Timestamp.now(),
      'shareTitle': '🦆 เป็ดไข่เทศคุณภาพ',
      'shareDescription': 'เป็ดไข่ให้ผลผลิตดี ขายคู่ได้',
      'shareTags': ['เป็ด', 'เป็ดไข่', 'ปศุสัตว์'],
    },
    {
      'farmId': 'farm002',
      'livestockId': 'goat001',
      'askingPrice': 6500.0,
      'minPrice': 6000.0,
      'description': 'แพะนมพันธุ์ดี ให้นมดี อายุ 1.5 ปี',
      'images': [
        'https://via.placeholder.com/400x300/A5D6A7/FFFFFF?text=Goat',
      ],
      'isNegotiable': true,
      'listedDate': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
      'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 27))),
      'status': 'active',
      'viewCount': 19,
      'createdAt': Timestamp.now(),
      'shareTitle': '🐐 แพะนมพันธุ์ดี ให้นมดี',
      'shareDescription': 'แพะนมสุขภาพดี ให้ผลผลิตนมสูง',
      'shareTags': ['แพะ', 'แพะนม', 'ปศุสัตว์'],
    },
  ];
  
  // Add to Firestore
  int count = 0;
  for (final listing in sampleListings) {
    await firestore.collection('market_listings').add(listing);
    count++;
    print('✅ เพิ่มข้อมูล $count/${sampleListings.length}');
  }
  
  print('');
  print('🎉 เสร็จสิ้น! เพิ่มข้อมูล $count รายการแล้ว');
  print('');
  print('📊 ตรวจสอบได้ที่:');
  print('   Firebase Console > Firestore > market_listings');
  print('');
  print('🌐 Refresh หน้าเว็บเพื่อดูข้อมูล');
}
