import 'package:flutter/foundation.dart';
import '../models/trading.dart';
import '../models/trading_record.dart' as old_trading;
import '../models/livestock.dart';
import '../services/trading_service.dart';

/// Provider สำหรับจัดการระบบตลาดซื้อขาย - เชื่อมต่อ Firestore
class TradingProvider with ChangeNotifier {
  final TradingService _tradingService = TradingService();
  
  // State
  List<MarketListing> _marketListings = [];
  List<MarketListing> _myListings = [];
  List<Map<String, dynamic>> _availableMarkets = [];
  bool _isLoading = false;
  String? _error;
  String? _currentFarmId;

  // Getters
  List<MarketListing> get marketListings => _marketListings;
  List<MarketListing> get myListings => _myListings;
  List<Map<String, dynamic>> get availableMarkets => _availableMarkets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// ตั้งค่า Farm ID ปัจจุบัน
  void setCurrentFarmId(String farmId) {
    _currentFarmId = farmId;
    notifyListeners();
  }

  /// ✅ โหลดรายการประกาศขายจาก Firestore
  Future<void> loadMarketListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Loading market listings from Firestore...');
      _marketListings = await _tradingService.getMarketListings();
      print('✅ Loaded ${_marketListings.length} listings from Firestore');
      
      // 🔍 DEBUG: Check images for each listing
      for (var listing in _marketListings) {
        print('🔍 Listing ${listing.id}:');
        print('   - livestockId: ${listing.livestockId}');
        print('   - images: ${listing.images}');
        print('   - images.length: ${listing.images.length}');
      }
      
      // Load my listings if farmId is set
      if (_currentFarmId != null) {
        _myListings = await _tradingService.getMyListings(_currentFarmId!);
        print('✅ Loaded ${_myListings.length} my listings for farmId: $_currentFarmId');
      } else {
        print('⚠️ farmId not set, skipping my listings');
        _myListings = [];
      }
      
