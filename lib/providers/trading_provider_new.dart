import 'package:flutter/foundation.dart';
import '../models/trading_record.dart';

class TradingProvider with ChangeNotifier {
  List<TradingRecord> _tradingRecords = [];
  bool _isLoading = false;

  List<TradingRecord> get tradingRecords => _tradingRecords;
  bool get isLoading => _isLoading;

  List<TradingRecord> get filteredRecords => _tradingRecords;

  Future<void> loadTradingRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _tradingRecords = [
        TradingRecord(
          id: 'TR001',
          type: 'sell',
          itemName: 'โคเนื้อพันธุ์บราห์มัน',
          category: 'โคเนื้อ',
          quantity: 2,
          pricePerUnit: 45000,
          totalAmount: 90000,
          date: DateTime.now().subtract(const Duration(days: 1)),
          buyerSeller: 'บริษัท เนื้อดี จำกัด',
          status: 'completed',
          notes: 'โคคุณภาพดี น้ำหนักรวม 900 กก.',
        ),
        TradingRecord(
          id: 'TR002',
          type: 'buy',
          itemName: 'ลูกโคนมพันธุ์โฮลสไตน์',
          category: 'โคนม',
          quantity: 3,
          pricePerUnit: 25000,
          totalAmount: 75000,
          date: DateTime.now().subtract(const Duration(days: 3)),
          buyerSeller: 'ฟาร์มโคนม สุขใส',
          status: 'completed',
          notes: 'ลูกโคอายุ 6 เดือน สุขภาพดี',
        ),
        TradingRecord(
          id: 'TR003',
          type: 'sell',
          itemName: 'สุกรขุนพร้อมขาย',
          category: 'สุกร',
          quantity: 10,
          pricePerUnit: 8500,
          totalAmount: 85000,
          date: DateTime.now().subtract(const Duration(days: 5)),
          buyerSeller: 'โรงฆ่าสุกร ชัยภูมิ',
          status: 'completed',
          notes: 'น้ำหนักเฉลี่ย 85 กก./ตัว',
        ),
        TradingRecord(
          id: 'TR004',
          type: 'buy',
          itemName: 'ลูกไก่พันธุ์ไข่',
          category: 'ไก่',
          quantity: 500,
          pricePerUnit: 35,
          totalAmount: 17500,
          date: DateTime.now().subtract(const Duration(days: 7)),
          buyerSeller: 'ฟาร์มไก่ แสงทอง',
          status: 'completed',
          notes: 'ลูกไก่อายุ 1 วัน พันธุ์ไฮไลน์',
        ),
        TradingRecord(
          id: 'TR005',
          type: 'sell',
          itemName: 'ไข่ไก่สด',
          category: 'ผลิตภัณฑ์',
          quantity: 100,
          pricePerUnit: 4.5,
          totalAmount: 450,
          date: DateTime.now().subtract(const Duration(days: 2)),
          buyerSeller: 'ร้านค้าปลีก บ้านสวน',
          status: 'completed',
          notes: 'ไข่ไก่สดใหม่ ขนาดใหญ่',
        ),
        TradingRecord(
          id: 'TR006',
          type: 'buy',
          itemName: 'อาหารโคเนื้อ',
          category: 'อาหารสัตว์',
          quantity: 50,
          pricePerUnit: 850,
          totalAmount: 42500,
          date: DateTime.now().subtract(const Duration(days: 10)),
          buyerSeller: 'บริษัท อาหารสัตว์ เจริญ',
          status: 'completed',
          notes: 'อาหารสูตรเร่งโต 50 กระสอบ',
        ),
        TradingRecord(
          id: 'TR007',
          type: 'sell',
          itemName: 'แพะพันธุ์บอร์',
          category: 'แพะ',
          quantity: 5,
          pricePerUnit: 12000,
          totalAmount: 60000,
          date: DateTime.now().subtract(const Duration(days: 4)),
          buyerSeller: 'ฟาร์มแพะ ภูเขียว',
          status: 'pending',
          notes: 'แพะสำหรับขยายพันธุ์',
        ),
        TradingRecord(
          id: 'TR008',
          type: 'buy',
          itemName: 'ลูกเป็ดพันธุ์เทศ',
          category: 'เป็ด',
          quantity: 200,
          pricePerUnit: 45,
          totalAmount: 9000,
          date: DateTime.now().subtract(const Duration(days: 6)),
          buyerSeller: 'ฟาร์มเป็ด น้ำใส',
          status: 'completed',
          notes: 'ลูกเป็ดอายุ 3 วัน',
        ),
        TradingRecord(
          id: 'TR009',
          type: 'sell',
          itemName: 'นมโคสด',
          category: 'ผลิตภัณฑ์',
          quantity: 500,
          pricePerUnit: 18,
          totalAmount: 9000,
          date: DateTime.now().subtract(const Duration(hours: 12)),
          buyerSeller: 'โรงงานผลิตภัณฑ์นม',
          status: 'completed',
          notes: 'นมสดคุณภาพดี 500 ลิตร',
        ),
        TradingRecord(
          id: 'TR010',
          type: 'buy',
          itemName: 'วัคซีนป้องกันโรค',
          category: 'ยาและวัคซีน',
          quantity: 20,
          pricePerUnit: 150,
          totalAmount: 3000,
          date: DateTime.now().subtract(const Duration(days: 8)),
          buyerSeller: 'คลินิกสัตวแพทย์ ชัยภูมิ',
          status: 'completed',
          notes: 'วัคซีนป้องกันโรคปากเท้าเปื่อย',
        ),
        TradingRecord(
          id: 'TR011',
          type: 'sell',
          itemName: 'ปลาดุกแอฟริกัน',
          category: 'ปลา',
          quantity: 1000,
          pricePerUnit: 35,
          totalAmount: 35000,
          date: DateTime.now().subtract(const Duration(days: 9)),
          buyerSeller: 'ตลาดสด เมืองชัยภูมิ',
          status: 'completed',
          notes: 'ปลาดุกขนาด 300-400 กรัม/ตัว',
        ),
        TradingRecord(
          id: 'TR012',
          type: 'buy',
          itemName: 'ลูกกบพันธุ์ไทย',
          category: 'สัตว์น้ำ',
          quantity: 2000,
          pricePerUnit: 2.5,
          totalAmount: 5000,
          date: DateTime.now().subtract(const Duration(days: 12)),
          buyerSeller: 'ฟาร์มกบ บ้านนา',
          status: 'completed',
          notes: 'ลูกกบอายุ 2 สัปดาห์',
        ),
      ];

    } catch (e) {
      debugPrint('Error loading trading records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TradingRecord> getRecordsByType(String type) {
    return _tradingRecords.where((record) => record.type == type).toList();
  }

  List<TradingRecord> getRecordsByStatus(String status) {
    return _tradingRecords.where((record) => record.status == status).toList();
  }

  List<TradingRecord> getRecordsByDateRange(DateTime startDate, DateTime endDate) {
    return _tradingRecords.where((record) => 
      record.date.isAfter(startDate) && record.date.isBefore(endDate)
    ).toList();
  }

  double getTotalSales() {
    return _tradingRecords
        .where((record) => record.type == 'sell' && record.status == 'completed')
        .fold(0.0, (sum, record) => sum + record.totalAmount);
  }

  double getTotalPurchases() {
    return _tradingRecords
        .where((record) => record.type == 'buy' && record.status == 'completed')
        .fold(0.0, (sum, record) => sum + record.totalAmount);
  }

  int getTotalTransactions() {
    return _tradingRecords.length;
  }

  Future<void> addTradingRecord(TradingRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _tradingRecords.add(record);
    } catch (e) {
      throw Exception('เพิ่มรายการซื้อขายไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTradingRecord(TradingRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _tradingRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _tradingRecords[index] = record;
      }
    } catch (e) {
      throw Exception('อัปเดตรายการซื้อขายไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTradingRecord(String recordId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _tradingRecords.removeWhere((record) => record.id == recordId);
    } catch (e) {
      throw Exception('ลบรายการซื้อขายไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
