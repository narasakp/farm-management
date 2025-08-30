import 'package:flutter/foundation.dart';
import '../models/livestock.dart';
import '../models/health_record.dart';

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
      
      // Mock data - 12 sample records
      _livestock = [
        Livestock(
          id: '1',
          farmId: 'farm1',
          earTag: 'COW001',
          type: LivestockType.dairyCow,
          breed: 'โฮลสไตน์',
          gender: LivestockGender.female,
          birthDate: DateTime(2021, 3, 15),
          weight: 450.0,
          status: LivestockStatus.healthy,
          notes: 'โคนมคุณภาพดี ให้นมวันละ 25 ลิตร',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '2',
          farmId: 'farm1',
          earTag: 'PIG001',
          type: LivestockType.pigFattening,
          breed: 'ลูกผสมยอร์คไชร์',
          gender: LivestockGender.male,
          birthDate: DateTime(2023, 8, 20),
          weight: 85.0,
          status: LivestockStatus.healthy,
          notes: 'สุกรขุนพร้อมขาย',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '3',
          farmId: 'farm1',
          earTag: 'CHK001',
          type: LivestockType.chickenLayer,
          breed: 'ไก่ไข่น้ำตาล',
          gender: LivestockGender.female,
          birthDate: DateTime(2023, 6, 10),
          weight: 1.8,
          status: LivestockStatus.healthy,
          notes: 'ไก่ไข่ให้ผลผลิตดี',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '4',
          farmId: 'farm1',
          earTag: 'COW002',
          type: LivestockType.beefCattleLocal,
          breed: 'โคเนื้อพื้นเมือง',
          gender: LivestockGender.female,
          birthDate: DateTime(2020, 12, 5),
          weight: 380.0,
          status: LivestockStatus.pregnant,
          notes: 'ท้อง 7 เดือน คาดคลอดเดือนหน้า',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '5',
          farmId: 'farm1',
          earTag: 'GOAT001',
          type: LivestockType.goatMeat,
          breed: 'แพะบอร์',
          gender: LivestockGender.male,
          birthDate: DateTime(2022, 9, 18),
          weight: 45.0,
          status: LivestockStatus.healthy,
          notes: 'แพะเนื้อคุณภาพดี',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '6',
          farmId: 'farm1',
          earTag: 'DUCK001',
          type: LivestockType.duckMeat,
          breed: 'เป็ดเทศ',
          gender: LivestockGender.female,
          birthDate: DateTime(2023, 4, 25),
          weight: 3.2,
          status: LivestockStatus.healthy,
          notes: 'เป็ดเนื้อโตดี',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '7',
          farmId: 'farm1',
          earTag: 'PIG002',
          type: LivestockType.pigBreeder,
          breed: 'แลนด์เรซ',
          gender: LivestockGender.female,
          birthDate: DateTime(2021, 11, 8),
          weight: 180.0,
          status: LivestockStatus.lactating,
          notes: 'แม่พันธุ์ให้ลูกอ่อน 8 ตัว',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '8',
          farmId: 'farm1',
          earTag: 'CHK002',
          type: LivestockType.chickenBroiler,
          breed: 'ไก่เนื้อ CP',
          gender: LivestockGender.male,
          birthDate: DateTime(2024, 1, 12),
          weight: 2.5,
          status: LivestockStatus.healthy,
          notes: 'ไก่เนื้อพร้อมขาย',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '9',
          farmId: 'farm1',
          earTag: 'COW003',
          type: LivestockType.beefCattleCrossbred,
          breed: 'ลูกผสมบราห์มัน',
          gender: LivestockGender.male,
          birthDate: DateTime(2022, 5, 30),
          weight: 420.0,
          status: LivestockStatus.sick,
          notes: 'ป่วยเล็กน้อย กำลังรักษา',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '10',
          farmId: 'farm1',
          earTag: 'GOAT002',
          type: LivestockType.goatDairy,
          breed: 'แพะนมซาเนน',
          gender: LivestockGender.female,
          birthDate: DateTime(2021, 7, 22),
          weight: 55.0,
          status: LivestockStatus.lactating,
          notes: 'แพะนมให้นมวันละ 3 ลิตร',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '11',
          farmId: 'farm1',
          earTag: 'DUCK002',
          type: LivestockType.duckEgg,
          breed: 'เป็ดไข่ไคยา',
          gender: LivestockGender.female,
          birthDate: DateTime(2022, 10, 14),
          weight: 2.8,
          status: LivestockStatus.healthy,
          notes: 'เป็ดไข่ให้ไข่วันละ 1 ฟอง',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Livestock(
          id: '12',
          farmId: 'farm1',
          earTag: 'PIG003',
          type: LivestockType.pigLocal,
          breed: 'สุกรพื้นเมือง',
          gender: LivestockGender.female,
          birthDate: DateTime(2023, 2, 8),
          weight: 65.0,
          status: LivestockStatus.sold,
          notes: 'ขายแล้วเมื่อสัปดาห์ที่แล้ว',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Mock health records
      _healthRecords = [
        HealthRecord(
          id: '1',
          livestockId: '1',
          date: DateTime.now().subtract(const Duration(days: 30)),
          recordType: 'checkup',
          notes: 'ตรวจสุขภาพประจำเดือน, สุขภาพดี, ฉีดวิตามิน',
          cost: 150.0,
          veterinarian: 'สพ.ประเสริฐ',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        HealthRecord(
          id: '2',
          livestockId: '2',
          date: DateTime.now().subtract(const Duration(days: 15)),
          recordType: 'checkup',
          notes: 'ตรวจครรภ์, ตั้งท้อง 6 เดือน, ให้วิตามินเสริม',
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
