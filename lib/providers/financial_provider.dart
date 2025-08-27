import 'package:flutter/foundation.dart';

class FinancialProvider with ChangeNotifier {
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;

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
