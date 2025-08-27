import 'package:flutter/foundation.dart';
import '../models/livestock.dart';

class LivestockProvider with ChangeNotifier {
  List<Livestock> _livestock = [];
  List<HealthRecord> _healthRecords = [];
  bool _isLoading = false;

  List<Livestock> get livestock => _livestock;
  List<HealthRecord> get healthRecords => _healthRecords;
  bool get isLoading => _isLoading;

  List<Livestock> getLivestockByFarm(String farmId) {
    return _livestock.where((animal) => animal.farmId == farmId).toList();
  }

  List<HealthRecord> getHealthRecordsByLivestock(String livestockId) {
    return _healthRecords.where((record) => record.livestockId == livestockId).toList();
  }

  Map<LivestockType, int> getLivestockSummary(String farmId) {
    final farmLivestock = getLivestockByFarm(farmId);
    final summary = <LivestockType, int>{};
    
    for (final animal in farmLivestock) {
      summary[animal.type] = (summary[animal.type] ?? 0) + 1;
    }
    
    return summary;
  }

  Future<void> loadLivestock(String farmId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _livestock = [
        Livestock(
          id: '1',
          farmId: farmId,
          type: LivestockType.dairyCow,
          breed: 'โฮลสไตน์',
          gender: 'เมีย',
          birthDate: DateTime(2021, 3, 15),
          weight: 450.0,
          earTag: 'DC001',
          status: LivestockStatus.lactating,
          createdAt: DateTime.now().subtract(const Duration(days: 800)),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '2',
          farmId: farmId,
          type: LivestockType.dairyCow,
          breed: 'โฮลสไตน์',
          gender: 'เมีย',
          birthDate: DateTime(2020, 8, 22),
          weight: 520.0,
          earTag: 'DC002',
          status: LivestockStatus.pregnant,
          createdAt: DateTime.now().subtract(const Duration(days: 1200)),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '3',
          farmId: farmId,
          type: LivestockType.chicken,
          breed: 'ไก่ไข่',
          gender: 'เมีย',
          birthDate: DateTime(2023, 1, 10),
          weight: 1.8,
          earTag: 'CH001',
          status: LivestockStatus.healthy,
          createdAt: DateTime.now().subtract(const Duration(days: 300)),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '4',
          farmId: farmId,
          type: LivestockType.pig,
          breed: 'ลูกผสม',
          gender: 'ผู้',
          birthDate: DateTime(2023, 5, 5),
          weight: 85.0,
          earTag: 'PG001',
          status: LivestockStatus.healthy,
          createdAt: DateTime.now().subtract(const Duration(days: 150)),
          updatedAt: DateTime.now(),
        ),
      ];

      // Mock health records
      _healthRecords = [
        HealthRecord(
          id: '1',
          livestockId: '1',
          date: DateTime.now().subtract(const Duration(days: 30)),
          symptoms: 'ตรวจสุขภาพประจำเดือน',
          diagnosis: 'สุขภาพดี',
          treatment: 'ฉีดวิตามิน',
          cost: 150.0,
          veterinarian: 'สพ.ประเสริฐ',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        HealthRecord(
          id: '2',
          livestockId: '2',
          date: DateTime.now().subtract(const Duration(days: 15)),
          symptoms: 'ตรวจครรภ์',
          diagnosis: 'ตั้งท้อง 6 เดือน',
          treatment: 'ให้วิตามินเสริม',
          cost: 200.0,
          veterinarian: 'สพ.ประเสริฐ',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
      ];
    } catch (e) {
      throw Exception('โหลดข้อมูลปศุสัตว์ไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLivestock(Livestock animal) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _livestock.add(animal);
    } catch (e) {
      throw Exception('เพิ่มปศุสัตว์ไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLivestock(Livestock animal) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _livestock.indexWhere((l) => l.id == animal.id);
      if (index != -1) {
        _livestock[index] = animal;
      }
    } catch (e) {
      throw Exception('อัปเดตข้อมูลปศุสัตว์ไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLivestock(String livestockId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _livestock.removeWhere((l) => l.id == livestockId);
      _healthRecords.removeWhere((r) => r.livestockId == livestockId);
    } catch (e) {
      throw Exception('ลบข้อมูลปศุสัตว์ไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _healthRecords.add(record);
    } catch (e) {
      throw Exception('เพิ่มบันทึกสุขภาพไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
