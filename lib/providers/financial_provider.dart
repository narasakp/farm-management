import 'package:flutter/foundation.dart';

class FinancialProvider with ChangeNotifier {
  List<FinancialRecord> _records = [];
  bool _isLoading = false;

  List<FinancialRecord> get records => _records;
  bool get isLoading => _isLoading;

  List<FinancialRecord> getRecordsByFarm(String farmId) {
    return _records.where((record) => record.farmId == farmId).toList();
  }

  double getTotalIncome(String farmId, DateTime? startDate, DateTime? endDate) {
    final farmRecords = getRecordsByFarm(farmId);
    return farmRecords
        .where((record) => 
            record.type == TransactionType.income &&
            (startDate == null || record.date.isAfter(startDate)) &&
            (endDate == null || record.date.isBefore(endDate)))
        .fold(0.0, (sum, record) => sum + record.amount);
  }

  double getTotalExpense(String farmId, DateTime? startDate, DateTime? endDate) {
    final farmRecords = getRecordsByFarm(farmId);
    return farmRecords
        .where((record) => 
            record.type == TransactionType.expense &&
            (startDate == null || record.date.isAfter(startDate)) &&
            (endDate == null || record.date.isBefore(endDate)))
        .fold(0.0, (sum, record) => sum + record.amount);
  }

  double getNetProfit(String farmId, DateTime? startDate, DateTime? endDate) {
    return getTotalIncome(farmId, startDate, endDate) - 
           getTotalExpense(farmId, startDate, endDate);
  }

  Future<void> loadFinancialRecords(String farmId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _records = [
        FinancialRecord(
          id: '1',
          farmId: farmId,
          type: TransactionType.income,
          category: 'ขายนม',
          amount: 15000.0,
          description: 'ขายนมโค 500 ลิตร',
          date: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        FinancialRecord(
          id: '2',
          farmId: farmId,
          type: TransactionType.expense,
          category: 'อาหารสัตว์',
          amount: 3500.0,
          description: 'ซื้อข้าวโพดบด 5 กระสอบ',
          date: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        FinancialRecord(
          id: '3',
          farmId: farmId,
          type: TransactionType.expense,
          category: 'ค่ารักษาพยาบาล',
          amount: 800.0,
          description: 'ค่าฉีดวัคซีนโค 4 ตัว',
          date: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        FinancialRecord(
          id: '4',
          farmId: farmId,
          type: TransactionType.income,
          category: 'ขายไข่',
          amount: 2400.0,
          description: 'ขายไข่ไก่ 20 แผง',
          date: DateTime.now().subtract(const Duration(days: 3)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
    } catch (e) {
      throw Exception('โหลดข้อมูลการเงินไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRecord(FinancialRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _records.add(record);
      _records.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw Exception('เพิ่มบันทึกการเงินไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecord(FinancialRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
        _records.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      throw Exception('อัปเดตบันทึกการเงินไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String recordId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _records.removeWhere((r) => r.id == recordId);
    } catch (e) {
      throw Exception('ลบบันทึกการเงินไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class FinancialRecord {
  final String id;
  final String farmId;
  final TransactionType type;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  FinancialRecord({
    required this.id,
    required this.farmId,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  factory FinancialRecord.fromJson(Map<String, dynamic> json) {
    return FinancialRecord(
      id: json['id'],
      farmId: json['farmId'],
      type: TransactionType.values.byName(json['type']),
      category: json['category'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'type': type.name,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum TransactionType {
  income('รายรับ'),
  expense('รายจ่าย');

  const TransactionType(this.displayName);
  final String displayName;
}
