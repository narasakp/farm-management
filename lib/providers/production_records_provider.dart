import 'package:flutter/foundation.dart';
import '../models/production_record.dart';
import '../services/production_service.dart';

/// Production Records Provider - Connected to real API
class ProductionRecordsProvider with ChangeNotifier {
  final ProductionService _service = ProductionService();
  
  List<ProductionRecord> _records = [];
  List<ProductionStatistics> _statistics = [];
  bool _isLoading = false;
  String? _error;

  List<ProductionRecord> get records => _records;
  List<ProductionStatistics> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Create production record
  Future<bool> createRecord(ProductionRecord record) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.createRecord(record);
      _records.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load records for livestock
  Future<void> loadRecords(
    String livestockId, {
    String? startDate,
    String? endDate,
    String? productionType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getRecords(
        livestockId,
        startDate: startDate,
        endDate: endDate,
        productionType: productionType,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load statistics
  Future<void> loadStatistics(
    String livestockId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      _statistics = await _service.getStatistics(
        livestockId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update record
  Future<bool> updateRecord(
    int id, {
    DateTime? productionDate,
    double? quantity,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateRecord(
        id,
        productionDate: productionDate,
        quantity: quantity,
        notes: notes,
      );
      
      // Update local list
      final index = _records.indexWhere((r) => r.id == id);
      if (index != -1) {
        _records[index] = _records[index].copyWith(
          productionDate: productionDate,
          quantity: quantity,
          notes: notes,
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete record
  Future<bool> deleteRecord(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteRecord(id);
      _records.removeWhere((r) => r.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get records by type
  List<ProductionRecord> getRecordsByType(ProductionType type) {
    return _records.where((r) => r.productionType == type).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _records = [];
    _statistics = [];
    _error = null;
    notifyListeners();
  }
}
