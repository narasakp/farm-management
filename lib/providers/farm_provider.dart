import 'package:flutter/foundation.dart';
import '../models/farm.dart';

class FarmProvider with ChangeNotifier {
  List<Farm> _farms = [];
  Farm? _selectedFarm;
  bool _isLoading = false;

  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  bool get isLoading => _isLoading;

  Future<void> loadFarms(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _farms = [
        Farm(
          id: '1',
          ownerId: ownerId,
          name: 'ฟาร์มโคนมสมชาย',
          address: '123 หมู่ 5',
          tambon: 'เนินสง่า',
          amphoe: 'เนินสง่า',
          province: 'ชัยภูมิ',
          postalCode: '36130',
          latitude: 15.7167,
          longitude: 102.0333,
          areaSize: 10.5,
          farmType: 'โคนม',
          registrationNumber: 'FM001234',
          registrationDate: DateTime(2023, 1, 15),
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        Farm(
          id: '2',
          ownerId: ownerId,
          name: 'ฟาร์มไก่ไข่บ้านสวน',
          address: '456 หมู่ 3',
          tambon: 'เนินสง่า',
          amphoe: 'เนินสง่า',
          province: 'ชัยภูมิ',
          postalCode: '36130',
          latitude: 15.7200,
          longitude: 102.0400,
          areaSize: 5.2,
          farmType: 'สัตว์ปีก',
          registrationNumber: 'FM001235',
          registrationDate: DateTime(2023, 6, 20),
          createdAt: DateTime.now().subtract(const Duration(days: 200)),
          updatedAt: DateTime.now(),
        ),
      ];

      if (_farms.isNotEmpty) {
        _selectedFarm = _farms.first;
      }
    } catch (e) {
      throw Exception('โหลดข้อมูลฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFarm(Farm farm) {
    _selectedFarm = farm;
    notifyListeners();
  }

  Future<void> addFarm(Farm farm) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _farms.add(farm);
      if (_selectedFarm == null) {
        _selectedFarm = farm;
      }
    } catch (e) {
      throw Exception('เพิ่มฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFarm(Farm farm) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _farms.indexWhere((f) => f.id == farm.id);
      if (index != -1) {
        _farms[index] = farm;
        if (_selectedFarm?.id == farm.id) {
          _selectedFarm = farm;
        }
      }
    } catch (e) {
      throw Exception('อัปเดตฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFarm(String farmId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _farms.removeWhere((f) => f.id == farmId);
      if (_selectedFarm?.id == farmId) {
        _selectedFarm = _farms.isNotEmpty ? _farms.first : null;
      }
    } catch (e) {
      throw Exception('ลบฟาร์มไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
