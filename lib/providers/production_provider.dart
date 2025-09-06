import 'package:flutter/material.dart';
import '../models/production_management.dart';

class ProductionProvider with ChangeNotifier {
  List<ProductionRecord> _productionRecords = [];
  List<ProductionTarget> _productionTargets = [];
  bool _isLoading = false;
  String? _error;

  List<ProductionRecord> get productionRecords => _productionRecords;
  List<ProductionTarget> get productionTargets => _productionTargets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductionProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    
    _productionRecords = [
      // Milk production records
      ProductionRecord(
        id: 'pr_001',
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        type: ProductionType.milk,
        quantity: 25.5,
        quality: ProductionQuality.excellent,
        date: now,
        timeCollected: DateTime(now.year, now.month, now.day, 6, 0),
        pricePerUnit: 18.0,
        collectedBy: 'นายสมชาย',
        storageLocation: 'ถังเก็บนม A',
        notes: 'นมคุณภาพดี ไขมัน 3.8%',
        qualityMetrics: {
          'fat_content': 3.8,
          'protein': 3.2,
          'somatic_cell_count': 150000,
        },
        createdAt: now,
        updatedAt: now,
      ),
      ProductionRecord(
        id: 'pr_002',
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        type: ProductionType.milk,
        quantity: 24.0,
        quality: ProductionQuality.good,
        date: now.subtract(const Duration(days: 1)),
        timeCollected: DateTime(now.year, now.month, now.day - 1, 6, 0),
        pricePerUnit: 18.0,
        collectedBy: 'นายสมชาย',
        storageLocation: 'ถังเก็บนม A',
        qualityMetrics: {
          'fat_content': 3.6,
          'protein': 3.1,
          'somatic_cell_count': 180000,
        },
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ProductionRecord(
        id: 'pr_003',
        livestockId: 'cow_002',
        livestockName: 'โคเบอร์ 002',
        type: ProductionType.milk,
        quantity: 22.0,
        quality: ProductionQuality.good,
        date: now,
        timeCollected: DateTime(now.year, now.month, now.day, 6, 15),
        pricePerUnit: 18.0,
        collectedBy: 'นายสมชาย',
        storageLocation: 'ถังเก็บนม B',
        qualityMetrics: {
          'fat_content': 3.5,
          'protein': 3.0,
          'somatic_cell_count': 200000,
        },
        createdAt: now,
        updatedAt: now,
      ),
      
      // Egg production records
      ProductionRecord(
        id: 'pr_004',
        livestockId: 'chicken_001',
        livestockName: 'ไก่ไข่ฟาร์ม A',
        type: ProductionType.eggs,
        quantity: 180,
        quality: ProductionQuality.excellent,
        date: now,
        timeCollected: DateTime(now.year, now.month, now.day, 8, 0),
        pricePerUnit: 4.5,
        collectedBy: 'นางสมหญิง',
        storageLocation: 'ห้องเก็บไข่ 1',
        notes: 'ไข่ขนาดใหญ่ เปลือกแข็งแรง',
        qualityMetrics: {
          'average_weight': 65.0,
          'shell_thickness': 0.35,
          'yolk_color_score': 8,
        },
        createdAt: now,
        updatedAt: now,
      ),
      ProductionRecord(
        id: 'pr_005',
        livestockId: 'chicken_001',
        livestockName: 'ไก่ไข่ฟาร์ม A',
        type: ProductionType.eggs,
        quantity: 175,
        quality: ProductionQuality.good,
        date: now.subtract(const Duration(days: 1)),
        timeCollected: DateTime(now.year, now.month, now.day - 1, 8, 0),
        pricePerUnit: 4.5,
        collectedBy: 'นางสมหญิง',
        storageLocation: 'ห้องเก็บไข่ 1',
        qualityMetrics: {
          'average_weight': 63.0,
          'shell_thickness': 0.33,
          'yolk_color_score': 7,
        },
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      
      // Honey production
      ProductionRecord(
        id: 'pr_006',
        livestockId: 'beehive_001',
        livestockName: 'รังผึ้ง 001',
        type: ProductionType.honey,
        quantity: 15.5,
        quality: ProductionQuality.excellent,
        date: now.subtract(const Duration(days: 7)),
        pricePerUnit: 250.0,
        collectedBy: 'นายสมศักดิ์',
        storageLocation: 'ห้องเก็บน้ำผึ้ง',
        notes: 'น้ำผึ้งดอกลิ้นจี่ คุณภาพพรีเมียม',
        qualityMetrics: {
          'moisture_content': 17.5,
          'sugar_content': 82.0,
          'color_grade': 'Light Amber',
        },
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      
      // Meat production
      ProductionRecord(
        id: 'pr_007',
        livestockId: 'pig_001',
        livestockName: 'สุกรเบอร์ 001',
        type: ProductionType.meat,
        quantity: 85.0,
        quality: ProductionQuality.good,
        date: now.subtract(const Duration(days: 14)),
        pricePerUnit: 120.0,
        collectedBy: 'โรงฆ่าสัตว์ ABC',
        notes: 'เนื้อคุณภาพดี น้ำหนักซาก 85 กก.',
        qualityMetrics: {
          'lean_meat_percentage': 58.0,
          'fat_thickness': 2.5,
          'ph_level': 5.8,
        },
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
    ];

    _productionTargets = [
      ProductionTarget(
        id: 'pt_001',
        type: ProductionType.milk,
        dailyTarget: 50.0,
        weeklyTarget: 350.0,
        monthlyTarget: 1500.0,
        yearlyTarget: 18000.0,
        minimumQuality: ProductionQuality.good,
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        startDate: DateTime(now.year, 1, 1),
        isActive: true,
        notes: 'เป้าหมายการผลิตนมรายวัน',
        createdAt: DateTime(now.year, 1, 1),
        updatedAt: DateTime(now.year, 1, 1),
      ),
      ProductionTarget(
        id: 'pt_002',
        type: ProductionType.eggs,
        dailyTarget: 200.0,
        weeklyTarget: 1400.0,
        monthlyTarget: 6000.0,
        yearlyTarget: 72000.0,
        minimumQuality: ProductionQuality.good,
        livestockId: 'chicken_001',
        livestockName: 'ไก่ไข่ฟาร์ม A',
        startDate: DateTime(now.year, 1, 1),
        isActive: true,
        notes: 'เป้าหมายการผลิตไข่รายวัน',
        createdAt: DateTime(now.year, 1, 1),
        updatedAt: DateTime(now.year, 1, 1),
      ),
    ];

    notifyListeners();
  }

  Future<void> addProductionRecord(ProductionRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _productionRecords.insert(0, record);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มบันทึกการผลิต';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProductionRecord(ProductionRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _productionRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _productionRecords[index] = record.copyWith(updatedAt: DateTime.now());
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการแก้ไขบันทึกการผลิต';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProductionRecord(String recordId) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _productionRecords.removeWhere((record) => record.id == recordId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการลบบันทึกการผลิต';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProductionTarget(ProductionTarget target) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _productionTargets.insert(0, target);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มเป้าหมายการผลิต';
    } finally {
      _setLoading(false);
    }
  }

  List<ProductionRecord> getRecordsByType(ProductionType type) {
    return _productionRecords.where((record) => record.type == type).toList();
  }

  List<ProductionRecord> getRecordsByDateRange(DateTime start, DateTime end) {
    return _productionRecords
        .where((record) => 
            record.date.isAfter(start.subtract(const Duration(days: 1))) &&
            record.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  List<ProductionRecord> getRecordsByLivestock(String livestockId) {
    return _productionRecords.where((record) => record.livestockId == livestockId).toList();
  }

  ProductionSummary getProductionSummary({DateTime? startDate, DateTime? endDate}) {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? now;
    
    final filteredRecords = getRecordsByDateRange(start, end);
    
    final totalRecords = filteredRecords.length;
    final totalQuantity = filteredRecords.fold<double>(0.0, (sum, record) => sum + record.quantity);
    final totalValue = filteredRecords.fold<double>(0.0, (sum, record) => sum + record.calculatedTotalValue);
    
    final averageQuality = filteredRecords.isNotEmpty
        ? filteredRecords.fold<double>(0.0, (sum, record) => sum + record.quality.score) / filteredRecords.length
        : 0.0;

    // Quantity by type
    final quantityByType = <ProductionType, double>{};
    final valueByType = <ProductionType, double>{};
    for (final type in ProductionType.values) {
      final typeRecords = filteredRecords.where((r) => r.type == type);
      quantityByType[type] = typeRecords.fold<double>(0.0, (sum, record) => sum + record.quantity);
      valueByType[type] = typeRecords.fold<double>(0.0, (sum, record) => sum + record.calculatedTotalValue);
    }

    // Records by quality
    final recordsByQuality = <ProductionQuality, int>{};
    for (final quality in ProductionQuality.values) {
      recordsByQuality[quality] = filteredRecords.where((r) => r.quality == quality).length;
    }

    // Recent records
    final recentRecords = List<ProductionRecord>.from(filteredRecords)
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(10);

    // Daily production
    final dailyProduction = <String, double>{};
    final monthlyProduction = <String, double>{};
    
    for (final record in filteredRecords) {
      final dateKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
      final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      
      dailyProduction[dateKey] = (dailyProduction[dateKey] ?? 0.0) + record.quantity;
      monthlyProduction[monthKey] = (monthlyProduction[monthKey] ?? 0.0) + record.quantity;
    }

    final averageDailyProduction = dailyProduction.isNotEmpty
        ? dailyProduction.values.fold<double>(0.0, (sum, value) => sum + value) / dailyProduction.length
        : 0.0;

    // Most productive type
    final mostProductiveType = quantityByType.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Top producing livestock
    final livestockProduction = <String, double>{};
    for (final record in filteredRecords) {
      livestockProduction[record.livestockName] = 
          (livestockProduction[record.livestockName] ?? 0.0) + record.quantity;
    }
    
    final topProducingLivestock = livestockProduction.isNotEmpty
        ? livestockProduction.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : '';

    return ProductionSummary(
      totalRecords: totalRecords,
      totalQuantity: totalQuantity,
      totalValue: totalValue,
      averageQuality: averageQuality,
      quantityByType: quantityByType,
      valueByType: valueByType,
      recordsByQuality: recordsByQuality,
      recentRecords: recentRecords.toList(),
      dailyProduction: dailyProduction,
      monthlyProduction: monthlyProduction,
      averageDailyProduction: averageDailyProduction,
      mostProductiveType: mostProductiveType,
      topProducingLivestock: topProducingLivestock,
    );
  }

  Map<String, double> getProductionTrends(ProductionType type, int days) {
    final now = DateTime.now();
    final trends = <String, double>{};
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';
      
      final dayRecords = _productionRecords.where((record) =>
          record.type == type &&
          record.date.year == date.year &&
          record.date.month == date.month &&
          record.date.day == date.day
      );
      
      trends[dateKey] = dayRecords.fold<double>(0.0, (sum, record) => sum + record.quantity);
    }
    
    return trends;
  }

  double getTargetProgress(ProductionType type, String period) {
    final target = _productionTargets.firstWhere(
      (t) => t.type == type && t.isActive,
      orElse: () => ProductionTarget(
        id: '',
        type: type,
        dailyTarget: 0,
        weeklyTarget: 0,
        monthlyTarget: 0,
        yearlyTarget: 0,
        minimumQuality: ProductionQuality.average,
        startDate: DateTime.now(),
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (!target.isActive) return 0.0;

    final now = DateTime.now();
    double targetValue = 0.0;
    DateTime startDate;

    switch (period) {
      case 'daily':
        targetValue = target.dailyTarget;
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        targetValue = target.weeklyTarget;
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'monthly':
        targetValue = target.monthlyTarget;
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        targetValue = target.yearlyTarget;
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        return 0.0;
    }

    final actualProduction = getRecordsByDateRange(startDate, now)
        .where((record) => record.type == type)
        .fold<double>(0.0, (sum, record) => sum + record.quantity);

    return targetValue > 0 ? (actualProduction / targetValue) * 100 : 0.0;
  }

  List<ProductionRecord> searchProductionRecords(String query) {
    if (query.isEmpty) return _productionRecords;
    
    final lowerQuery = query.toLowerCase();
    return _productionRecords.where((record) =>
        record.livestockName.toLowerCase().contains(lowerQuery) ||
        record.type.displayName.toLowerCase().contains(lowerQuery) ||
        (record.collectedBy?.toLowerCase().contains(lowerQuery) ?? false) ||
        (record.notes?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
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
