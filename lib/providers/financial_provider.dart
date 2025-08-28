import 'package:flutter/foundation.dart';

class FinancialProvider with ChangeNotifier {
  bool _isLoading = false;
  double _totalIncome = 45000;
  double _totalExpense = 28000;
  
  bool get isLoading => _isLoading;
  
  double getTotalIncome(String farmId) => _totalIncome;
  double getTotalExpense(String farmId) => _totalExpense;

  Future<void> loadSampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('Error loading financial data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
