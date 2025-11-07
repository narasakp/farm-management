import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductionAuthService {
  static const String _baseUrl = 'http://localhost:3000/api/auth';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Check if user exists by email (for password reset)
  Future<Map<String, dynamic>> checkUserByEmail(String email) async {
    try {
      print('🔍 Checking user by email: $email');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/check-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseText = response.body;
      print('📧 Check user response: $responseText');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(responseText);
      } catch (e) {
        print('❌ JSON decode error: $e');
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาดในการตอบสนองจากเซิร์ฟเวอร์',
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่พบผู้ใช้งานในระบบ',
        };
      }
    } catch (e) {
      print('❌ Check user error: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการตรวจสอบผู้ใช้งาน: $e',
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      print('🔄 Resetting password for: $email');
      print('🔑 New password: $newPassword');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,  // Send plain password - backend will hash it
        }),
      );

      final responseText = response.body;
      print('🔄 Reset password response: $responseText');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(responseText);
      } catch (e) {
        print('❌ JSON decode error: $e');
        return {
          'success': false,
          'message': 'เกิดข้อผิดพลาดในการตอบสนองจากเซิร์ฟเวอร์',
        };
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่สามารถรีเซ็ตรหัสผ่านได้',
        };
      }
    } catch (e) {
      print('❌ Reset password error: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการรีเซ็ตรหัสผ่าน: $e',
      };
    }
  }

  // Login with username/password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔐 Production login attempt for: $username');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Version': '1.0.0',
        },
        body: jsonEncode({
          'username': username,
          'password': password,  // Send plain password - backend will hash it
          'device_info': await _getDeviceInfo(),
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout - ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success']) {
          // Store tokens securely
          await _storeTokens(data['access_token'], data['refresh_token']);
          await _storeUserData(data['user']);
          
          print('✅ Production login successful');
          return {
            'success': true,
            'userId': data['user']['id']?.toString() ?? '',
            'userRole': data['user']['role']?.toString() ?? 'user',
            'displayName': data['user']['displayName']?.toString() ?? data['user']['username']?.toString() ?? 'ผู้ใช้',
            'email': data['user']['email']?.toString() ?? '',
            'accessToken': data['access_token']?.toString() ?? '',
          };
        } else {
          print('❌ Login failed: ${data['message']}');
          return {
            'success': false,
            'error': data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
        };
      } else if (response.statusCode == 403) {
        // Account suspended - use message from backend
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'บัญชีนี้ถูกระงับการใช้งาน กรุณาติดต่อผู้ดูแลระบบ',
        };
      } else if (response.statusCode == 423) {
        // Account locked - use message from backend (includes remaining time)
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'บัญชีถูกล็อค กรุณาลองใหม่ภายหลัง',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
        };
      }
    } catch (e) {
      print('❌ Production login error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      if (e.toString().contains('timeout')) {
        return {
          'success': false,
          'error': 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง',
        };
      } else if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        return {
          'success': false,
          'error': 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
        };
      } else {
        return {
          'success': false,
          'error': 'เกิดข้อผิดพลาด: ${e.toString()}',
        };
      }
    }
  }

  // Register new user (Named Parameters - Safe from parameter order bugs)
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String displayName,
    required String role,
  }) async {
    try {
      print('📝 Production registration for: $username');
      print('📧 Email: $email');
      print('👤 Display Name: $displayName');
      print('🎭 Role: $role');
      
      // Use plain password for backend (backend will hash it)
      final requestBody = {
        'username': username,
        'password': password, // Send plain password
        'email': email,
        'display_name': displayName,
        'role': role,
      };
      
      print('📤 Sending request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Version': '1.0.0',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Production registration successful');
          return {
            'success': true,
            'message': data['message'] ?? 'สมัครสมาชิกสำเร็จ',
            'userId': data['user']?['id'],
          };
        } else {
          return {
            'success': false,
            'error': data['message'] ?? 'เกิดข้อผิดพลาดในการสร้างบัญชี',
          };
        }
      } else if (response.statusCode == 409) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'ชื่อผู้ใช้หรืออีเมลมีอยู่แล้ว',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'เกิดข้อผิดพลาดในการสร้างบัญชี',
        };
      }
    } catch (e) {
      print('❌ Production registration error: $e');
      
      String errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
      
      if (e.toString().contains('CORS')) {
        errorMessage = 'ปัญหา CORS - กรุณาตรวจสอบการตั้งค่าเซิร์ฟเวอร์';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'เซิร์ฟเวอร์ไม่ตอบสนอง - กรุณาตรวจสอบว่าเซิร์ฟเวอร์ทำงานอยู่';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'การเชื่อมต่อหมดเวลา - กรุณาลองใหม่อีกครั้ง';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'details': e.toString(),
      };
    }
  }


  // Refresh access token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) {
        return {'success': false, 'error': 'No refresh token'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeTokens(data['access_token'], data['refresh_token']);
        return {'success': true, 'access_token': data['access_token']};
      } else {
        await logout(); // Clear invalid tokens
        return {'success': false, 'error': 'Token refresh failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Token refresh error'};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null) {
        // Notify server about logout
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
      
      // Clear local storage
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Validate token with server
  Future<bool> validateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_baseUrl/validate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Try to refresh token
        final refreshResult = await refreshToken();
        return refreshResult['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _getDeviceInfo() async {
    // In production, get real device info
    return 'Flutter Web Client v1.0.0';
  }

  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  // Get authorization header for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    
    return {'Content-Type': 'application/json'};
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
