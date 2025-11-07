import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  /// Get current user profile
  static Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['user'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String email,
    required String displayName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'displayName': displayName,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'อัปเดตโปรไฟล์สำเร็จ',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'เกิดข้อผิดพลาดในการอัปเดตโปรไฟล์',
        };
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }

  /// Upload avatar (Base64)
  static Future<Map<String, dynamic>> uploadAvatar({
    required String token,
    required String avatarBase64,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/upload-avatar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'avatarBase64': avatarBase64,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'อัปเดตรูปโปรไฟล์สำเร็จ',
          'avatarUrl': data['avatarUrl'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'เกิดข้อผิดพลาดในการอัพโหลดรูปภาพ',
        };
      }
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'เปลี่ยนรหัสผ่านสำเร็จ',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน',
        };
      }
    } catch (e) {
      print('❌ Error changing password: $e');
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }
}
