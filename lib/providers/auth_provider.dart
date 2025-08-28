import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  
  User({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });
  
  String get fullName => '$firstName $lastName';
}

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  String? _savedPhoneNumber;
  
  String? get savedPhoneNumber => _savedPhoneNumber;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _savedPhoneNumber = prefs.getString('saved_phone_number');
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // For demo purposes, accept any phone number with password "123456"
      if (password == "123456") {
        _isLoggedIn = true;
        _currentUser = User(
          phoneNumber: phoneNumber,
          firstName: 'เกษตรกร',
          lastName: 'ตัวอย่าง',
        );

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_phone', phoneNumber);
        await prefs.setString('saved_phone_number', phoneNumber);
        _savedPhoneNumber = phoneNumber;
        
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user_phone');
      
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
