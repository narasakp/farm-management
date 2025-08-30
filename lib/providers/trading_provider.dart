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

  int get totalTradingRecords => _tradingRecords.length;
  
  double get totalSales => _tradingRecords
      .where((record) => record.type == 'sell')
      .fold(0.0, (sum, record) => sum + (record.pricePerUnit * record.quantity));
  
  double get totalPurchases => _tradingRecords
      .where((record) => record.type == 'buy')
      .fold(0.0, (sum, record) => sum + (record.pricePerUnit * record.quantity));

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

  // Market listings for online marketplace
  List<Map<String, dynamic>> _marketListings = [];
  
  List<Map<String, dynamic>> get marketListings => _marketListings;

  // Legacy methods for compatibility with old screens
  Future<void> loadMarketListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _marketListings = [
        {
          'id': 'ML001',
          'title': 'โคเนื้อบราห์มันคุณภาพดี',
          'category': 'โค',
          'price': 45000,
          'unit': 'ตัว',
          'seller': 'ฟาร์มสุขใส',
          'location': 'นครราชสีมา',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'โคเนื้อพันธุ์บราห์มัน อายุ 2 ปี น้ำหนัก 450 กก. สุขภาพดี',
          'quantity': 3,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(hours: 2)),
          'views': 45,
          'likes': 8,
        },
        {
          'id': 'ML002',
          'title': 'ลูกโคนมโฮลสไตน์',
          'category': 'โค',
          'price': 25000,
          'unit': 'ตัว',
          'seller': 'ฟาร์มโคนมทองคำ',
          'location': 'สระบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'ลูกโคนมพันธุ์โฮลสไตน์ อายุ 6 เดือน ฉีดวัคซีนครบ',
          'quantity': 5,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(hours: 5)),
          'views': 32,
          'likes': 12,
        },
        {
          'id': 'ML003',
          'title': 'สุกรขุนพร้อมขาย',
          'category': 'สุกร',
          'price': 8500,
          'unit': 'ตัว',
          'seller': 'ฟาร์มสุกรบ้านสวน',
          'location': 'ลพบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'สุกรขุนน้ำหนัก 110 กก. พร้อมขาย สุขภาพดี',
          'quantity': 8,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(hours: 8)),
          'views': 28,
          'likes': 5,
        },
        {
          'id': 'ML004',
          'title': 'ไก่ไข่พันธุ์ดี',
          'category': 'ไก่',
          'price': 180,
          'unit': 'ตัว',
          'seller': 'ฟาร์มไก่ไข่มั่งมี',
          'location': 'ชลบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'ไก่ไข่พันธุ์ไฮไลน์ อายุ 18 สัปดาห์ ให้ไข่ได้แล้ว',
          'quantity': 50,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(hours: 12)),
          'views': 67,
          'likes': 15,
        },
        {
          'id': 'ML005',
          'title': 'แพะบอร์เนื้อดี',
          'category': 'แพะ',
          'price': 4500,
          'unit': 'ตัว',
          'seller': 'ฟาร์มแพะภูเขา',
          'location': 'เพชรบูรณ์',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'แพะบอร์พันธุ์แท้ อายุ 8 เดือน น้ำหนัก 25 กก.',
          'quantity': 6,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 1)),
          'views': 23,
          'likes': 4,
        },
        {
          'id': 'ML006',
          'title': 'เป็ดเทศเนื้อหวาน',
          'category': 'เป็ด',
          'price': 350,
          'unit': 'ตัว',
          'seller': 'ฟาร์มเป็ดริมน้ำ',
          'location': 'อยุธยา',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'เป็ดเทศอายุ 10 สัปดาห์ น้ำหนัก 3.5 กก. เนื้อหวาน',
          'quantity': 20,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          'views': 41,
          'likes': 9,
        },
        {
          'id': 'ML007',
          'title': 'กระบือไทยพันธุ์แท้',
          'category': 'กระบือ',
          'price': 35000,
          'unit': 'ตัว',
          'seller': 'ฟาร์มกระบือไทย',
          'location': 'สุพรรณบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'กระบือไทยพันธุ์แท้ อายุ 3 ปี แข็งแรง เหมาะทำงาน',
          'quantity': 2,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 2)),
          'views': 18,
          'likes': 3,
        },
        {
          'id': 'ML008',
          'title': 'แกะดอร์เปอร์เนื้อดี',
          'category': 'แกะ',
          'price': 6500,
          'unit': 'ตัว',
          'seller': 'ฟาร์มแกะดอร์เปอร์',
          'location': 'กาญจนบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'แกะดอร์เปอร์อายุ 1 ปี น้ำหนัก 35 กก. เนื้อนุ่ม',
          'quantity': 4,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          'views': 29,
          'likes': 6,
        },
        {
          'id': 'ML009',
          'title': 'โคนมผลิตสูง',
          'category': 'โค',
          'price': 55000,
          'unit': 'ตัว',
          'seller': 'ฟาร์มโคนมพรีเมี่ยม',
          'location': 'ราชบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'โคนมให้นมวันละ 30 ลิตร อายุ 4 ปี สุขภาพดีเยี่ยม',
          'quantity': 1,
          'status': 'sold',
          'posted': DateTime.now().subtract(const Duration(days: 3)),
          'views': 89,
          'likes': 22,
        },
        {
          'id': 'ML010',
          'title': 'ไก่เนื้อโบรยเลอร์',
          'category': 'ไก่',
          'price': 85,
          'unit': 'ตัว',
          'seller': 'ฟาร์มไก่เนื้อใหญ่',
          'location': 'นครปฐม',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'ไก่เนื้อโบรยเลอร์ อายุ 45 วัน น้ำหนัก 2.2 กก.',
          'quantity': 100,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 3, hours: 8)),
          'views': 156,
          'likes': 31,
        },
        {
          'id': 'ML011',
          'title': 'สุกรพันธุ์แลนด์เรซ',
          'category': 'สุกร',
          'price': 12000,
          'unit': 'ตัว',
          'seller': 'ฟาร์มสุกรพันธุ์ดี',
          'location': 'ปราจีนบุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'สุกรแม่พันธุ์แลนด์เรซ อายุ 1.5 ปี พร้อมผสมพันธุ์',
          'quantity': 3,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 4)),
          'views': 37,
          'likes': 8,
        },
        {
          'id': 'ML012',
          'title': 'เป็ดไข่ขาวใหญ่',
          'category': 'เป็ด',
          'price': 280,
          'unit': 'ตัว',
          'seller': 'ฟาร์มเป็ดไข่คุณภาพ',
          'location': 'สิงห์บุรี',
          'image': 'https://via.placeholder.com/300x200',
          'description': 'เป็ดไข่พันธุ์ขาวใหญ่ อายุ 20 สัปดาห์ ให้ไข่ได้แล้ว',
          'quantity': 25,
          'status': 'available',
          'posted': DateTime.now().subtract(const Duration(days: 5)),
          'views': 52,
          'likes': 11,
        },
      ];
    } catch (e) {
      throw Exception('โหลดข้อมูลตลาดไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createListing(dynamic listing) async {
    // Convert old listing format to new TradingRecord
    final record = TradingRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'sell',
      itemName: listing.toString(),
      category: 'livestock',
      quantity: 1,
      pricePerUnit: 0.0,
      totalAmount: 0.0,
      date: DateTime.now(),
      buyerSeller: 'Unknown',
      status: 'active',
      notes: null,
    );
    await addTradingRecord(record);
  }

  // Market filtering and sorting methods
  List<Map<String, dynamic>> getFilteredListings(String category, String sortBy) {
    var filtered = _marketListings;
    
    // Filter by category
    if (category != 'ทั้งหมด') {
      filtered = filtered.where((listing) => listing['category'] == category).toList();
    }
    
    // Sort listings
    switch (sortBy) {
      case 'ราคาต่ำ-สูง':
        filtered.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'ราคาสูง-ต่ำ':
        filtered.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'ยอดนิยม':
        filtered.sort((a, b) => b['views'].compareTo(a['views']));
        break;
      case 'ล่าสุด':
      default:
        filtered.sort((a, b) => b['posted'].compareTo(a['posted']));
        break;
    }
    
    return filtered;
  }

  // Available markets for queue booking
  List<Map<String, dynamic>> get availableMarkets => [
    {
      'id': 'market1',
      'name': 'ตลาดปศุสัตว์กลาง',
      'location': 'นครราชสีมา',
      'openDays': 'จันทร์, พุธ, ศุกร์',
      'openTime': '06:00 - 16:00',
      'queueCount': 15,
      'nextSlot': DateTime.now().add(const Duration(days: 2)),
    },
    {
      'id': 'market2', 
      'name': 'ตลาดปศุสัตว์ภาคเหนือ',
      'location': 'เชียงใหม่',
      'openDays': 'อังคาร, พฤหัสบดี, เสาร์',
      'openTime': '05:30 - 15:30',
      'queueCount': 8,
      'nextSlot': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'id': 'market3',
      'name': 'ตลาดปศุสัตว์ภาคใต้',
      'location': 'สงขลา',
      'openDays': 'จันทร์, พุธ, เสาร์',
      'openTime': '06:30 - 17:00',
      'queueCount': 12,
      'nextSlot': DateTime.now().add(const Duration(days: 3)),
    },
  ];

  Future<void> bookMarketQueue(dynamic booking) async {
    // Convert booking to trading record
    final record = TradingRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'buy',
      itemName: booking.toString(),
      category: 'livestock',
      quantity: 1,
      pricePerUnit: 0.0,
      totalAmount: 0.0,
      date: DateTime.now(),
      buyerSeller: 'Unknown',
      status: 'pending',
      notes: 'Market queue booking',
    );
    await addTradingRecord(record);
  }

  Future<void> updateListing(dynamic listing) async {
    // Placeholder for updating listing
    notifyListeners();
  }

  Future<void> deleteListing(String id) async {
    await deleteTradingRecord(id);
  }

  List<dynamic> get myListings => _tradingRecords;

  // Additional methods for TradingListScreen
  double getTotalSales() => totalSales;
  double getTotalPurchases() => totalPurchases;
  int getTotalTransactions() => totalTradingRecords;
}
