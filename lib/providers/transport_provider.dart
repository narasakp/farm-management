import 'package:flutter/foundation.dart';
import '../models/transport_record.dart';

class TransportProvider with ChangeNotifier {
  List<TransportRecord> _transportRecords = [];
  bool _isLoading = false;

  List<TransportRecord> get transportRecords => _transportRecords;
  bool get isLoading => _isLoading;

  List<TransportRecord> get filteredRecords => _transportRecords;

  Future<void> loadTransportRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _transportRecords = [
        TransportRecord(
          id: 'TP001',
          type: 'delivery',
          itemName: 'โคเนื้อพันธุ์บราห์มัน',
          quantity: 2,
          fromLocation: 'ฟาร์มโคนม บ้านหนองบัว',
          toLocation: 'ตลาดโค เนินสง่า',
          scheduledDate: DateTime.now().add(const Duration(days: 2)),
          actualDate: null,
          driverName: 'สมชาย ใจดี',
          vehicleNumber: 'กข-1234',
          status: 'scheduled',
          distance: 25.5,
          cost: 775,
          notes: 'โคคุณภาพดี น้ำหนักรวม 900 กก.',
        ),
        TransportRecord(
          id: 'TP002',
          type: 'pickup',
          itemName: 'ลูกโคนมพันธุ์โฮลสไตน์',
          quantity: 3,
          fromLocation: 'ฟาร์มโคนม สุขใส',
          toLocation: 'ฟาร์มของเรา',
          scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
          actualDate: DateTime.now().subtract(const Duration(days: 1)),
          driverName: 'สมหญิง รักษ์ดี',
          vehicleNumber: 'คง-5678',
          status: 'delivered',
          distance: 18.2,
          cost: 668,
          notes: 'ลูกโคอายุ 6 เดือน สุขภาพดี',
        ),
        TransportRecord(
          id: 'TP003',
          type: 'delivery',
          itemName: 'สุกรขุนพร้อมขาย',
          quantity: 10,
          fromLocation: 'ฟาร์มของเรา',
          toLocation: 'โรงฆ่าสุกร ชัยภูมิ',
          scheduledDate: DateTime.now().subtract(const Duration(days: 3)),
          actualDate: DateTime.now().subtract(const Duration(days: 3)),
          driverName: 'สมศักดิ์ ขยันดี',
          vehicleNumber: 'จฉ-9012',
          status: 'delivered',
          distance: 32.1,
          cost: 1142,
          notes: 'น้ำหนักเฉลี่ย 85 กก./ตัว',
        ),
        TransportRecord(
          id: 'TP004',
          type: 'pickup',
          itemName: 'ลูกไก่พันธุ์ไข่',
          quantity: 500,
          fromLocation: 'ฟาร์มไก่ แสงทอง',
          toLocation: 'ฟาร์มของเรา',
          scheduledDate: DateTime.now().subtract(const Duration(days: 5)),
          actualDate: DateTime.now().subtract(const Duration(days: 5)),
          driverName: 'สมปอง ขับดี',
          vehicleNumber: 'ฉช-3456',
          status: 'delivered',
          distance: 45.3,
          cost: 543,
          notes: 'ลูกไก่อายุ 1 วัน พันธุ์ไฮไลน์',
        ),
        TransportRecord(
          id: 'TP005',
          type: 'delivery',
          itemName: 'ไข่ไก่สด',
          quantity: 100,
          fromLocation: 'ฟาร์มของเรา',
          toLocation: 'ร้านค้าปลีก บ้านสวน',
          scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
          actualDate: DateTime.now().subtract(const Duration(days: 1)),
          driverName: 'สมใจ ส่งดี',
          vehicleNumber: 'ซฌ-7890',
          status: 'delivered',
          distance: 12.5,
          cost: 200,
          notes: 'ไข่ไก่สดใหม่ ขนาดใหญ่',
        ),
        TransportRecord(
          id: 'TP006',
          type: 'pickup',
          itemName: 'อาหารโคเนื้อ',
          quantity: 50,
          fromLocation: 'บริษัท อาหารสัตว์ เจริญ',
          toLocation: 'ฟาร์มของเรา',
          scheduledDate: DateTime.now().subtract(const Duration(days: 7)),
          actualDate: DateTime.now().subtract(const Duration(days: 7)),
          driverName: 'สมชาย ใจดี',
          vehicleNumber: 'กข-1234',
          status: 'delivered',
          distance: 28.7,
          cost: 430,
          notes: 'อาหารสูตรเร่งโต 50 กระสอบ',
        ),
        TransportRecord(
          id: 'TP007',
          type: 'delivery',
          itemName: 'แพะพันธุ์บอร์',
          quantity: 5,
          fromLocation: 'ฟาร์มของเรา',
          toLocation: 'ฟาร์มแพะ ภูเขียว',
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          actualDate: null,
          driverName: 'สมหญิง รักษ์ดี',
          vehicleNumber: 'คง-5678',
          status: 'scheduled',
          distance: 55.2,
          cost: 1414,
          notes: 'แพะสำหรับขยายพันธุ์',
        ),
        TransportRecord(
          id: 'TP008',
          type: 'pickup',
          itemName: 'ลูกเป็ดพันธุ์เทศ',
          quantity: 200,
          fromLocation: 'ฟาร์มเป็ด น้ำใส',
          toLocation: 'ฟาร์มของเรา',
          scheduledDate: DateTime.now().subtract(const Duration(days: 4)),
          actualDate: DateTime.now().subtract(const Duration(days: 4)),
          driverName: 'สมศักดิ์ ขยันดี',
          vehicleNumber: 'จฉ-9012',
          status: 'delivered',
          distance: 22.8,
          cost: 456,
          notes: 'ลูกเป็ดอายุ 3 วัน',
        ),
        TransportRecord(
          id: 'TP009',
          type: 'delivery',
          itemName: 'นมโคสด',
          quantity: 500,
          fromLocation: 'ฟาร์มของเรา',
          toLocation: 'โรงงานผลิตภัณฑ์นม',
          scheduledDate: DateTime.now().subtract(const Duration(hours: 6)),
          actualDate: DateTime.now().subtract(const Duration(hours: 6)),
          driverName: 'สมปอง ขับดี',
          vehicleNumber: 'ฉช-3456',
          status: 'delivered',
          distance: 15.3,
          cost: 245,
          notes: 'นมสดคุณภาพดี 500 ลิตร',
        ),
        TransportRecord(
          id: 'TP010',
          type: 'pickup',
          itemName: 'วัคซีนป้องกันโรค',
          quantity: 20,
          fromLocation: 'คลินิกสัตวแพทย์ ชัยภูมิ',
          toLocation: 'ฟาร์มของเรา',
          scheduledDate: DateTime.now().subtract(const Duration(days: 6)),
          actualDate: DateTime.now().subtract(const Duration(days: 6)),
          driverName: 'สมใจ ส่งดี',
          vehicleNumber: 'ซฌ-7890',
          status: 'delivered',
          distance: 8.5,
          cost: 170,
          notes: 'วัคซีนป้องกันโรคปากเท้าเปื่อย',
        ),
        TransportRecord(
          id: 'TP011',
          type: 'delivery',
          itemName: 'ปลาดุกแอฟริกัน',
          quantity: 1000,
          fromLocation: 'ฟาร์มปลาของเรา',
          toLocation: 'ตลาดสด เมืองชัยภูมิ',
          scheduledDate: DateTime.now().subtract(const Duration(days: 8)),
          actualDate: DateTime.now().subtract(const Duration(days: 8)),
          driverName: 'สมชาย ใจดี',
          vehicleNumber: 'กข-1234',
          status: 'delivered',
          distance: 19.7,
          cost: 394,
          notes: 'ปลาดุกขนาด 300-400 กรัม/ตัว',
        ),
        TransportRecord(
          id: 'TP012',
          type: 'transfer',
          itemName: 'ลูกกบพันธุ์ไทย',
          quantity: 2000,
          fromLocation: 'ฟาร์มกบ บ้านนา',
          toLocation: 'ฟาร์มกบของเรา',
          scheduledDate: DateTime.now().subtract(const Duration(days: 10)),
          actualDate: DateTime.now().subtract(const Duration(days: 10)),
          driverName: 'สมหญิง รักษ์ดี',
          vehicleNumber: 'คง-5678',
          status: 'delivered',
          distance: 35.4,
          cost: 708,
          notes: 'ลูกกบอายุ 2 สัปดาห์',
        ),
      ];

    } catch (e) {
      debugPrint('Error loading transport records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TransportRecord> getRecordsByType(String type) {
    return _transportRecords.where((record) => record.type == type).toList();
  }

  List<TransportRecord> getRecordsByStatus(String status) {
    return _transportRecords.where((record) => record.status == status).toList();
  }

  List<TransportRecord> getRecordsByDateRange(DateTime startDate, DateTime endDate) {
    return _transportRecords.where((record) => 
      record.scheduledDate.isAfter(startDate) && record.scheduledDate.isBefore(endDate)
    ).toList();
  }

  double getTotalTransportCost() {
    return _transportRecords
        .where((record) => record.status == 'delivered')
        .fold(0.0, (sum, record) => sum + record.cost);
  }

  double getTotalDistance() {
    return _transportRecords
        .where((record) => record.status == 'delivered')
        .fold(0.0, (sum, record) => sum + record.distance);
  }

  int getTotalTransports() {
    return _transportRecords.length;
  }

  Future<void> addTransportRecord(TransportRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _transportRecords.add(record);
    } catch (e) {
      throw Exception('เพิ่มรายการขนส่งไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransportRecord(TransportRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _transportRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _transportRecords[index] = record;
      }
    } catch (e) {
      throw Exception('อัปเดตรายการขนส่งไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransportRecord(String recordId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _transportRecords.removeWhere((record) => record.id == recordId);
    } catch (e) {
      throw Exception('ลบรายการขนส่งไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Legacy methods for compatibility with old screens
  List<dynamic> get availableVehicles => [];
  List<dynamic> get myVehicles => [];
  List<dynamic> get transportBookings => [];

  Future<void> loadTransportData() async {
    await loadTransportRecords();
  }

  Future<void> addVehicle(dynamic vehicle) async {
    // Placeholder for adding vehicle
    notifyListeners();
  }

  Future<void> bookTransport(dynamic booking) async {
    // Convert booking to transport record
    final record = TransportRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'delivery',
      itemName: booking.toString(),
      quantity: 1,
      fromLocation: 'Unknown',
      toLocation: 'Unknown',
      scheduledDate: DateTime.now(),
      actualDate: null,
      driverName: 'Unknown',
      vehicleNumber: '',
      status: 'pending',
      distance: 0.0,
      cost: 0.0,
      notes: 'Transport booking',
    );
    await addTransportRecord(record);
  }

  Future<void> updateVehicle(dynamic vehicle) async {
    // Placeholder for updating vehicle
    notifyListeners();
  }

  Future<void> toggleVehicleStatus(String vehicleId) async {
    // Placeholder for toggling vehicle status
    notifyListeners();
  }
}