      // Load available markets
      _availableMarkets = await _tradingService.getAvailableMarkets();
      print('✅ Loaded ${_availableMarkets.length} markets');
      
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading market listings: $e');
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// ✅ สร้างประกาศขายใหม่
  Future<void> createListing(MarketListing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Creating new listing...');
      final id = await _tradingService.createListing(listing);
      print('✅ Created listing: $id');
      
      // Reload listings
      await loadMarketListings();
      
    } catch (e) {
      _error = e.toString();
      print('❌ Error creating listing: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// ✅ อัปเดตประกาศขาย
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    try {
      print('📝 Updating listing: $id');
      await _tradingService.updateListing(id, data);
      print('✅ Updated listing');
      
      // Reload listings
      await loadMarketListings();
      
    } catch (e) {
      print('❌ Error updating listing: $e');
      rethrow;
    }
  }
  
  /// ✅ ลบประกาศขาย
  Future<void> deleteListing(String id) async {
    try {
      print('🗑️ Deleting listing: $id');
      await _tradingService.deleteListing(id);
      print('✅ Deleted listing');
      
      // Reload listings
      await loadMarketListings();
      
    } catch (e) {
      print('❌ Error deleting listing: $e');
      rethrow;
    }
  }
  
  /// เพิ่มจำนวนการดู
  Future<void> incrementViewCount(String listingId) async {
    try {
      await _tradingService.incrementViewCount(listingId);
    } catch (e) {
      print('❌ Error incrementing view count: $e');
    }
  }
  
  /// ✅ จองคิวตลาด
  Future<void> bookMarketQueue(MarketBooking booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📅 Booking market queue...');
      final id = await _tradingService.bookMarketQueue(booking);
      print('✅ Booked queue: $id');
      
    } catch (e) {
      _error = e.toString();
      print('❌ Error booking queue: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// กรองรายการตามหมวดหมู่และเรียงลำดับ
  /// Requires LivestockProvider to get livestock type for accurate filtering
  List<MarketListing> getFilteredListings(
    String category, 
    String sortBy,
    List<Livestock> allLivestock, // Pass from LivestockProvider
    {String searchQuery = ''}  // ✅ เพิ่ม searchQuery parameter
  ) {
    print('🔍 getFilteredListings - Category: $category, Search: "$searchQuery", Total: ${_marketListings.length}');
    
    var filtered = List<MarketListing>.from(_marketListings);
    
    // ✅ Filter by search query FIRST (ถ้ามี)
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filtered = filtered.where((listing) {
        final livestockId = listing.livestockId.toLowerCase();
        final priceStr = listing.askingPrice.toString();
        final description = listing.description?.toLowerCase() ?? '';
        final title = listing.shareTitle?.toLowerCase() ?? '';
        final tags = listing.shareTags?.map((t) => t.toLowerCase()).join(' ') ?? '';
        final farmId = listing.farmId.toLowerCase();
        
        // Get livestock type
        Livestock? livestock;
        try {
          livestock = allLivestock.firstWhere((l) => l.id == listing.livestockId);
        } catch (e) {
          livestock = null;
        }
        final livestockType = livestock?.type.displayName.toLowerCase() ?? '';
        
        // Combine all searchable text
        final searchText = '$livestockId $description $title $tags $farmId $livestockType';
        
        // Check if query is a category keyword (โค, สุกร, etc.)
        final isCategoryKeyword = ['โค', 'กระบือ', 'สุกร', 'ไก่', 'เป็ด', 'แพะ', 'แกะ'].contains(query);
        
        if (isCategoryKeyword) {
          // Use category matching for better results
          return _matchCategoryInText(searchText, query);
        } else {
          // Simple text search
          return livestockId.contains(query) ||
                 priceStr.contains(query) ||
                 description.contains(query) ||
                 title.contains(query) ||
                 tags.contains(query) ||
                 livestockType.contains(query) ||
                 farmId.contains(query);
        }
      }).toList();
      
      print('✅ Search filtered: ${filtered.length} items');
    }
    
    // Filter by category based on listing description/tags AND livestock type
    if (category != 'ทั้งหมด') {
      filtered = filtered.where((listing) {
        // Try multiple matching strategies
        final livestockId = listing.livestockId.toLowerCase();
        final description = listing.description?.toLowerCase() ?? '';
        final title = listing.shareTitle?.toLowerCase() ?? '';
        final tags = listing.shareTags?.map((t) => t.toLowerCase()).join(' ') ?? '';
        
        // Get livestock type from provider
        Livestock? livestock;
        try {
          livestock = allLivestock.firstWhere(
            (l) => l.id == listing.livestockId,
          );
        } catch (e) {
          livestock = null;
        }
        final livestockType = livestock?.type.displayName.toLowerCase() ?? '';
        
        // Combine all searchable text INCLUDING livestock type
        final searchText = '$livestockId $description $title $tags $livestockType';
        
        // Check if category matches
        bool match = _matchCategoryInText(searchText, category);
        
        if (match) {
          print('  ✅ Match: ${listing.shareTitle ?? livestockId}');
          print('     LivestockType: $livestockType');
          print('     SearchText: $searchText');
        }
        return match;
      }).toList();
      
      print('✅ Filtered "$category": ${filtered.length} items');
    }
    
    // Sort listings
    _sortListings(filtered, sortBy);
    
    return filtered;
  }
  
  /// Helper method to match category keywords in text (description, title, tags)
  bool _matchCategoryInText(String searchText, String category) {
    // Map category names to multiple keywords for flexible matching
    const categoryMap = {
      'โค': ['cow', 'cattle', 'beef', 'dairy', 'โค', 'โคเนื้อ', 'โคนม', 'วัว'],
      'กระบือ': ['buffalo', 'buf', 'กระบือ', 'ควาย'],
      'สุกร': ['pig', 'swine', 'pork', 'สุกร', 'หมู'],
      'ไก่': ['chk', 'chicken', 'ไก่', 'ไก่เนื้อ', 'ไก่ไข่', 'boiler', 'layer'],
      'เป็ด': ['duck', 'เป็ด', 'เป็ดเทศ'],
      'แพะ': ['goat', 'แพะ', 'แพะเนื้อ', 'แพะนม'],
      'แกะ': ['sheep', 'แกะ', 'แกะเนื้อ'],
    };
    
    // Conflicting keywords that should exclude a match
    const conflictMap = {
      'กระบือ': ['cow', 'cattle', 'โค', 'วัว'], // If cattle appears, not buffalo
      'โค': ['buffalo', 'buf', 'กระบือ'], // If buffalo appears, not cattle
    };
    
    final keywords = categoryMap[category] ?? [category];
    final conflicts = conflictMap[category] ?? [];
    final searchLower = searchText.toLowerCase();
    
    // Check for conflicting keywords first
    for (final conflict in conflicts) {
      if (searchLower.contains(conflict.toLowerCase())) {
        return false; // Exclude if conflicting keyword found
      }
    }
    
    // Check if any keyword appears in the search text
    for (final keyword in keywords) {
      if (searchLower.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }
  
  void _sortListings(List<MarketListing> filtered, String sortBy) {
    // Sort listings
    switch (sortBy) {
      case 'ราคาต่ำ-สูง':
        filtered.sort((a, b) => a.askingPrice.compareTo(b.askingPrice));
        break;
      case 'ราคาสูง-ต่ำ':
        filtered.sort((a, b) => b.askingPrice.compareTo(a.askingPrice));
        break;
      case 'ยอดนิยม':
        filtered.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'ล่าสุด':
      default:
        filtered.sort((a, b) => b.listedDate.compareTo(a.listedDate));
        break;
    }
  }
  
  /// ค้นหาประกาศ
  Future<void> searchListings(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _marketListings = await _tradingService.searchListings(query);
    } catch (e) {
      print('❌ Error searching listings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// ดึงสถิติตลาด
  Future<Map<String, dynamic>> getMarketStats() async {
    try {
      return await _tradingService.getMarketStats();
    } catch (e) {
      print('❌ Error getting market stats: $e');
      return {};
    }
  }
  
  /// Backward compatibility methods
  
  // For old trading_list_screen.dart - convert MarketListing to TradingRecord
  List<old_trading.TradingRecord> get tradingRecords {
    return _marketListings.map((listing) {
      return old_trading.TradingRecord(
        id: listing.id,
        type: 'sell',
        itemName: 'ปศุสัตว์ #${listing.livestockId}',
        category: 'livestock',
        quantity: 1,
        pricePerUnit: listing.askingPrice,
        totalAmount: listing.askingPrice,
        date: listing.listedDate,
        buyerSeller: 'ฟาร์ม ${listing.farmId}',
        status: listing.status == 'active' ? 'pending' : listing.status,
        notes: listing.description,
      );
    }).toList();
  }
  
  Future<void> loadTradingRecords() async {
    await loadMarketListings();
  }
  
  double getTotalSales() {
    return _marketListings
        .where((l) => l.status == 'sold')
        .fold(0.0, (sum, l) => sum + l.askingPrice);
  }
  
  double getTotalPurchases() {
    return 0.0; // Not tracking purchases separately yet
  }
  
  int getTotalTransactions() {
    return _marketListings.where((l) => l.status == 'sold').length;
  }
  
  /// Seed sample data for testing
  Future<void> seedSampleData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🌱 Seeding sample data...');
      await _tradingService.seedSampleListings();
      print('✅ Sample data seeded');
      
      // Reload listings
      await loadMarketListings();
      
    } catch (e) {
      _error = e.toString();
      print('❌ Error seeding data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
