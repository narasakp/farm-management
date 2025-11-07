import 'package:flutter/foundation.dart';
import '../models/market.dart';
import '../services/market_service.dart';

/// Provider สำหรับจัดการ state ของตลาดนัด
class MarketProvider with ChangeNotifier {
  final MarketService _marketService = MarketService();

  List<Market> _markets = [];
  Market? _selectedMarket;
  bool _isLoading = false;
  String? _error;
  String _selectedLivestockFilter = 'ทั้งหมด';

  // Getters
  List<Market> get markets => _markets;
  Market? get selectedMarket => _selectedMarket;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedLivestockFilter => _selectedLivestockFilter;

  /// ดึงรายการตลาดทั้งหมด
  Future<void> loadMarkets({bool activeOnly = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Loading markets...');
      _markets = await _marketService.getMarkets(activeOnly: activeOnly);
      print('✅ Loaded ${_markets.length} markets');
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading markets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// เลือกตลาด
  Future<void> selectMarket(String marketId) async {
    try {
      print('📍 Selecting market: $marketId');
      _selectedMarket = await _marketService.getMarketById(marketId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('❌ Error selecting market: $e');
      notifyListeners();
    }
  }

  /// เคลียร์การเลือก
  void clearSelection() {
    _selectedMarket = null;
    notifyListeners();
  }

  /// กรองตามประเภทสัตว์
  void filterByLivestock(String livestockType) {
    _selectedLivestockFilter = livestockType;
    notifyListeners();
  }

  /// รายการตลาดที่กรองแล้ว
  List<Market> get filteredMarkets {
    if (_selectedLivestockFilter == 'ทั้งหมด') {
      return _markets;
    }

    return _markets.where((market) {
      return market.zones.any((zone) => 
        zone.livestockType.toLowerCase() == _selectedLivestockFilter.toLowerCase() && 
        zone.isActive
      );
    }).toList();
  }

  /// ตรวจสอบคิวว่าง
  Future<int> checkAvailableSlots(
    String marketId,
    String zoneId,
    DateTime date,
    String timeSlot,
  ) async {
    try {
      return await _marketService.getAvailableSlots(
        marketId,
        zoneId,
        date,
        timeSlot,
      );
    } catch (e) {
      print('❌ Error checking slots: $e');
      return 0;
    }
  }

  /// สร้างตลาดใหม่ (Admin)
  Future<bool> createMarket(Market market) async {
    try {
      await _marketService.createMarket(market);
      await loadMarkets(); // Reload
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// อัปเดตตลาด (Admin)
  Future<bool> updateMarket(Market market) async {
    try {
      await _marketService.updateMarket(market);
      await loadMarkets(); // Reload
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// ลบตลาด (Admin)
  Future<bool> deleteMarket(String marketId) async {
    try {
      await _marketService.deleteMarket(marketId);
      await loadMarkets(); // Reload
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
