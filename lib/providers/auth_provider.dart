import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/production_auth_service.dart';

/// Legacy AuthProvider - Wrapper สำหรับ backward compatibility
/// ใช้ ProductionAuthService เป็น backend จริง
class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticated => _isLoggedIn; // Alias for backward compatibility
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  String? _savedPhoneNumber;
  
  String? get savedPhoneNumber => _savedPhoneNumber;

  // Constructor - auto check auth status
  AuthProvider() {
    _initializeAuthStatus();
  }

  Future<void> _initializeAuthStatus() async {
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check ProductionAuthService tokens
      final authService = ProductionAuthService();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (isLoggedIn) {
        // Validate token
        final isValid = await authService.validateToken();
        if (isValid) {
          _isLoggedIn = true;
          final userData = await authService.getCurrentUser();
          if (userData != null) {
            // Debug: พิมพ์ userData
            debugPrint('🔍 DEBUG AuthProvider - userData keys: ${userData.keys}');
            debugPrint('🔍 DEBUG AuthProvider - displayName: ${userData['displayName']}');
            debugPrint('🔍 DEBUG AuthProvider - display_name: ${userData['display_name']}');
            
            // ใช้ displayName หรือ display_name (รองรับทั้งสองแบบ)
            final displayName = userData['displayName']?.toString() ?? 
                               userData['display_name']?.toString() ?? '';
            
            debugPrint('🔍 DEBUG AuthProvider - final displayName: $displayName');
            
            _currentUser = User(
              id: userData['id']?.toString() ?? '',
              username: userData['username']?.toString() ?? 'unknown_user',
              phoneNumber: userData['phone']?.toString(),
              firstName: displayName,
              lastName: '',
              email: userData['email']?.toString() ?? '',
              avatarUrl: userData['photoUrl']?.toString() ?? userData['photo_url']?.toString(),
              role: userData['role']?.toString(),  // 🆕 User role
            );
            
            debugPrint('🔍 DEBUG AuthProvider - User created with firstName: ${_currentUser?.firstName}');
          }
        } else {
          await authService.logout();
          _isLoggedIn = false;
          _currentUser = null;
        }
      } else {
        _isLoggedIn = false;
        _currentUser = null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      _savedPhoneNumber = prefs.getString('saved_phone_number');
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final authService = ProductionAuthService();
      final result = await authService.login(username, password);
      
      if (result['success'] == true) {
        _isLoggedIn = true;
        _currentUser = User(
          id: result['userId']?.toString() ?? username,
          username: username,
          phoneNumber: result['email']?.toString() ?? '',
          firstName: result['displayName']?.toString() ?? username,
          lastName: '',
          email: result['email']?.toString() ?? '',
          role: result['role']?.toString(),  // 🆕 User role
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_phone', username);
        
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

  Future<void> setLoggedIn(bool value, {String? email, String? name, String? role}) async {
    _isLoggedIn = value;
    
    if (value && email != null) {
      _currentUser = User(
        id: email,
        username: email.split('@')[0],
        phoneNumber: email,
        firstName: name ?? email.split('@')[0],
        lastName: '',
        email: email,
        role: role,  // 🆕 User role
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_phone', email);
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      debugPrint('🔓 Logout started...');
      final authService = ProductionAuthService();
      await authService.logout();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user_phone');
      await prefs.clear();
      
      _isLoggedIn = false;
      _currentUser = null;
      debugPrint('🔓 Logout completed. isLoggedIn: $_isLoggedIn');
      notifyListeners();
      debugPrint('🔓 notifyListeners() called');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
