import 'package:flutter/material.dart';
import '../models/feed_management.dart';

class FeedProvider with ChangeNotifier {
  List<FeedItem> _feedItems = [];
  List<FeedingRecord> _feedingRecords = [];
  List<FeedSchedule> _feedSchedules = [];
  List<FeedInventoryTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<FeedItem> get feedItems => _feedItems;
  List<FeedingRecord> get feedingRecords => _feedingRecords;
  List<FeedSchedule> get feedSchedules => _feedSchedules;
  List<FeedInventoryTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FeedProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    
    _feedItems = [
      FeedItem(
        id: 'feed_001',
        name: 'อาหารโคนม 18% โปรตีน',
        type: FeedType.concentrate,
        brand: 'บีคอน',
        description: 'อาหารข้นสำหรับโคนมให้นม',
        unit: FeedUnit.kg,
        currentStock: 250.0,
        minimumStock: 100.0,
        maximumStock: 500.0,
        costPerUnit: 18.50,
        supplier: 'บริษัท อาหารสัตว์ ABC',
        supplierContact: '02-123-4567',
        expiryDate: now.add(const Duration(days: 90)),
        batchNumber: 'BT2024090401',
        storageLocation: 'โกดัง A ชั้น 1',
        nutritionalInfo: {
          'protein': 18.0,
          'fat': 4.5,
          'fiber': 8.0,
          'moisture': 12.0,
        },
        suitableFor: ['โค', 'กระบือ'],
        notes: 'เก็บในที่แห้ง อุณหภูมิไม่เกิน 30°C',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      FeedItem(
        id: 'feed_002',
        name: 'หญ้าแห้ง',
        type: FeedType.roughage,
        description: 'หญ้าแห้งคุณภาพดี',
        unit: FeedUnit.kg,
        currentStock: 80.0,
        minimumStock: 150.0,
        maximumStock: 1000.0,
        costPerUnit: 8.0,
        supplier: 'ฟาร์มหญ้าเขียว',
        supplierContact: '081-234-5678',
        storageLocation: 'โกดัง B',
        nutritionalInfo: {
          'protein': 8.5,
          'fiber': 32.0,
          'moisture': 15.0,
        },
        suitableFor: ['โค', 'กระบือ', 'แพะ', 'แกะ'],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      FeedItem(
        id: 'feed_003',
        name: 'อาหารไก่ไข่ เลเยอร์',
        type: FeedType.concentrate,
        brand: 'ซีพี',
        description: 'อาหารสำหรับไก่ไข่ระยะให้ไข่',
        unit: FeedUnit.kg,
        currentStock: 180.0,
        minimumStock: 50.0,
        maximumStock: 300.0,
        costPerUnit: 22.0,
        supplier: 'บริษัท เจริญโภคภัณฑ์',
        supplierContact: '02-987-6543',
        expiryDate: now.add(const Duration(days: 60)),
        batchNumber: 'CP2024090301',
        storageLocation: 'โกดัง C',
        nutritionalInfo: {
          'protein': 16.5,
          'fat': 3.5,
          'calcium': 3.8,
          'phosphorus': 0.65,
        },
        suitableFor: ['ไก่'],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      FeedItem(
        id: 'feed_004',
        name: 'เกลือแร่ผสม',
        type: FeedType.mineral,
        brand: 'มิเนอรัล พลัส',
        description: 'เกลือแร่ผสมวิตามินสำหรับสัตว์เคี้ยวเอื้อง',
        unit: FeedUnit.kg,
        currentStock: 25.0,
        minimumStock: 10.0,
        maximumStock: 50.0,
        costPerUnit: 45.0,
        supplier: 'บริษัท วิตามิน แอนด์ มิเนอรัล',
        supplierContact: '02-555-1234',
        expiryDate: now.add(const Duration(days: 180)),
        batchNumber: 'MIN2024090201',
        storageLocation: 'โกดัง A ชั้น 2',
        nutritionalInfo: {
          'calcium': 18.0,
          'phosphorus': 8.0,
          'sodium': 15.0,
          'magnesium': 2.5,
        },
        suitableFor: ['โค', 'กระบือ', 'แพะ', 'แกะ'],
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      FeedItem(
        id: 'feed_005',
        name: 'อาหารหมูเนื้อ',
        type: FeedType.concentrate,
        brand: 'บีคอน',
        description: 'อาหารสำหรับหมูเนื้อ ระยะขุน',
        unit: FeedUnit.kg,
        currentStock: 15.0,
        minimumStock: 50.0,
        maximumStock: 200.0,
        costPerUnit: 19.5,
        supplier: 'บริษัท อาหารสัตว์ ABC',
        supplierContact: '02-123-4567',
        expiryDate: now.add(const Duration(days: 45)),
        batchNumber: 'PIG2024090101',
        storageLocation: 'โกดัง D',
        nutritionalInfo: {
          'protein': 16.0,
          'fat': 4.0,
          'fiber': 6.0,
          'lysine': 0.95,
        },
        suitableFor: ['สุกร'],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
    ];

    _feedingRecords = [
      FeedingRecord(
        id: 'fr_001',
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        feedItemId: 'feed_001',
        feedItemName: 'อาหารโคนม 18% โปรตีน',
        quantity: 5.0,
        unit: FeedUnit.kg,
        feedingTime: DateTime(now.year, now.month, now.day, 6, 0),
        fedBy: 'นายสมชาย',
        notes: 'ให้อาหารเช้า',
        cost: 92.50,
        createdAt: DateTime(now.year, now.month, now.day, 6, 15),
      ),
      FeedingRecord(
        id: 'fr_002',
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        feedItemId: 'feed_002',
        feedItemName: 'หญ้าแห้ง',
        quantity: 8.0,
        unit: FeedUnit.kg,
        feedingTime: DateTime(now.year, now.month, now.day, 8, 0),
        fedBy: 'นายสมชาย',
        notes: 'หญ้าแห้งเสริม',
        cost: 64.0,
        createdAt: DateTime(now.year, now.month, now.day, 8, 15),
      ),
      FeedingRecord(
        id: 'fr_003',
        livestockId: 'chicken_001',
        livestockName: 'ไก่ไข่ฟาร์ม A',
        feedItemId: 'feed_003',
        feedItemName: 'อาหารไก่ไข่ เลเยอร์',
        quantity: 12.0,
        unit: FeedUnit.kg,
        feedingTime: DateTime(now.year, now.month, now.day, 7, 0),
        fedBy: 'นางสมหญิง',
        notes: 'อาหารเช้า ไก่ไข่',
        cost: 264.0,
        createdAt: DateTime(now.year, now.month, now.day, 7, 30),
      ),
    ];

    _feedSchedules = [
      FeedSchedule(
        id: 'fs_001',
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        feedItemId: 'feed_001',
        feedItemName: 'อาหารโคนม 18% โปรตีน',
        quantity: 5.0,
        unit: FeedUnit.kg,
        feedingTimes: [6, 18], // 6 AM and 6 PM
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
        startDate: DateTime(now.year, now.month, 1),
        isActive: true,
        notes: 'อาหารข้นเช้า-เย็น',
        createdAt: DateTime(now.year, now.month, 1),
        updatedAt: DateTime(now.year, now.month, 1),
      ),
      FeedSchedule(
        id: 'fs_002',
        livestockId: 'chicken_001',
        livestockName: 'ไก่ไข่ฟาร์ม A',
        feedItemId: 'feed_003',
        feedItemName: 'อาหารไก่ไข่ เลเยอร์',
        quantity: 12.0,
        unit: FeedUnit.kg,
        feedingTimes: [7, 15], // 7 AM and 3 PM
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
        startDate: DateTime(now.year, now.month, 1),
        isActive: true,
        notes: 'อาหารไก่ไข่ 2 มื้อ',
        createdAt: DateTime(now.year, now.month, 1),
        updatedAt: DateTime(now.year, now.month, 1),
      ),
    ];

    _transactions = [
      FeedInventoryTransaction(
        id: 'ft_001',
        feedItemId: 'feed_001',
        feedItemName: 'อาหารโคนม 18% โปรตีน',
        type: 'in',
        quantity: 300.0,
        unit: FeedUnit.kg,
        costPerUnit: 18.50,
        totalCost: 5550.0,
        reason: 'รับซื้อเข้าสต็อก',
        reference: 'PO-2024-001',
        performedBy: 'นายสมชาย',
        transactionDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      FeedInventoryTransaction(
        id: 'ft_002',
        feedItemId: 'feed_001',
        feedItemName: 'อาหารโคนม 18% โปรตีน',
        type: 'out',
        quantity: 5.0,
        unit: FeedUnit.kg,
        reason: 'ให้อาหารสัตว์',
        reference: 'fr_001',
        performedBy: 'นายสมชาย',
        transactionDate: DateTime(now.year, now.month, now.day, 6, 0),
        createdAt: DateTime(now.year, now.month, now.day, 6, 15),
      ),
    ];

    notifyListeners();
  }

  Future<void> addFeedItem(FeedItem item) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _feedItems.insert(0, item);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มรายการอาหาร';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateFeedItem(FeedItem item) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _feedItems.indexWhere((f) => f.id == item.id);
      if (index != -1) {
        _feedItems[index] = item.copyWith(updatedAt: DateTime.now());
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการแก้ไขรายการอาหาร';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteFeedItem(String itemId) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _feedItems.removeWhere((item) => item.id == itemId);
      _feedingRecords.removeWhere((record) => record.feedItemId == itemId);
      _feedSchedules.removeWhere((schedule) => schedule.feedItemId == itemId);
      _transactions.removeWhere((transaction) => transaction.feedItemId == itemId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการลบรายการอาหาร';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFeedingRecord(FeedingRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _feedingRecords.insert(0, record);
      
      // Update stock
      final feedItemIndex = _feedItems.indexWhere((item) => item.id == record.feedItemId);
      if (feedItemIndex != -1) {
        final feedItem = _feedItems[feedItemIndex];
        final newStock = feedItem.currentStock - record.quantity;
        _feedItems[feedItemIndex] = feedItem.copyWith(
          currentStock: newStock,
          updatedAt: DateTime.now(),
        );
        
        // Add transaction
        final transaction = FeedInventoryTransaction(
          id: 'ft_${DateTime.now().millisecondsSinceEpoch}',
          feedItemId: record.feedItemId,
          feedItemName: record.feedItemName,
          type: 'out',
          quantity: record.quantity,
          unit: record.unit,
          reason: 'ให้อาหารสัตว์',
          reference: record.id,
          performedBy: record.fedBy,
          transactionDate: record.feedingTime,
          createdAt: record.createdAt,
        );
        _transactions.insert(0, transaction);
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการบันทึกการให้อาหาร';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFeedSchedule(FeedSchedule schedule) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _feedSchedules.insert(0, schedule);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มตารางให้อาหาร';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStock(String itemId, double newStock, String reason, String? performedBy) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _feedItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = _feedItems[index];
        final difference = newStock - item.currentStock;
        
        _feedItems[index] = item.copyWith(
          currentStock: newStock,
          updatedAt: DateTime.now(),
        );
        
        // Add transaction
        final transaction = FeedInventoryTransaction(
          id: 'ft_${DateTime.now().millisecondsSinceEpoch}',
          feedItemId: itemId,
          feedItemName: item.name,
          type: difference > 0 ? 'in' : 'out',
          quantity: difference.abs(),
          unit: item.unit,
          reason: reason,
          performedBy: performedBy,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        _transactions.insert(0, transaction);
        
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการปรับปรุงสต็อก';
    } finally {
      _setLoading(false);
    }
  }

  List<FeedItem> getLowStockItems() {
    return _feedItems.where((item) => item.isLowStock).toList();
  }

  List<FeedItem> getExpiringSoonItems() {
    return _feedItems.where((item) => item.isExpiringSoon).toList();
  }

  List<FeedItem> getExpiredItems() {
    return _feedItems.where((item) => item.isExpired).toList();
  }

  List<FeedSchedule> getUpcomingFeedings() {
    final now = DateTime.now();
    return _feedSchedules.where((schedule) => schedule.shouldFeedNow()).toList();
  }

  FeedSummary getFeedSummary() {
    final totalFeedItems = _feedItems.length;
    final lowStockItems = getLowStockItems().length;
    final expiringSoonItems = getExpiringSoonItems().length;
    final expiredItems = getExpiredItems().length;
    
    final totalInventoryValue = _feedItems.fold<double>(0.0, (sum, item) => sum + item.stockValue);
    
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlyFeedCost = _feedingRecords
        .where((record) => record.feedingTime.isAfter(monthStart))
        .fold<double>(0.0, (sum, record) => sum + (record.cost ?? 0.0));
    
    // Items by type
    final itemsByType = <FeedType, int>{};
    final valueByType = <FeedType, double>{};
    for (final type in FeedType.values) {
      final typeItems = _feedItems.where((item) => item.type == type);
      itemsByType[type] = typeItems.length;
      valueByType[type] = typeItems.fold<double>(0.0, (sum, item) => sum + item.stockValue);
    }
    
    // Critical items (low stock, expiring, expired)
    final criticalItems = <FeedItem>[];
    criticalItems.addAll(getLowStockItems());
    criticalItems.addAll(getExpiringSoonItems());
    criticalItems.addAll(getExpiredItems());
    
    // Recent feedings
    final recentFeedings = List<FeedingRecord>.from(_feedingRecords)
      ..sort((a, b) => b.feedingTime.compareTo(a.feedingTime))
      ..take(10);
    
    // Upcoming feedings
    final upcomingFeedings = getUpcomingFeedings();

    return FeedSummary(
      totalFeedItems: totalFeedItems,
      lowStockItems: lowStockItems,
      expiringSoonItems: expiringSoonItems,
      expiredItems: expiredItems,
      totalInventoryValue: totalInventoryValue,
      monthlyFeedCost: monthlyFeedCost,
      itemsByType: itemsByType,
      valueByType: valueByType,
      criticalItems: criticalItems.toSet().toList(), // Remove duplicates
      recentFeedings: recentFeedings.toList(),
      upcomingFeedings: upcomingFeedings,
    );
  }

  List<FeedItem> searchFeedItems(String query) {
    if (query.isEmpty) return _feedItems;
    
    final lowerQuery = query.toLowerCase();
    return _feedItems.where((item) =>
        item.name.toLowerCase().contains(lowerQuery) ||
        (item.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
        (item.supplier?.toLowerCase().contains(lowerQuery) ?? false) ||
        item.type.displayName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  List<FeedingRecord> getFeedingRecordsByDateRange(DateTime start, DateTime end) {
    return _feedingRecords
        .where((record) => 
            record.feedingTime.isAfter(start.subtract(const Duration(days: 1))) &&
            record.feedingTime.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
