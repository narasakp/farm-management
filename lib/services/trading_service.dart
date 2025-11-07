import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trading.dart';

/// Service สำหรับจัดการข้อมูลตลาดซื้อขาย - เชื่อมต่อ Firestore
class TradingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection names
  static const String _marketListingsCollection = 'market_listings';
  static const String _marketBookingsCollection = 'market_bookings';
  static const String _transactionsCollection = 'trading_transactions';
  static const String _marketsCollection = 'markets';
  
  /// ดึงรายการประกาศขายทั้งหมด (Real-time)
  Stream<List<MarketListing>> getMarketListingsStream() {
    return _firestore
        .collection(_marketListingsCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('listedDate', descending: true) // ✅ Enabled - Index ready!
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketListing.fromFirestore(doc))
            .toList());
  }
  
  /// ดึงรายการประกาศขายทั้งหมด (จาก Firestore)
  Future<List<MarketListing>> getMarketListings() async {
    try {
      final snapshot = await _firestore
          .collection(_marketListingsCollection)
          .orderBy('listedDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => MarketListing.fromFirestore(doc))
          .where((listing) => listing.status != 'withdrawn') // Filter out deleted listings
          .toList();
    } catch (e) {
      print('❌ Error getting market listings: $e');
      return [];
    }
  }
  
  /// ดึงรายการประกาศของฉัน
  Future<List<MarketListing>> getMyListings(String farmId) async {
    try {
      final snapshot = await _firestore
          .collection(_marketListingsCollection)
          .where('farmId', isEqualTo: farmId)
          // ⚠️ Removed orderBy to avoid composite index requirement
          // Sort manually in memory instead
          .get();
      
      final listings = snapshot.docs
          .map((doc) => MarketListing.fromFirestore(doc))
          .where((listing) => listing.status != 'withdrawn') // Filter out deleted listings
          .toList();
      
      // Sort in memory by listedDate descending
      listings.sort((a, b) => b.listedDate.compareTo(a.listedDate));
      
      print('✅ Filtered ${listings.length} active my listings (excluded withdrawn)');
      return listings;
    } catch (e) {
      print('❌ Error getting my listings: $e');
      return [];
    }
  }
  
  /// สร้างประกาศขายใหม่
  Future<String> createListing(MarketListing listing) async {
    try {
      final docRef = await _firestore
          .collection(_marketListingsCollection)
          .add(listing.toFirestore());
      
      print('✅ Created listing: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating listing: $e');
      throw Exception('ไม่สามารถสร้างประกาศขายได้: $e');
    }
  }
  
  /// อัปเดตประกาศขาย
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_marketListingsCollection)
          .doc(id)
          .update(data);
      
      print('✅ Updated listing: $id');
    } catch (e) {
      print('❌ Error updating listing: $e');
      throw Exception('ไม่สามารถอัปเดตประกาศขายได้: $e');
    }
  }
  
  /// ลบประกาศขาย (soft delete - เปลี่ยน status)
  Future<void> deleteListing(String id) async {
    try {
      await _firestore
          .collection(_marketListingsCollection)
          .doc(id)
          .update({
        'status': 'withdrawn',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Deleted listing: $id');
    } catch (e) {
      print('❌ Error deleting listing: $e');
      throw Exception('ไม่สามารถลบประกาศขายได้: $e');
    }
  }
  
  /// เพิ่มจำนวนการดู
  Future<void> incrementViewCount(String listingId) async {
    try {
      await _firestore
          .collection(_marketListingsCollection)
          .doc(listingId)
          .update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Error incrementing view count: $e');
    }
  }
  
  /// ดึงรายการตลาดที่เปิดให้จองคิว
  Future<List<Map<String, dynamic>>> getAvailableMarkets() async {
    try {
      final snapshot = await _firestore
          .collection(_marketsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error getting markets: $e');
      return [];
    }
  }
  
  /// จองคิวตลาด
  Future<String> bookMarketQueue(MarketBooking booking) async {
    try {
      final docRef = await _firestore
          .collection(_marketBookingsCollection)
          .add(booking.toFirestore());
      
      print('✅ Created market booking: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating market booking: $e');
      throw Exception('ไม่สามารถจองคิวได้: $e');
    }
  }
  
  /// ดึงรายการจองคิวของฉัน
  Future<List<MarketBooking>> getMyBookings(String farmId) async {
    try {
      final snapshot = await _firestore
          .collection(_marketBookingsCollection)
          .where('farmId', isEqualTo: farmId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .orderBy('bookingDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => MarketBooking.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting bookings: $e');
      return [];
    }
  }
  
  /// บันทึกธุรกรรมซื้อขาย
  Future<String> recordTransaction(Map<String, dynamic> transaction) async {
    try {
      final docRef = await _firestore
          .collection(_transactionsCollection)
          .add({
        ...transaction,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Recorded transaction: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error recording transaction: $e');
      throw Exception('ไม่สามารถบันทึกธุรกรรมได้: $e');
    }
  }
  
  /// ค้นหาประกาศ
  Future<List<MarketListing>> searchListings(String query) async {
    try {
      // Note: Firestore ไม่รองรับ full-text search โดยตรง
      // ต้องใช้ Algolia หรือ Elasticsearch สำหรับ production
      // ตอนนี้ใช้การค้นหาแบบง่าย
      final snapshot = await _firestore
          .collection(_marketListingsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('listedDate', descending: true)
          .limit(50)
          .get();
      
      final allListings = snapshot.docs
          .map((doc) => MarketListing.fromFirestore(doc))
          .toList();
      
      // Filter in memory
      final searchLower = query.toLowerCase();
      return allListings.where((listing) {
        return listing.livestockId.toLowerCase().contains(searchLower) ||
               (listing.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    } catch (e) {
      print('❌ Error searching listings: $e');
      return [];
    }
  }
  
  /// กรองรายการตามหมวดหมู่
  Future<List<MarketListing>> filterListings({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? location,
  }) async {
    try {
      Query query = _firestore
          .collection(_marketListingsCollection)
          .where('status', isEqualTo: 'active');
      
      // Note: Firestore มีข้อจำกัดในการใช้ where หลายตัว
      // อาจต้อง filter บางส่วนใน memory
      
      final snapshot = await query
          .orderBy('listedDate', descending: true)
          .limit(100)
          .get();
      
      var listings = snapshot.docs
          .map((doc) => MarketListing.fromFirestore(doc))
          .toList();
      
      // Filter in memory
      if (minPrice != null) {
        listings = listings.where((l) => l.askingPrice >= minPrice).toList();
      }
      if (maxPrice != null) {
        listings = listings.where((l) => l.askingPrice <= maxPrice).toList();
      }
      
      return listings;
    } catch (e) {
      print('❌ Error filtering listings: $e');
      return [];
    }
  }
  
  /// ดึงสถิติตลาด
  Future<Map<String, dynamic>> getMarketStats() async {
    try {
      final listingsSnapshot = await _firestore
          .collection(_marketListingsCollection)
          .where('status', isEqualTo: 'active')
          .get();
      
      final soldSnapshot = await _firestore
          .collection(_marketListingsCollection)
          .where('status', isEqualTo: 'sold')
          .get();
      
      int totalViews = 0;
      double totalValue = 0;
      
      for (var doc in listingsSnapshot.docs) {
        final data = doc.data();
        totalViews += (data['viewCount'] as int? ?? 0);
        totalValue += (data['askingPrice'] as num? ?? 0).toDouble();
      }
      
      return {
        'activeListings': listingsSnapshot.docs.length,
        'soldListings': soldSnapshot.docs.length,
        'totalViews': totalViews,
        'totalValue': totalValue,
        'averagePrice': listingsSnapshot.docs.isEmpty 
            ? 0 
            : totalValue / listingsSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error getting market stats: $e');
      return {};
    }
  }
  
  /// Seed sample data for testing (ข้อมูลตัวอย่างสำหรับทดสอบ)
  Future<void> seedSampleListings() async {
    try {
      print('🌱 Seeding sample market listings...');
      
      final sampleListings = [
        MarketListing(
          id: '',
          farmId: 'farm001',
          livestockId: 'cow001',
          askingPrice: 25000,
          isNegotiable: true,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          description: 'โคเนื้อพันธุ์ดี น้ำหนัก 350 กก. สุขภาพแข็งแรง',
          shareTitle: 'โคเนื้อพันธุ์ดี - ขาย 25,000 บาท',
          shareTags: ['โค', 'โคเนื้อ', 'cow', 'cattle', 'beef'],
          images: [
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
          ],
          viewCount: 15,
        ),
        MarketListing(
          id: '',
          farmId: 'farm002',
          livestockId: 'buffalo001',
          askingPrice: 30000,
          isNegotiable: true,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          description: 'กระบือพันธุ์แท้ อายุ 3 ปี',
          shareTitle: 'กระบือพันธุ์แท้ - ขาย 30,000 บาท',
          shareTags: ['กระบือ', 'buffalo'],
          images: [
            'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
          ],
          viewCount: 8,
        ),
        MarketListing(
          id: '',
          farmId: 'farm003',
          livestockId: 'pig001',
          askingPrice: 5000,
          isNegotiable: true,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(days: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          description: 'สุกรพันธุ์ดี น้ำหนัก 100 กก.',
          shareTitle: 'สุกรพันธุ์ดี - ขาย 5,000 บาท',
          shareTags: ['สุกร', 'pig', 'pork'],
          images: [
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
          ],
          viewCount: 12,
        ),
        MarketListing(
          id: '',
          farmId: 'farm004',
          livestockId: 'chicken001',
          askingPrice: 150,
          isNegotiable: false,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(hours: 5)),
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          description: 'ไก่เนื้อพันธุ์ดี อายุ 45 วัน',
          shareTitle: 'ไก่เนื้อพันธุ์ดี - ขาย 150 บาท',
          shareTags: ['ไก่', 'chicken', 'ไก่เนื้อ'],
          images: [
            'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400',
          ],
          viewCount: 20,
        ),
        MarketListing(
          id: '',
          farmId: 'farm005',
          livestockId: 'duck001',
          askingPrice: 180,
          isNegotiable: false,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(hours: 10)),
          createdAt: DateTime.now().subtract(const Duration(hours: 10)),
          description: 'เป็ดเทศพันธุ์ดี อายุ 60 วัน',
          shareTitle: 'เป็ดเทศพันธุ์ดี - ขาย 180 บาท',
          shareTags: ['เป็ด', 'duck', 'เป็ดเทศ'],
          images: [
            'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
          ],
          viewCount: 5,
        ),
        MarketListing(
          id: '',
          farmId: 'farm006',
          livestockId: 'goat001',
          askingPrice: 8000,
          isNegotiable: true,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(hours: 15)),
          createdAt: DateTime.now().subtract(const Duration(hours: 15)),
          description: 'แพะพันธุ์ดี อายุ 1 ปี',
          shareTitle: 'แพะพันธุ์ดี - ขาย 8,000 บาท',
          shareTags: ['แพะ', 'goat'],
          images: [
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
          ],
          viewCount: 7,
        ),
        MarketListing(
          id: '',
          farmId: 'farm007',
          livestockId: 'sheep001',
          askingPrice: 12000,
          isNegotiable: true,
          status: 'active',
          listedDate: DateTime.now().subtract(const Duration(hours: 20)),
          createdAt: DateTime.now().subtract(const Duration(hours: 20)),
          description: 'แกะพันธุ์ดี อายุ 2 ปี',
          shareTitle: 'แกะพันธุ์ดี - ขาย 12,000 บาท',
          shareTags: ['แกะ', 'sheep'],
          images: [
            'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400',
          ],
          viewCount: 10,
        ),
        MarketListing(
          id: '',
          farmId: 'farm008',
          livestockId: 'cow002',
          askingPrice: 28000,
          isNegotiable: true,
          status: 'active',
          listedDate: DateTime.now(),
          createdAt: DateTime.now(),
          description: 'โคนมพันธุ์ดี ให้นม 15 ลิตร/วัน',
          shareTitle: 'โคนมพันธุ์ดี - ขาย 28,000 บาท',
          shareTags: ['โค', 'โคนม', 'cow', 'dairy'],
          images: [
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400',
          ],
          viewCount: 25,
        ),
      ];
      
      for (final listing in sampleListings) {
        await createListing(listing);
      }
      
      print('✅ Seeded ${sampleListings.length} sample listings');
    } catch (e) {
      print('❌ Error seeding sample listings: $e');
      rethrow;
    }
  }
}
