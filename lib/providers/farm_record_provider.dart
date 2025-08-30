import 'package:flutter/foundation.dart';
import '../models/farm_record.dart';

class FarmRecordProvider with ChangeNotifier {
  List<FarmRecord> _farmRecords = [];
  bool _isLoading = false;

  List<FarmRecord> get farmRecords => _farmRecords;
  bool get isLoading => _isLoading;

  List<FarmRecord> get filteredRecords => _farmRecords;

  Future<void> loadFarmRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _farmRecords = [
        FarmRecord(
          id: 'FM001',
          name: 'ฟาร์มโคนม บ้านหนองบัว',
          location: 'บ้านหนองบัว ตำบลหนองบัว อำเภอเมือง จังหวัดชัยภูมิ',
          ownerName: 'นายสมชาย ใจดี',
          phoneNumber: '081-234-5678',
          area: 25.5,
          farmType: 'โคนม',
          livestockCount: 45,
          establishedDate: DateTime(2018, 3, 15),
          status: 'active',
          description: 'ฟาร์มโคนมขนาดกลาง เน้นการผลิตนมคุณภาพสูง',
        ),
        FarmRecord(
          id: 'FM002',
          name: 'ฟาร์มสุกร บ้านโนนสวรรค์',
          location: 'บ้านโนนสวรรค์ ตำบลโนนสวรรค์ อำเภอภูเขียว จังหวัดชัยภูมิ',
          ownerName: 'นางสมหญิง รักษ์ดี',
          phoneNumber: '082-345-6789',
          area: 18.2,
          farmType: 'สุกร',
          livestockCount: 120,
          establishedDate: DateTime(2020, 7, 22),
          status: 'active',
          description: 'ฟาร์มสุกรขุนแบบปิด มีระบบควบคุมสิ่งแวดล้อม',
        ),
        FarmRecord(
          id: 'FM003',
          name: 'ฟาร์มไก่ แสงทอง',
          location: 'บ้านแสงทอง ตำบลแสงทอง อำเภอเนินสง่า จังหวัดชัยภูมิ',
          ownerName: 'นายสมศักดิ์ ขยันดี',
          phoneNumber: '083-456-7890',
          area: 12.8,
          farmType: 'ไก่ไข่',
          livestockCount: 2500,
          establishedDate: DateTime(2019, 11, 8),
          status: 'active',
          description: 'ฟาร์มไก่ไข่ระบบปิด ผลิตไข่ไก่สดคุณภาพ',
        ),
        FarmRecord(
          id: 'FM004',
          name: 'ฟาร์มแพะ ภูเขียว',
          location: 'บ้านภูเขียว ตำบลภูเขียว อำเภอภูเขียว จังหวัดชัยภูมิ',
          ownerName: 'นายสมปอง ขับดี',
          phoneNumber: '084-567-8901',
          area: 35.7,
          farmType: 'แพะ',
          livestockCount: 85,
          establishedDate: DateTime(2017, 5, 12),
          status: 'active',
          description: 'ฟาร์มแพะเนื้อและแพะนม ระบบปล่อยแบบกึ่งธรรมชาติ',
        ),
        FarmRecord(
          id: 'FM005',
          name: 'ฟาร์มเป็ด น้ำใส',
          location: 'บ้านน้ำใส ตำบลน้ำใส อำเภอแก้งคร้อ จังหวัดชัยภูมิ',
          ownerName: 'นางสมใจ ส่งดี',
          phoneNumber: '085-678-9012',
          area: 22.3,
          farmType: 'เป็ด',
          livestockCount: 800,
          establishedDate: DateTime(2021, 1, 20),
          status: 'active',
          description: 'ฟาร์มเป็ดไข่และเป็ดเนื้อ มีบ่อน้ำธรรมชาติ',
        ),
        FarmRecord(
          id: 'FM006',
          name: 'ฟาร์มปลา บ้านนา',
          location: 'บ้านนา ตำบลนาเยีย อำเภอเทพสถิต จังหวัดชัยภูมิ',
          ownerName: 'นายสมหมาย ปลาดี',
          phoneNumber: '086-789-0123',
          area: 8.5,
          farmType: 'ปลาน้ำจืด',
          livestockCount: 5000,
          establishedDate: DateTime(2022, 4, 10),
          status: 'active',
          description: 'ฟาร์มปลาดุกและปลานิล ระบบบ่อดิน',
        ),
        FarmRecord(
          id: 'FM007',
          name: 'ฟาร์มกบ บ้านนา',
          location: 'บ้านนา ตำบลนาเยีย อำเภอเทพสถิต จังหวัดชัยภูมิ',
          ownerName: 'นางสมจิตร์ กบดี',
          phoneNumber: '087-890-1234',
          area: 5.2,
          farmType: 'กบ',
          livestockCount: 15000,
          establishedDate: DateTime(2023, 2, 14),
          status: 'active',
          description: 'ฟาร์มกบพันธุ์ไทย ระบบบ่อซีเมนต์',
        ),
        FarmRecord(
          id: 'FM008',
          name: 'ฟาร์มโคเนื้อ ดอนหัวฟ้า',
          location: 'บ้านดอนหัวฟ้า ตำบลดอนหัวฟ้า อำเภอหนองบัวระเหว จังหวัดชัยภูมิ',
          ownerName: 'นายสมคิด โคดี',
          phoneNumber: '088-901-2345',
          area: 45.8,
          farmType: 'โคเนื้อ',
          livestockCount: 65,
          establishedDate: DateTime(2016, 9, 5),
          status: 'active',
          description: 'ฟาร์มโคเนื้อพันธุ์บราห์มัน ระบบปล่อยแบบธรรมชาติ',
        ),
        FarmRecord(
          id: 'FM009',
          name: 'ฟาร์มไก่เนื้อ สีดา',
          location: 'บ้านสีดา ตำบลสีดา อำเภอสีดา จังหวัดชัยภูมิ',
          ownerName: 'นายสมบัติ ไก่ดี',
          phoneNumber: '089-012-3456',
          area: 15.6,
          farmType: 'ไก่เนื้อ',
          livestockCount: 3500,
          establishedDate: DateTime(2020, 12, 18),
          status: 'maintenance',
          description: 'ฟาร์มไก่เนื้อระบบปิด กำลังปรับปรุงโรงเรือน',
        ),
        FarmRecord(
          id: 'FM010',
          name: 'ฟาร์มกระบือ บ้านเก่า',
          location: 'บ้านเก่า ตำบลเก่า อำเภอบ้านเก่า จังหวัดชัยภูมิ',
          ownerName: 'นายสมนึก กระบือดี',
          phoneNumber: '090-123-4567',
          area: 38.9,
          farmType: 'กระบือ',
          livestockCount: 28,
          establishedDate: DateTime(2015, 6, 30),
          status: 'active',
          description: 'ฟาร์มกระบือพันธุ์ไทย เลี้ยงแบบดั้งเดิม',
        ),
        FarmRecord(
          id: 'FM011',
          name: 'ฟาร์มแกะ หินดาด',
          location: 'บ้านหินดาด ตำบลหินดาด อำเภอหินดาด จังหวัดชัยภูมิ',
          ownerName: 'นางสมพร แกะดี',
          phoneNumber: '091-234-5678',
          area: 28.4,
          farmType: 'แกะ',
          livestockCount: 150,
          establishedDate: DateTime(2019, 8, 25),
          status: 'active',
          description: 'ฟาร์มแกะขนและแกะเนื้อ ระบบปล่อยแบบกึ่งธรรมชาติ',
        ),
        FarmRecord(
          id: 'FM012',
          name: 'ฟาร์มผสม บ้านใหม่',
          location: 'บ้านใหม่ ตำบลใหม่ อำเภอเมือง จังหวัดชัยภูมิ',
          ownerName: 'นายสมเกียรติ ผสมดี',
          phoneNumber: '092-345-6789',
          area: 52.1,
          farmType: 'ฟาร์มผสม',
          livestockCount: 280,
          establishedDate: DateTime(2021, 10, 12),
          status: 'inactive',
          description: 'ฟาร์มผสมหลายชนิดสัตว์ ปัจจุบันหยุดดำเนินการชั่วคราว',
        ),
      ];

    } catch (e) {
      debugPrint('Error loading farm records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<FarmRecord> getRecordsByStatus(String status) {
    return _farmRecords.where((record) => record.status == status).toList();
  }

  List<FarmRecord> getRecordsByFarmType(String farmType) {
    return _farmRecords.where((record) => record.farmType == farmType).toList();
  }

  List<FarmRecord> searchFarms(String query) {
    return _farmRecords.where((record) => 
      record.name.toLowerCase().contains(query.toLowerCase()) ||
      record.location.toLowerCase().contains(query.toLowerCase()) ||
      record.ownerName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  double getTotalArea() {
    return _farmRecords.fold(0.0, (sum, record) => sum + record.area);
  }

  int getTotalLivestock() {
    return _farmRecords.fold(0, (sum, record) => sum + record.livestockCount);
  }

  int getTotalFarms() {
    return _farmRecords.length;
  }

  int getActiveFarms() {
    return _farmRecords.where((record) => record.status == 'active').length;
  }

  Future<void> addFarmRecord(FarmRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _farmRecords.add(record);
    } catch (e) {
      throw Exception('เพิ่มรายการฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFarmRecord(FarmRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _farmRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _farmRecords[index] = record;
      }
    } catch (e) {
      throw Exception('อัปเดตรายการฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFarmRecord(String recordId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _farmRecords.removeWhere((record) => record.id == recordId);
    } catch (e) {
      throw Exception('ลบรายการฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
