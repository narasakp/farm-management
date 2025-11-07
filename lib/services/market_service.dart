import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market.dart';
import '../data/mock_markets.dart';

/// Service สำหรับจัดการตลาดนัด
class MarketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'markets';

  /// ดึงรายการตลาดทั้งหมดที่เปิดใช้งาน
  Future<List<Market>> getMarkets({bool activeOnly = true}) async {
    try {
      // TODO: Implement Firestore query
      // Query query = _firestore.collection(_collection);
      // if (activeOnly) {
      //   query = query.where('isActive', isEqualTo: true);
      // }
      // final snapshot = await query.get();
      // return snapshot.docs.map((doc) => Market.fromJson(doc.data())).toList();

      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
      return MockMarkets.markets.where((m) => !activeOnly || m.isActive).toList();
    } catch (e) {
      print('❌ Error loading markets: $e');
      rethrow;
    }
  }

  /// ดึงตลาดเฉพาะ ID
  Future<Market?> getMarketById(String marketId) async {
    try {
      // TODO: Implement Firestore query
      // final doc = await _firestore.collection(_collection).doc(marketId).get();
      // if (doc.exists) {
      //   return Market.fromJson(doc.data()!);
      // }
      // return null;

      // Mock data
      await Future.delayed(const Duration(milliseconds: 300));
      return MockMarkets.markets.firstWhere(
        (m) => m.id == marketId,
        orElse: () => throw Exception('Market not found'),
      );
    } catch (e) {
      print('❌ Error loading market $marketId: $e');
      return null;
    }
  }

  /// สร้างตลาดใหม่ (Admin only)
  Future<String> createMarket(Market market) async {
    try {
      // TODO: Implement Firestore create
      // final docRef = await _firestore.collection(_collection).add(market.toJson());
      // return docRef.id;

      print('✅ Created market: ${market.name}');
      return market.id;
    } catch (e) {
      print('❌ Error creating market: $e');
      rethrow;
    }
  }

  /// อัปเดตตลาด (Admin only)
  Future<void> updateMarket(Market market) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(market.id).update(market.toJson());

      print('✅ Updated market: ${market.name}');
    } catch (e) {
      print('❌ Error updating market: $e');
      rethrow;
    }
  }

  /// ลบตลาด (Admin only) - Soft delete
  Future<void> deleteMarket(String marketId) async {
    try {
      // TODO: Implement Firestore soft delete
      // await _firestore.collection(_collection).doc(marketId).update({
      //   'isActive': false,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });

      print('✅ Deleted market: $marketId');
    } catch (e) {
      print('❌ Error deleting market: $e');
      rethrow;
    }
  }

  /// ค้นหาตลาดตามประเภทสัตว์
  Future<List<Market>> searchByLivestockType(String livestockType) async {
    try {
      final markets = await getMarkets();
      return markets.where((market) {
        return market.zones.any((zone) => 
          zone.livestockType.toLowerCase() == livestockType.toLowerCase() && 
          zone.isActive
        );
      }).toList();
    } catch (e) {
      print('❌ Error searching markets: $e');
      return [];
    }
  }

  /// ตรวจสอบคิวว่างในโซน
  Future<int> getAvailableSlots(
    String marketId,
    String zoneId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      // TODO: Query bookings และคำนวณคิวว่าง
      // final bookings = await _firestore
      //   .collection('bookings')
      //   .where('marketId', isEqualTo: marketId)
      //   .where('zoneId', isEqualTo: zoneId)
      //   .where('bookingDate', isEqualTo: Timestamp.fromDate(date))
      //   .where('timeSlot', isEqualTo: timeSlot)
      //   .where('status', whereIn: ['confirmed', 'checked_in'])
      //   .get();
      
      // final market = await getMarketById(marketId);
      // final zone = market?.zones.firstWhere((z) => z.id == zoneId);
      // return (zone?.totalSlots ?? 0) - bookings.docs.length;

      // Mock: Random available slots
      await Future.delayed(const Duration(milliseconds: 200));
      final market = await getMarketById(marketId);
      final zone = market?.zones.firstWhere((z) => z.id == zoneId);
      final totalSlots = zone?.totalSlots ?? 0;
      // Simulate 50-80% available
      return (totalSlots * 0.7).round();
    } catch (e) {
      print('❌ Error checking slots: $e');
      return 0;
    }
  }

  /// สร้างเลขคิว
  Future<String> generateQueueNumber(
    String marketId,
    String zoneId,
    DateTime date,
  ) async {
    try {
      // TODO: Query จำนวนการจองในวันนั้นและสร้างเลขคิว
      // final bookings = await _firestore
      //   .collection('bookings')
      //   .where('marketId', isEqualTo: marketId)
      //   .where('zoneId', isEqualTo: zoneId)
      //   .where('bookingDate', isEqualTo: Timestamp.fromDate(date))
      //   .orderBy('queueNumber', descending: true)
      //   .limit(1)
      //   .get();
      
      // String lastQueue = bookings.docs.isEmpty ? '' : bookings.docs.first.data()['queueNumber'];
      // int nextNumber = _parseQueueNumber(lastQueue) + 1;

      // Mock: Random queue number
      await Future.delayed(const Duration(milliseconds: 100));
      final market = await getMarketById(marketId);
      final zone = market?.zones.firstWhere((z) => z.id == zoneId);
      final code = zone?.code ?? 'A';
      final number = DateTime.now().millisecondsSinceEpoch % 100;
      return '$code-${number.toString().padLeft(3, '0')}';
    } catch (e) {
      print('❌ Error generating queue number: $e');
      return 'A-000';
    }
  }

  /// Parse queue number to get sequential number
  int _parseQueueNumber(String queueNumber) {
    if (queueNumber.isEmpty) return 0;
    final parts = queueNumber.split('-');
    if (parts.length != 2) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  /// ดึงสถิติตลาด (สำหรับ Analytics)
  Future<Map<String, dynamic>> getMarketStats(String marketId) async {
    try {
      // TODO: Implement real stats
      return {
        'totalBookings': 0,
        'totalRevenue': 0.0,
        'avgRating': 0.0,
        'reviewCount': 0,
      };
    } catch (e) {
      print('❌ Error loading market stats: $e');
      return {};
    }
  }
}
