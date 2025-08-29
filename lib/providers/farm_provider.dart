import 'package:flutter/foundation.dart';

class Farm {
  final String id;
  final String name;
  final String location;
  final int totalAnimals;
  final double monthlyIncome;
  final double monthlyExpense;
  
  Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.totalAnimals,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });
  
  double get netProfit => monthlyIncome - monthlyExpense;
}

class FarmProvider with ChangeNotifier {
  List<Farm> _farms = [];
  int _totalAnimals = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  bool _isLoading = false;
  Farm? _selectedFarm;

  List<Farm> get farms => _farms;
  int get totalAnimals => _totalAnimals;
  int get totalLivestock => _totalAnimals;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get netProfit => _monthlyIncome - _monthlyExpense;
  bool get isLoading => _isLoading;
  Farm? get selectedFarm => _selectedFarm;

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
      
      _selectedFarm = Farm(
        id: '1',
        name: 'ฟาร์มตัวอย่าง',
        location: 'จังหวัดนครราชสีมา',
        totalAnimals: 125,
        monthlyIncome: 45000,
        monthlyExpense: 28000,
      );
      
      _farms = [
        _selectedFarm!,
        Farm(
          id: '2',
          name: 'ฟาร์มโคเนื้อ',
          location: 'จังหวัดขอนแก่น',
          totalAnimals: 85,
          monthlyIncome: 32000,
          monthlyExpense: 18000,
        ),
        Farm(
          id: '3',
          name: 'ฟาร์มไก่พื้นเมือง',
          location: 'จังหวัดอุบลราชธานี',
          totalAnimals: 200,
          monthlyIncome: 28000,
          monthlyExpense: 15000,
        ),
      ];
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
      
      _farms = [
        Farm(
          id: '1',
          name: 'ฟาร์มตัวอย่าง',
          location: 'จังหวัดนครราชสีมา',
          totalAnimals: 125,
          monthlyIncome: 45000,
          monthlyExpense: 28000,
        ),
        Farm(
          id: '2',
          name: 'ฟาร์มโคเนื้อ',
          location: 'จังหวัดขอนแก่น',
          totalAnimals: 85,
          monthlyIncome: 32000,
          monthlyExpense: 18000,
        ),
        Farm(
          id: '3',
          name: 'ฟาร์มไก่พื้นเมือง',
          location: 'จังหวัดอุบลราชธานี',
          totalAnimals: 200,
          monthlyIncome: 28000,
          monthlyExpense: 15000,
        ),
      ];
      
      _totalAnimals = _farms.fold(0, (sum, farm) => sum + farm.totalAnimals);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
