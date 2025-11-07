import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trading.dart';
import '../models/social_share.dart';

/// 🌱 Seed Data Utility
/// ใช้สำหรับเพิ่มข้อมูลทดสอบใน Firestore

class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// เพิ่มข้อมูล Sample Market Listings
  static Future<void> seedMarketListings() async {
    print('🌱 เริ่มเพิ่มข้อมูล Sample Market Listings...');
    
    final sampleListings = [
      MarketListing(
        id: '', // Firestore จะสร้าง ID ให้อัตโนมัติ
        farmId: 'farm001',
        livestockId: 'cattle001',
        askingPrice: 45000,
        minPrice: 42000,
        description: 'โคเนื้อบราหมันคุณภาพดี อายุ 2 ปี น้ำหนัก 450 กก.',
        images: [
          'assets/images/livestock/cattle.svg',
        ],
        isNegotiable: true,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 15,
        createdAt: DateTime.now(),
        shareTitle: '🐂 โคเนื้อบราหมันคุณภาพ A+',
        shareDescription: 'โคเนื้อพันธุ์ดี สุขภาพแข็งแรง พร้อมส่งมอบ',
        shareTags: ['โคเนื้อ', 'บราหมัน', 'ปศุสัตว์'],
      ),
      MarketListing(
        id: '',
        farmId: 'farm002',
        livestockId: 'pig001',
        askingPrice: 8500,
        minPrice: 8000,
        description: 'สุกรพันธุ์แลนด์เรซ น้ำหนัก 95 กก. พร้อมขาย',
        images: ['assets/images/livestock/pig.svg'],
        isNegotiable: true,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 8,
        createdAt: DateTime.now(),
        shareTitle: '🐷 สุกรพันธุ์ดีพร้อมขาย',
        shareDescription: 'สุกรแลนด์เรซ น้ำหนักดี สุขภาพดี',
        shareTags: ['สุกร', 'แลนด์เรซ', 'ปศุสัตว์'],
      ),
      MarketListing(
        id: '',
        farmId: 'farm001',
        livestockId: 'chicken001',
        askingPrice: 150,
        minPrice: 140,
        description: 'ไก่ไข่สายพันธุ์ดี ให้ไข่ดี อายุ 6 เดือน',
        images: ['assets/images/livestock/chicken.svg'],
        isNegotiable: true,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 23,
        createdAt: DateTime.now(),
        shareTitle: '🐔 ไก่ไข่พันธุ์ดี ให้ผลผลิตสูง',
        shareDescription: 'ไก่ไข่สายพันธุ์ดี เริ่มให้ไข่แล้ว',
        shareTags: ['ไก่ไข่', 'ไก่', 'ปศุสัตว์'],
      ),
      MarketListing(
        id: '',
        farmId: 'farm003',
        livestockId: 'duck001',
        askingPrice: 180,
        description: 'เป็ดไข่เทศ อายุ 7 เดือน ให้ไข่ดีมาก',
        images: ['assets/images/livestock/duck.svg'],
        isNegotiable: false,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 12,
        createdAt: DateTime.now(),
        shareTitle: '🦆 เป็ดไข่เทศคุณภาพ',
        shareDescription: 'เป็ดไข่ให้ผลผลิตดี ขายคู่ได้',
        shareTags: ['เป็ด', 'เป็ดไข่', 'ปศุสัตว์'],
      ),
      MarketListing(
        id: '',
        farmId: 'farm002',
        livestockId: 'goat001',
        askingPrice: 6500,
        minPrice: 6000,
        description: 'แพะนมพันธุ์ดี ให้นมดี อายุ 1.5 ปี',
        images: ['assets/images/livestock/goat.svg'],
        isNegotiable: true,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 19,
        createdAt: DateTime.now(),
        shareTitle: '🐐 แพะนมพันธุ์ดี ให้นมดี',
        shareDescription: 'แพะนมสุขภาพดี ให้ผลผลิตนมสูง',
        shareTags: ['แพะ', 'แพะนม', 'ปศุสัตว์'],
      ),
      MarketListing(
        id: '',
        farmId: 'farm001',
        livestockId: 'cattle002',
        askingPrice: 38000,
        minPrice: 35000,
        description: 'โคนมโฮลสไตน์ ให้นม 25 ลิตร/วัน',
        images: ['assets/images/livestock/cattle.svg'],
        isNegotiable: true,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 31,
        createdAt: DateTime.now(),
        shareTitle: '🐄 โคนมโฮลสไตน์ให้นมสูง',
        shareDescription: 'โคนมคุณภาพ ให้ผลผลิตนมดีเยี่ยม',
        shareTags: ['โคนม', 'โฮลสไตน์', 'ปศุสัตว์'],
      ),
      MarketListing(
        id: '',
        farmId: 'farm004',
        livestockId: 'pig002',
        askingPrice: 9000,
        minPrice: 8500,
        description: 'สุกรดูรอค น้ำหนัก 88 กก.',
        images: [
          'assets/images/livestock/pig.svg',
        ],
        isNegotiable: true,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 5,
        createdAt: DateTime.now(),
      ),
      MarketListing(
        id: '',
        farmId: 'farm003',
        livestockId: 'chicken002',
        askingPrice: 120,
        description: 'ไก่เนื้อพร้อมขาย น้ำหนัก 2.5 กก./ตัว',
        images: [
          'assets/images/livestock/chicken.svg',
        ],
        isNegotiable: false,
        listedDate: DateTime.now(),
        status: 'active',
        viewCount: 17,
        createdAt: DateTime.now(),
      ),
    ];
    
    // ใช้ batch write เพื่อความเร็ว
    final batch = _firestore.batch();
    final collectionRef = _firestore.collection('market_listings');
    
    for (final listing in sampleListings) {
      final docRef = collectionRef.doc();
      batch.set(docRef, listing.toFirestore());
    }
    
    await batch.commit();
    
    print('✅ เพิ่มข้อมูล ${sampleListings.length} รายการสำเร็จ!');
  }
  
  /// ลบข้อมูลทั้งหมด (ระวัง! ใช้เฉพาะ Development)
  static Future<void> clearMarketListings() async {
    print('🗑️ กำลังลบข้อมูล Market Listings...');
    
    final snapshot = await _firestore.collection('market_listings').get();
    final batch = _firestore.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    print('✅ ลบข้อมูล ${snapshot.docs.length} รายการแล้ว');
  }
  
  /// Reset ข้อมูล (ลบแล้วเพิ่มใหม่)
  static Future<void> resetMarketListings() async {
    await clearMarketListings();
    await seedMarketListings();
    print('🔄 Reset ข้อมูลเรียบร้อย! จำนวน 8 รายการ');
  }
  
  /// ลบข้อมูลซ้ำ (เก็บไว้แค่ 8 รายการแรก)
  static Future<void> removeDuplicates() async {
    print('🔍 กำลังตรวจสอบข้อมูลซ้ำ...');
    
    final snapshot = await _firestore.collection('market_listings').get();
    final total = snapshot.docs.length;
    
    print('📊 พบข้อมูลทั้งหมด: $total รายการ');
    
    if (total <= 8) {
      print('✅ ข้อมูลปกติ (${total} รายการ)');
      return;
    }
    
    // ลบข้อมูลส่วนเกิน (เก็บไว้แค่ 8 รายการแรก)
    final toDelete = snapshot.docs.skip(8).toList();
    final batch = _firestore.batch();
    
    for (final doc in toDelete) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    print('🗑️ ลบข้อมูลซ้ำ ${toDelete.length} รายการ');
    print('✅ เหลือข้อมูล 8 รายการ');
  }
  
  // ========== SOCIAL COMMERCE DATA ==========
  
  /// เพิ่มข้อมูล Social Shares
  static Future<void> seedSocialShares() async {
    print('📱 เริ่มเพิ่มข้อมูล Social Shares...');
    
    final baseDate = DateTime.now();
    final sampleShares = [
      // Facebook Shares
      SocialShare(
        id: '',
        listingId: 'cattle001',
        userId: 'user001',
        platform: 'facebook',
        contentType: 'image',
        templateId: 'card',
        shareUrl: 'https://farm.app/buy/cattle001?source=fb',
        shareContent: '🐂 โคเนื้อบราห์มันคุณภาพ A+ ราคาพิเศษ!',
        createdAt: baseDate.subtract(const Duration(days: 7)),
        viewCount: 1250,
        clickCount: 125,
        conversionCount: 8,
      ),
      SocialShare(
        id: '',
        listingId: 'pig001',
        userId: 'user002',
        platform: 'facebook',
        contentType: 'image',
        templateId: 'price',
        shareUrl: 'https://farm.app/buy/pig001?source=fb',
        shareContent: '🐷 สุกรพันธุ์ดีพร้อมขาย โปรโมชันพิเศษ!',
        createdAt: baseDate.subtract(const Duration(days: 6)),
        viewCount: 890,
        clickCount: 89,
        conversionCount: 5,
      ),
      
      // TikTok Shares
      SocialShare(
        id: '',
        listingId: 'chicken001',
        userId: 'user001',
        platform: 'tiktok',
        contentType: 'video',
        templateId: 'video',
        shareUrl: 'https://farm.app/buy/chicken001?source=tt',
        shareContent: '🐔 ไก่ไข่พันธุ์ดี ให้ผลผลิตสูง! #ไก่ไข่ #ฟาร์มไก่',
        createdAt: baseDate.subtract(const Duration(days: 5)),
        viewCount: 3450,
        clickCount: 345,
        conversionCount: 18,
      ),
      SocialShare(
        id: '',
        listingId: 'cattle002',
        userId: 'user003',
        platform: 'tiktok',
        contentType: 'video',
        templateId: 'video',
        shareUrl: 'https://farm.app/buy/cattle002?source=tt',
        shareContent: '🐄 โคนมโฮลสไตน์ให้นมสูง 25 ลิตร/วัน! #โคนม',
        createdAt: baseDate.subtract(const Duration(days: 4)),
        viewCount: 2890,
        clickCount: 289,
        conversionCount: 12,
      ),
      
      // X (Twitter) Shares
      SocialShare(
        id: '',
        listingId: 'goat001',
        userId: 'user002',
        platform: 'x',
        contentType: 'image',
        templateId: 'card',
        shareUrl: 'https://farm.app/buy/goat001?source=x',
        shareContent: '🐐 แพะนมพันธุ์ดี ให้นมดี อายุ 1.5 ปี',
        createdAt: baseDate.subtract(const Duration(days: 3)),
        viewCount: 567,
        clickCount: 56,
        conversionCount: 3,
      ),
      
      // LINE Shares
      SocialShare(
        id: '',
        listingId: 'duck001',
        userId: 'user001',
        platform: 'line',
        contentType: 'image',
        templateId: 'gallery',
        shareUrl: 'https://farm.app/buy/duck001?source=line',
        shareContent: '🦆 เป็ดไข่เทศคุณภาพ ขายคู่ได้',
        createdAt: baseDate.subtract(const Duration(days: 2)),
        viewCount: 445,
        clickCount: 44,
        conversionCount: 4,
      ),
      SocialShare(
        id: '',
        listingId: 'pig002',
        userId: 'user003',
        platform: 'line',
        contentType: 'image',
        templateId: 'price',
        shareUrl: 'https://farm.app/buy/pig002?source=line',
        shareContent: '🐷 สุกรดูรอค น้ำหนัก 88 กก.',
        createdAt: baseDate.subtract(const Duration(days: 1)),
        viewCount: 334,
        clickCount: 33,
        conversionCount: 2,
      ),
    ];
    
    final batch = _firestore.batch();
    final collectionRef = _firestore.collection('social_shares');
    
    for (final share in sampleShares) {
      final docRef = collectionRef.doc();
      batch.set(docRef, share.toFirestore());
    }
    
    await batch.commit();
    
    print('✅ เพิ่มข้อมูล ${sampleShares.length} Social Shares สำเร็จ!');
  }
  
  /// เพิ่มข้อมูล Orders
  static Future<void> seedOrders() async {
    print('🛒 เริ่มเพิ่มข้อมูล Orders...');
    
    final baseDate = DateTime.now();
    final sampleOrders = [
      {
        'orderId': 'ORD${baseDate.millisecondsSinceEpoch - 700000}',
        'listingId': 'cattle001',
        'buyerName': 'นายสมชาย ใจดี',
        'buyerPhone': '089-123-4567',
        'buyerAddress': 'บ้านเลขที่ 123 ต.นาดี อ.เมือง จ.ขอนแก่น',
        'paymentMethod': 'bank_transfer',
        'totalAmount': 45000,
        'status': 'completed',
        'source': 'facebook',
        'userId': 'buyer001',
        'createdAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 7))),
        'updatedAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 5))),
      },
      {
        'orderId': 'ORD${baseDate.millisecondsSinceEpoch - 600000}',
        'listingId': 'chicken001',
        'buyerName': 'นางสาวสมหญิง รักสุข',
        'buyerPhone': '081-234-5678',
        'buyerAddress': 'บ้านเลขที่ 456 ต.สุขสันต์ อ.เมือง จ.อุดรธานี',
        'paymentMethod': 'cash_on_delivery',
        'totalAmount': 1500,
        'status': 'confirmed',
        'source': 'tiktok',
        'userId': 'buyer002',
        'createdAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 5))),
        'updatedAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 4))),
      },
      {
        'orderId': 'ORD${baseDate.millisecondsSinceEpoch - 500000}',
        'listingId': 'cattle002',
        'buyerName': 'นายอำนวย มั่งมี',
        'buyerPhone': '092-345-6789',
        'paymentMethod': 'bank_transfer',
        'totalAmount': 38000,
        'status': 'completed',
        'source': 'tiktok',
        'userId': 'buyer003',
        'createdAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 4))),
        'updatedAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 2))),
      },
      {
        'orderId': 'ORD${baseDate.millisecondsSinceEpoch - 400000}',
        'listingId': 'goat001',
        'buyerName': 'นายประสิทธิ์ ชัยชนะ',
        'buyerPhone': '087-456-7890',
        'paymentMethod': 'promptpay',
        'totalAmount': 6500,
        'status': 'shipped',
        'source': 'line',
        'userId': 'buyer004',
        'createdAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 2))),
        'updatedAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 1))),
      },
      {
        'orderId': 'ORD${baseDate.millisecondsSinceEpoch - 300000}',
        'listingId': 'pig001',
        'buyerName': 'นายวิชัย เจริญรุ่ง',
        'buyerPhone': '095-567-8901',
        'paymentMethod': 'bank_transfer',
        'totalAmount': 8500,
        'status': 'pending',
        'source': 'facebook',
        'userId': 'buyer005',
        'createdAt': Timestamp.fromDate(baseDate.subtract(const Duration(days: 1))),
        'updatedAt': Timestamp.fromDate(baseDate),
      },
    ];
    
    final batch = _firestore.batch();
    final collectionRef = _firestore.collection('orders');
    
    for (final order in sampleOrders) {
      final docRef = collectionRef.doc(order['orderId'] as String);
      batch.set(docRef, order);
    }
    
    await batch.commit();
    
    print('✅ เพิ่มข้อมูล ${sampleOrders.length} Orders สำเร็จ!');
  }
  
  /// ลบข้อมูล Social Shares
  static Future<void> clearSocialShares() async {
    print('🗑️ กำลังลบข้อมูล Social Shares...');
    
    final snapshot = await _firestore.collection('social_shares').get();
    final batch = _firestore.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    print('✅ ลบข้อมูล ${snapshot.docs.length} รายการแล้ว');
  }
  
  /// ลบข้อมูล Orders
  static Future<void> clearOrders() async {
    print('🗑️ กำลังลบข้อมูล Orders...');
    
    final snapshot = await _firestore.collection('orders').get();
    final batch = _firestore.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    
    print('✅ ลบข้อมูล ${snapshot.docs.length} รายการแล้ว');
  }
  
  /// Seed ข้อมูลทั้งหมด (All in one)
  static Future<void> seedAll() async {
    print('🌱🌱🌱 เริ่ม Seed ข้อมูลทั้งหมด...');
    
    await seedMarketListings();
    await seedSocialShares();
    await seedOrders();
    
    print('🎉 Seed ข้อมูลทั้งหมดเรียบร้อย!');
  }
  
  /// ลบข้อมูลทั้งหมด
  static Future<void> clearAll() async {
    print('🗑️🗑️🗑️ กำลังลบข้อมูลทั้งหมด...');
    
    await clearMarketListings();
    await clearSocialShares();
    await clearOrders();
    
    print('✅ ลบข้อมูลทั้งหมดเรียบร้อย!');
  }
  
  /// 🔧 แก้ไข Image Paths (ลบ "assets/" ออก)
  static Future<void> fixImagePaths() async {
    print('🔧 เริ่มแก้ไข Image Paths...');
    
    final snapshot = await _firestore.collection('market_listings').get();
    
    print('✅ พบ ${snapshot.docs.length} รายการ');
    
    int updatedCount = 0;
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final images = data['images'] as List<dynamic>?;
      
      if (images != null && images.isNotEmpty) {
        final originalImages = List<String>.from(images);
        
        // แก้ไข path: ลบ "assets/" ออกจากหน้า path
        final fixedImages = originalImages.map((path) {
          if (path.startsWith('assets/')) {
            return path.replaceFirst('assets/', '');
          }
          return path;
        }).toList();
        
        // ตรวจสอบว่ามีการเปลี่ยนแปลงหรือไม่
        final hasChanges = originalImages.toString() != fixedImages.toString();
        
        if (hasChanges) {
          print('📝 แก้ไข ${doc.id}:');
          print('   Before: $originalImages');
          print('   After:  $fixedImages');
          
          await doc.reference.update({'images': fixedImages});
          updatedCount++;
        } else {
          print('✅ ${doc.id} - ถูกต้องแล้ว');
        }
      } else {
        print('⚠️  ${doc.id} - ไม่มีรูป');
      }
    }
    
    print('✅ แก้ไขเสร็จแล้ว $updatedCount รายการ');
  }
  
  /// Reset ข้อมูลทั้งหมด
  static Future<void> resetAll() async {
    await clearAll();
    await seedAll();
    print('🔄 Reset ข้อมูลทั้งหมดเรียบร้อย!');
  }
}
