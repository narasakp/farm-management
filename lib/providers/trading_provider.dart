import 'package:flutter/foundation.dart';
import '../models/trading.dart';
import '../models/livestock.dart';

class TradingProvider with ChangeNotifier {
  List<MarketListing> _marketListings = [];
  List<LivestockMarket> _availableMarkets = [];
  List<MarketBooking> _marketBookings = [];
  List<TradingRecord> _tradingRecords = [];
  bool _isLoading = false;

  List<MarketListing> get marketListings => _marketListings;
  List<LivestockMarket> get availableMarkets => _availableMarkets;
  List<MarketBooking> get marketBookings => _marketBookings;
  List<TradingRecord> get tradingRecords => _tradingRecords;
  bool get isLoading => _isLoading;

  List<MarketListing> get myListings {
    // TODO: Filter by current user's farm
    return _marketListings.where((listing) => listing.farmId == 'current_user_farm').toList();
  }

  List<MarketListing> getFilteredListings(String category, String sortBy) {
    var filtered = _marketListings.where((listing) => listing.status == 'active');
    
    // Filter by category
    if (category != 'ทั้งหมด') {
      // TODO: Implement category filtering based on livestock type
      // filtered = filtered.where((listing) => getAnimalType(listing.livestockId) == category);
    }
    
    var result = filtered.toList();
    
    // Sort
    switch (sortBy) {
      case 'ราคาต่ำ-สูง':
        result.sort((a, b) => a.askingPrice.compareTo(b.askingPrice));
        break;
      case 'ราคาสูง-ต่ำ':
        result.sort((a, b) => b.askingPrice.compareTo(a.askingPrice));
        break;
      case 'ยอดนิยม':
        result.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'ล่าสุด':
      default:
        result.sort((a, b) => b.listedDate.compareTo(a.listedDate));
        break;
    }
    
    return result;
  }

  Future<void> loadMarketListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _marketListings = [
        MarketListing(
          id: '1',
          farmId: 'farm1',
          livestockId: 'cattle001',
          askingPrice: 45000,
          minPrice: 40000,
          description: 'โคเนื้อพันธุ์ดี สุขภาพแข็งแรง น้ำหนัก 450 กก.',
          isNegotiable: true,
          listedDate: DateTime.now().subtract(const Duration(days: 2)),
          status: 'active',
          viewCount: 15,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        MarketListing(
          id: '2',
          farmId: 'farm2',
          livestockId: 'cattle002',
          askingPrice: 38000,
          description: 'โคนมให้ผลผลิตดี อายุ 3 ปี',
          isNegotiable: false,
          listedDate: DateTime.now().subtract(const Duration(days: 1)),
          status: 'active',
          viewCount: 8,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MarketListing(
          id: '3',
          farmId: 'current_user_farm',
          livestockId: 'pig001',
          askingPrice: 12000,
          minPrice: 10000,
          description: 'สุกรขุนพร้อมขาย น้ำหนัก 80 กก.',
          isNegotiable: true,
          listedDate: DateTime.now().subtract(const Duration(hours: 6)),
          status: 'active',
          viewCount: 3,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];

      _availableMarkets = [
        LivestockMarket(
          id: '1',
          name: 'ตลาดโค-กระบือ เนินสง่า',
          location: 'อำเภอเนินสง่า จังหวัดชัยภูมิ',
          type: 'physical',
          operatingDays: ['จันทร์', 'พุธ', 'ศุกร์'],
          operatingHours: '06:00 - 12:00',
          contactInfo: '044-123456',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        LivestockMarket(
          id: '2',
          name: 'ตลาดปศุสัตว์ออนไลน์ ชัยภูมิ',
          location: 'ออนไลน์',
          type: 'online',
          operatingDays: ['ทุกวัน'],
          operatingHours: '24 ชั่วโมง',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ];

    } catch (e) {
      debugPrint('Error loading market listings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createListing(MarketListing listing) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _marketListings.add(listing);
    } catch (e) {
      throw Exception('สร้างประกาศไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateListing(MarketListing listing) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _marketListings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _marketListings[index] = listing;
      }
    } catch (e) {
      throw Exception('อัปเดตประกาศไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String listingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _marketListings.removeWhere((listing) => listing.id == listingId);
    } catch (e) {
      throw Exception('ลบประกาศไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookMarketQueue(MarketBooking booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _marketBookings.add(booking);
    } catch (e) {
      throw Exception('จองคิวไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordTrade(TradingRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _tradingRecords.add(record);
    } catch (e) {
      throw Exception('บันทึกการซื้อขายไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void incrementViewCount(String listingId) {
    final index = _marketListings.indexWhere((listing) => listing.id == listingId);
    if (index != -1) {
      final listing = _marketListings[index];
      _marketListings[index] = MarketListing(
        id: listing.id,
        farmId: listing.farmId,
        livestockId: listing.livestockId,
        askingPrice: listing.askingPrice,
        minPrice: listing.minPrice,
        description: listing.description,
        images: listing.images,
        isNegotiable: listing.isNegotiable,
        listedDate: listing.listedDate,
        expiryDate: listing.expiryDate,
        status: listing.status,
        viewCount: listing.viewCount + 1,
        createdAt: listing.createdAt,
      );
      notifyListeners();
    }
  }

  List<TradingRecord> getTradingHistory(String farmId) {
    return _tradingRecords.where((record) => record.farmId == farmId).toList();
  }

  double getTotalRevenue(String farmId, DateTime startDate, DateTime endDate) {
    return _tradingRecords
        .where((record) => 
            record.farmId == farmId &&
            record.transactionType == 'sell' &&
            record.transactionDate.isAfter(startDate) &&
            record.transactionDate.isBefore(endDate))
        .fold(0.0, (sum, record) => sum + record.price);
  }

  double getTotalExpenses(String farmId, DateTime startDate, DateTime endDate) {
    return _tradingRecords
        .where((record) => 
            record.farmId == farmId &&
            record.transactionType == 'buy' &&
            record.transactionDate.isAfter(startDate) &&
            record.transactionDate.isBefore(endDate))
        .fold(0.0, (sum, record) => sum + record.price);
  }
}
