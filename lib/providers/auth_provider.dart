import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm.dart';

class AuthProvider with ChangeNotifier {
  Farmer? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  Farmer? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> login(String phoneNumber, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      _currentUser = Farmer(
        id: '1',
        prefix: 'นาย',
        firstName: 'สมชาย',
        lastName: 'ใจดี',
        idCard: '1234567890123',
        phoneNumber: phoneNumber,
        email: 'somchai@example.com',
        address: '123 หมู่ 5',
        tambon: 'เนินสง่า',
        amphoe: 'เนินสง่า',
        province: 'ชัยภูมิ',
        occupation: 'เกษตรกร',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setBool('is_authenticated', true);
      
    } catch (e) {
      throw Exception('เข้าสู่ระบบไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('is_authenticated') ?? false;
    final userId = prefs.getString('user_id');
    
    if (isAuth && userId != null) {
      // Load user data
      _currentUser = Farmer(
        id: userId,
        prefix: 'นาย',
        firstName: 'สมชาย',
        lastName: 'ใจดี',
        idCard: '1234567890123',
        phoneNumber: '0812345678',
        email: 'somchai@example.com',
        address: '123 หมู่ 5',
        tambon: 'เนินสง่า',
        amphoe: 'เนินสง่า',
        province: 'ชัยภูมิ',
        occupation: 'เกษตรกร',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;
    }
    
    notifyListeners();
  }

  Future<void> register({
    required String prefix,
    required String firstName,
    required String lastName,
    required String idCard,
    required String phoneNumber,
    required String address,
    required String tambon,
    required String amphoe,
    required String province,
    String? email,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = Farmer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prefix: prefix,
        firstName: firstName,
        lastName: lastName,
        idCard: idCard,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        tambon: tambon,
        amphoe: amphoe,
        province: province,
        occupation: 'เกษตรกร',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id);
      await prefs.setBool('is_authenticated', true);
      
    } catch (e) {
      throw Exception('ลงทะเบียนไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
