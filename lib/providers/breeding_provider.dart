import 'package:flutter/material.dart';
import '../models/breeding_management.dart';

class BreedingProvider with ChangeNotifier {
  List<BreedingRecord> _breedingRecords = [];
  List<OffspringRecord> _offspringRecords = [];
  bool _isLoading = false;
  String? _error;

  List<BreedingRecord> get breedingRecords => _breedingRecords;
  List<OffspringRecord> get offspringRecords => _offspringRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BreedingProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    
    _breedingRecords = [
      BreedingRecord(
        id: 'br_001',
        motherId: 'cow_001',
        motherName: 'โคเบอร์ 001',
        fatherId: 'bull_001',
        fatherName: 'วัวพ่อพันธุ์ A',
        matingDate: now.subtract(const Duration(days: 180)),
        expectedDeliveryDate: now.add(const Duration(days: 100)),
        status: BreedingStatus.pregnant,
        veterinarian: 'นายสมชาย ใจดี',
        cost: 500.0,
        notes: 'การผสมเทียมครั้งที่ 1 สำเร็จ',
        healthChecks: {
          'month_3': 'ตรวจพบการตั้งท้อง',
          'month_6': 'ลูกโตปกติ',
        },
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      BreedingRecord(
        id: 'br_002',
        motherId: 'cow_002',
        motherName: 'โคเบอร์ 002',
        fatherId: 'bull_001',
        fatherName: 'วัวพ่อพันธุ์ A',
        matingDate: now.subtract(const Duration(days: 300)),
        expectedDeliveryDate: now.subtract(const Duration(days: 20)),
        actualDeliveryDate: now.subtract(const Duration(days: 15)),
        status: BreedingStatus.delivered,
        numberOfOffspring: 1,
        offspringIds: ['calf_001'],
        veterinarian: 'นายสมชาย ใจดี',
        cost: 500.0,
        notes: 'คลอดลูกเพศเมีย 1 ตัว สุขภาพดี',
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      BreedingRecord(
        id: 'br_003',
        motherId: 'pig_001',
        motherName: 'สุกรเบอร์ 001',
        fatherId: 'boar_001',
        fatherName: 'หมูพ่อพันธุ์ B',
        matingDate: now.subtract(const Duration(days: 90)),
        expectedDeliveryDate: now.add(const Duration(days: 25)),
        status: BreedingStatus.pregnant,
        cost: 200.0,
        notes: 'การผสมธรรมชาติ คาดว่าจะได้ลูก 8-10 ตัว',
        healthChecks: {
          'month_2': 'ตั้งท้องแน่นอน',
        },
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      BreedingRecord(
        id: 'br_004',
        motherId: 'goat_001',
        motherName: 'แพะเบอร์ 001',
        fatherId: 'buck_001',
        fatherName: 'แพะพ่อพันธุ์ C',
        matingDate: now.subtract(const Duration(days: 200)),
        expectedDeliveryDate: now.subtract(const Duration(days: 50)),
        actualDeliveryDate: now.subtract(const Duration(days: 45)),
        status: BreedingStatus.delivered,
        numberOfOffspring: 2,
        offspringIds: ['kid_001', 'kid_002'],
        cost: 150.0,
        notes: 'คลอดลูกแฝด เพศผู้และเพศเมีย',
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
      BreedingRecord(
        id: 'br_005',
        motherId: 'cow_003',
        motherName: 'โคเบอร์ 003',
        fatherId: 'bull_002',
        fatherName: 'วัวพ่อพันธุ์ D',
        matingDate: now.subtract(const Duration(days: 60)),
        expectedDeliveryDate: now.add(const Duration(days: 220)),
        status: BreedingStatus.mated,
        cost: 600.0,
        notes: 'รอตรวจการตั้งท้อง',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 60)),
      ),
    ];

    _offspringRecords = [
      OffspringRecord(
        id: 'calf_001',
        breedingRecordId: 'br_002',
        name: 'ลูกโค 001',
        gender: 'เมีย',
        birthDate: now.subtract(const Duration(days: 15)),
        birthWeight: 35.0,
        healthStatus: 'แข็งแรง',
        notes: 'เจริญเติบโตดี ดูดนมแม่ปกติ',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      OffspringRecord(
        id: 'kid_001',
        breedingRecordId: 'br_004',
        name: 'ลูกแพะ 001',
        gender: 'ผู้',
        birthDate: now.subtract(const Duration(days: 45)),
        birthWeight: 3.2,
        healthStatus: 'แข็งแรง',
        notes: 'ลูกแฝดตัวแรก',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      OffspringRecord(
        id: 'kid_002',
        breedingRecordId: 'br_004',
        name: 'ลูกแพะ 002',
        gender: 'เมีย',
        birthDate: now.subtract(const Duration(days: 45)),
        birthWeight: 3.0,
        healthStatus: 'แข็งแรง',
        notes: 'ลูกแฝดตัวที่สอง',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];

    notifyListeners();
  }

  Future<void> addBreedingRecord(BreedingRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _breedingRecords.insert(0, record);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มบันทึกการผสมพันธุ์';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBreedingRecord(BreedingRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _breedingRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _breedingRecords[index] = record.copyWith(updatedAt: DateTime.now());
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการแก้ไขบันทึกการผสมพันธุ์';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBreedingRecord(String recordId) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _breedingRecords.removeWhere((record) => record.id == recordId);
      _offspringRecords.removeWhere((offspring) => offspring.breedingRecordId == recordId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการลบบันทึกการผสมพันธุ์';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addOffspringRecord(OffspringRecord offspring) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _offspringRecords.insert(0, offspring);
      
      // Update breeding record
      final breedingIndex = _breedingRecords.indexWhere((r) => r.id == offspring.breedingRecordId);
      if (breedingIndex != -1) {
        final breeding = _breedingRecords[breedingIndex];
        final updatedOffspringIds = List<String>.from(breeding.offspringIds)..add(offspring.id);
        _breedingRecords[breedingIndex] = breeding.copyWith(
          offspringIds: updatedOffspringIds,
          numberOfOffspring: updatedOffspringIds.length,
          updatedAt: DateTime.now(),
        );
      }
      
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มบันทึกลูกสัตว์';
    } finally {
      _setLoading(false);
    }
  }

  List<BreedingRecord> getBreedingsByStatus(BreedingStatus status) {
    return _breedingRecords.where((record) => record.status == status).toList();
  }

  List<BreedingRecord> getPregnantAnimals() {
    return _breedingRecords.where((record) => record.status == BreedingStatus.pregnant).toList();
  }

  List<BreedingRecord> getUpcomingDeliveries() {
    final now = DateTime.now();
    final upcoming = now.add(const Duration(days: 30));
    
    return _breedingRecords
        .where((record) => 
            record.status == BreedingStatus.pregnant &&
            record.expectedDeliveryDate != null &&
            record.expectedDeliveryDate!.isAfter(now) &&
            record.expectedDeliveryDate!.isBefore(upcoming))
        .toList()
      ..sort((a, b) => a.expectedDeliveryDate!.compareTo(b.expectedDeliveryDate!));
  }

  List<BreedingRecord> getOverdueDeliveries() {
    final now = DateTime.now();
    
    return _breedingRecords
        .where((record) => 
            record.status == BreedingStatus.pregnant &&
            record.expectedDeliveryDate != null &&
            record.expectedDeliveryDate!.isBefore(now))
        .toList()
      ..sort((a, b) => a.expectedDeliveryDate!.compareTo(b.expectedDeliveryDate!));
  }

  List<OffspringRecord> getOffspringByBreeding(String breedingId) {
    return _offspringRecords.where((offspring) => offspring.breedingRecordId == breedingId).toList();
  }

  BreedingSummary getBreedingSummary() {
    final totalBreedings = _breedingRecords.length;
    final activePregnancies = _breedingRecords.where((r) => r.status == BreedingStatus.pregnant).length;
    final successfulDeliveries = _breedingRecords.where((r) => r.status == BreedingStatus.delivered).length;
    final failedBreedings = _breedingRecords.where((r) => r.status == BreedingStatus.failed).length;
    
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final expectedDeliveriesThisMonth = _breedingRecords
        .where((r) => 
            r.status == BreedingStatus.pregnant &&
            r.expectedDeliveryDate != null &&
            r.expectedDeliveryDate!.isAfter(now) &&
            r.expectedDeliveryDate!.isBefore(endOfMonth))
        .length;
    
    final overdueDeliveries = getOverdueDeliveries().length;
    final totalBreedingCost = _breedingRecords.fold<double>(0.0, (sum, record) => sum + (record.cost ?? 0.0));
    
    final deliveredRecords = _breedingRecords.where((r) => r.status == BreedingStatus.delivered && r.numberOfOffspring != null);
    final averageOffspringPerDelivery = deliveredRecords.isNotEmpty
        ? deliveredRecords.fold<int>(0, (sum, record) => sum + (record.numberOfOffspring ?? 0)) / deliveredRecords.length
        : 0.0;
    
    final recentBreedings = List<BreedingRecord>.from(_breedingRecords)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
      ..take(5);
    
    final upcomingDeliveries = getUpcomingDeliveries();

    return BreedingSummary(
      totalBreedings: totalBreedings,
      activePregnancies: activePregnancies,
      successfulDeliveries: successfulDeliveries,
      failedBreedings: failedBreedings,
      expectedDeliveriesThisMonth: expectedDeliveriesThisMonth,
      overdueDeliveries: overdueDeliveries,
      totalBreedingCost: totalBreedingCost,
      averageOffspringPerDelivery: averageOffspringPerDelivery,
      recentBreedings: recentBreedings.toList(),
      upcomingDeliveries: upcomingDeliveries,
    );
  }

  List<BreedingRecord> searchBreedingRecords(String query) {
    if (query.isEmpty) return _breedingRecords;
    
    final lowerQuery = query.toLowerCase();
    return _breedingRecords.where((record) =>
        record.motherName.toLowerCase().contains(lowerQuery) ||
        record.fatherName.toLowerCase().contains(lowerQuery) ||
        (record.veterinarian?.toLowerCase().contains(lowerQuery) ?? false) ||
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
