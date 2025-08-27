import 'package:flutter/foundation.dart';

class FarmProvider with ChangeNotifier {
  int _totalAnimals = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  bool _isLoading = false;

  int get totalAnimals => _totalAnimals;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get netProfit => _monthlyIncome - _monthlyExpense;
  bool get isLoading => _isLoading;

  Future<void> loadFarms(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load sample data instead
      _totalAnimals = 125;
      _monthlyIncome = 45000;
      _monthlyExpense = 28000;
    } catch (e) {
      throw Exception('โหลดข้อมูลฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loadSampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _totalAnimals = 125;
      _monthlyIncome = 45000;
      _monthlyExpense = 28000;
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
