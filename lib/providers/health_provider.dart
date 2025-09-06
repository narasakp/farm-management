import 'package:flutter/material.dart';
import '../models/health_management.dart';
import '../models/livestock.dart';

class HealthProvider with ChangeNotifier {
  List<HealthRecord> _healthRecords = [];
  List<VaccinationSchedule> _vaccinationSchedules = [];
  bool _isLoading = false;
  String? _error;

  List<HealthRecord> get healthRecords => _healthRecords;
  List<VaccinationSchedule> get vaccinationSchedules => _vaccinationSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HealthProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    
    // Sample vaccination schedules
    _vaccinationSchedules = [
      VaccinationSchedule(
        id: 'vac_1',
        vaccineName: 'วัคซีนป้องกันโรคปากและเท้าเปื่อย',
        description: 'ป้องกันโรคปากและเท้าเปื่อยในโค-กระบือ',
        ageInDays: 90,
        isRequired: true,
        notes: 'ฉีดซ้ำทุก 6 เดือน',
      ),
      VaccinationSchedule(
        id: 'vac_2',
        vaccineName: 'วัคซีนป้องกันโรคเลือดออก',
        description: 'ป้องกันโรคเลือดออกในโค-กระบือ',
        ageInDays: 120,
        isRequired: true,
        notes: 'ฉีดซ้ำทุกปี',
      ),
      VaccinationSchedule(
        id: 'vac_3',
        vaccineName: 'วัคซีนป้องกันโรคไข้หวัดนก',
        description: 'ป้องกันโรคไข้หวัดนกในไก่-เป็ด',
        ageInDays: 14,
        isRequired: true,
        notes: 'ฉีดซ้ำทุก 3 เดือน',
      ),
    ];

    // Sample health records
    _healthRecords = [
      HealthRecord(
        id: 'hr_001',
        livestockId: 'cow_001',
        livestockName: 'โคเบอร์ 001',
        type: HealthRecordType.vaccination,
        title: 'ฉีดวัคซีนป้องกันโรคปากและเท้าเปื่อย',
        description: 'ฉีดวัคซีนป้องกันโรคปากและเท้าเปื่อยครั้งที่ 1',
        date: now.subtract(const Duration(days: 30)),
        veterinarian: 'นายสมชาย ใจดี',
        clinic: 'คลินิกสัตวแพทย์เนินสง่า',
        cost: 150.0,
        medication: 'วัคซีน FMD',
        dosage: '2 ml',
        nextDueDate: now.add(const Duration(days: 150)),
        status: HealthStatus.healthy,
        symptoms: [],
        notes: 'ฉีดเข้าใต้หนัง บริเวณคอ',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      HealthRecord(
        id: 'hr_002',
        livestockId: 'cow_002',
        livestockName: 'โคเบอร์ 002',
        type: HealthRecordType.treatment,
        title: 'รักษาโรคท้องเสีย',
        description: 'รักษาอาการท้องเสียและขาดน้ำ',
        date: now.subtract(const Duration(days: 15)),
        veterinarian: 'นางสาวมาลี สุขใส',
        clinic: 'โรงพยาบาลสัตว์ชัยภูมิ',
        cost: 350.0,
        medication: 'ยาแก้ท้องเสีย + เกลือแร่',
        dosage: '10 ml x 3 วัน',
        status: HealthStatus.recovering,
        symptoms: ['ท้องเสีย', 'ขาดน้ำ', 'ไม่กินอาหาร'],
        notes: 'ให้ยาต่อเนื่อง 3 วัน ดีขึ้นมาก',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
      HealthRecord(
        id: 'hr_003',
        livestockId: 'pig_001',
        livestockName: 'สุกรเบอร์ 001',
        type: HealthRecordType.checkup,
        title: 'ตรวจสุขภาพประจำเดือน',
        description: 'ตรวจสุขภาพทั่วไปและชั่งน้ำหนัก',
        date: now.subtract(const Duration(days: 7)),
        veterinarian: 'นายประยุทธ์ รักสัตว์',
        cost: 100.0,
        status: HealthStatus.healthy,
        symptoms: [],
        notes: 'สุขภาพแข็งแรงดี น้ำหนัก 85 กก.',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      HealthRecord(
        id: 'hr_004',
        livestockId: 'chicken_001',
        livestockName: 'ไก่โรงเรือน A',
        type: HealthRecordType.vaccination,
        title: 'ฉีดวัคซีนป้องกันโรคไข้หวัดนก',
        description: 'ฉีดวัคซีนป้องกันโรคไข้หวัดนกให้ไก่ทั้งโรงเรือน',
        date: now.subtract(const Duration(days: 45)),
        veterinarian: 'นายสุรชัย ปศุสัตว์',
        cost: 500.0,
        medication: 'วัคซีน AI H5N1',
        dosage: '0.5 ml ต่อตัว',
        nextDueDate: now.add(const Duration(days: 45)),
        status: HealthStatus.healthy,
        symptoms: [],
        notes: 'ฉีดให้ไก่ 100 ตัว',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
      HealthRecord(
        id: 'hr_005',
        livestockId: 'cow_003',
        livestockName: 'โคเบอร์ 003',
        type: HealthRecordType.illness,
        title: 'เจ็บป่วยด้วยโรคเท้าเปื่อย',
        description: 'พบอาการเท้าเปื่อยและเดินกะเผลก',
        date: now.subtract(const Duration(days: 5)),
        veterinarian: 'นายสมชาย ใจดี',
        clinic: 'คลินิกสัตวแพทย์เนินสง่า',
        cost: 250.0,
        medication: 'ยาฆ่าเชื้อ + ยาปฏิชีวนะ',
        dosage: 'ทาภายนอก + ฉีด 5 ml',
        status: HealthStatus.sick,
        symptoms: ['เท้าเปื่อย', 'เดินกะเผลก', 'ไข้'],
        notes: 'กักแยกจากฝูง รักษาต่อเนื่อง',
        attachments: [],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    notifyListeners();
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      _healthRecords.insert(0, record);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการเพิ่มบันทึกสุขภาพ';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      final index = _healthRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _healthRecords[index] = record.copyWith(updatedAt: DateTime.now());
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการแก้ไขบันทึกสุขภาพ';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHealthRecord(String recordId) async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
      _healthRecords.removeWhere((record) => record.id == recordId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'เกิดข้อผิดพลาดในการลบบันทึกสุขภาพ';
    } finally {
      _setLoading(false);
    }
  }

  List<HealthRecord> getHealthRecordsByLivestock(String livestockId) {
    return _healthRecords.where((record) => record.livestockId == livestockId).toList();
  }

  List<HealthRecord> getHealthRecordsByType(HealthRecordType type) {
    return _healthRecords.where((record) => record.type == type).toList();
  }

  List<HealthRecord> getHealthRecordsByStatus(HealthStatus status) {
    return _healthRecords.where((record) => record.status == status).toList();
  }

  List<HealthRecord> getUpcomingVaccinations() {
    final now = DateTime.now();
    final upcoming = DateTime.now().add(const Duration(days: 30));
    
    return _healthRecords
        .where((record) => 
            record.type == HealthRecordType.vaccination &&
            record.nextDueDate != null &&
            record.nextDueDate!.isAfter(now) &&
            record.nextDueDate!.isBefore(upcoming))
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  List<HealthRecord> getOverdueVaccinations() {
    final now = DateTime.now();
    
    return _healthRecords
        .where((record) => 
            record.type == HealthRecordType.vaccination &&
            record.nextDueDate != null &&
            record.nextDueDate!.isBefore(now))
        .toList()
      ..sort((a, b) => a.nextDueDate!.compareTo(b.nextDueDate!));
  }

  HealthSummary getHealthSummary() {
    final totalRecords = _healthRecords.length;
    final vaccinationCount = _healthRecords.where((r) => r.type == HealthRecordType.vaccination).length;
    final treatmentCount = _healthRecords.where((r) => r.type == HealthRecordType.treatment).length;
    final healthyCount = _healthRecords.where((r) => r.status == HealthStatus.healthy).length;
    final sickCount = _healthRecords.where((r) => r.status == HealthStatus.sick).length;
    final totalCost = _healthRecords.fold<double>(0.0, (sum, record) => sum + (record.cost ?? 0.0));
    
    final vaccinations = _healthRecords.where((r) => r.type == HealthRecordType.vaccination).toList();
    final lastVaccination = vaccinations.isNotEmpty 
        ? vaccinations.reduce((a, b) => a.date.isAfter(b.date) ? a : b).date
        : null;
    
    final upcoming = getUpcomingVaccinations();
    final nextDueVaccination = upcoming.isNotEmpty ? upcoming.first.nextDueDate : null;
    
    final recentRecords = List<HealthRecord>.from(_healthRecords)
      ..sort((a, b) => b.date.compareTo(a.date))
      ..take(5);

    return HealthSummary(
      totalRecords: totalRecords,
      vaccinationCount: vaccinationCount,
      treatmentCount: treatmentCount,
      healthyCount: healthyCount,
      sickCount: sickCount,
      totalCost: totalCost,
      lastVaccination: lastVaccination,
      nextDueVaccination: nextDueVaccination,
      recentRecords: recentRecords.toList(),
      upcomingVaccinations: upcoming,
    );
  }

  List<HealthRecord> searchHealthRecords(String query) {
    if (query.isEmpty) return _healthRecords;
    
    final lowerQuery = query.toLowerCase();
    return _healthRecords.where((record) =>
        record.title.toLowerCase().contains(lowerQuery) ||
        record.description.toLowerCase().contains(lowerQuery) ||
        record.livestockName.toLowerCase().contains(lowerQuery) ||
        (record.veterinarian?.toLowerCase().contains(lowerQuery) ?? false) ||
        (record.medication?.toLowerCase().contains(lowerQuery) ?? false)
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
