import 'dart:convert';
import 'package:http/http.dart' as http;

/// Privacy Service
/// จัดการการเข้าถึงข้อมูลอ่อนไหวตาม PDPA
class PrivacyService {
  static const String baseUrl = 'http://localhost:3000/api/privacy';

  /// ขอดูข้อมูลเต็ม (Click-to-Reveal)
  /// สำหรับ OFFICER, ADMIN
  static Future<Map<String, dynamic>?> clickToReveal({
    required String targetUserId,
    required String reason,
    required String token,
    List<String>? accessFields, // เช่น ['id_card'] หรือ ['phone']
  }) async {
    try {
      print('🔍 Click-to-Reveal: User $targetUserId');
      print('📝 Reason: $reason');
      print('📋 Access Fields: $accessFields');

      final response = await http.post(
        Uri.parse('$baseUrl/click-to-reveal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'target_user_id': targetUserId,
          'reason': reason,
          'access_fields': accessFields,
        }),
      );

      print('📡 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Temporary Access Granted');
          print('⏰ Expires: ${data['expires_at']}');
          return data;
        }
      } else if (response.statusCode == 429) {
        final data = json.decode(response.body);
        print('⚠️ Rate Limit: ${data['message']}');
        return {'error': data['message']};
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        print('❌ Forbidden: ${data['message']}');
        return {'error': data['message']};
      }

      return null;
    } catch (e) {
      print('❌ Click-to-Reveal error: $e');
      return null;
    }
  }

  /// ขอเข้าถึงฉุกเฉิน (Emergency Access)
  /// สำหรับ OFFICER, ADMIN
  static Future<Map<String, dynamic>?> emergencyAccess({
    required String targetUserId,
    required String reason,
    required String emergencyType,
    required String token,
    List<String>? accessFields,
  }) async {
    try {
      print('🚨 Emergency Access: User $targetUserId');
      print('📝 Type: $emergencyType');
      print('📝 Reason: $reason');
      print('📋 Access Fields: $accessFields');

      final response = await http.post(
        Uri.parse('$baseUrl/emergency-access'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'target_user_id': targetUserId,
          'reason': reason,
          'emergency_type': emergencyType,
          'access_fields': accessFields,
        }),
      );

      print('📡 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Emergency Access Granted');
          print('⏰ Expires: ${data['expires_at']}');
          return data;
        }
      }

      return null;
    } catch (e) {
      print('❌ Emergency Access error: $e');
      return null;
    }
  }

  /// ขอให้เกษตรกรโทรกลับ (Request Callback)
  /// สำหรับ OFFICER, ADMIN, RESEARCHER
  static Future<Map<String, dynamic>?> requestCallback({
    required String targetUserId,
    required String message,
    required String token,
  }) async {
    try {
      print('🟢 Request Callback: User $targetUserId');
      print('📝 Message: $message');

      final response = await http.post(
        Uri.parse('$baseUrl/request-callback'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'target_user_id': targetUserId,
          'message': message,
        }),
      );

      print('📡 Response: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Callback Requested');
          return data;
        } else {
          print('⚠️ Success = false: ${data['message']}');
          return data; // Return ข้อมูลเพื่อแสดง error message
        }
      } else if (response.statusCode == 403) {
        print('🚫 Forbidden: No permission');
        return {'success': false, 'message': 'ไม่มีสิทธิ์ใช้งาน'};
      } else if (response.statusCode == 404) {
        print('🔍 Not found');
        return {'success': false, 'message': 'ไม่พบข้อมูล'};
      }

      return {'success': false, 'message': 'เกิดข้อผิดพลาด (${response.statusCode})'};
    } catch (e) {
      print('❌ Request Callback error: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: $e'};
    }
  }

  /// ดึงข้อมูลเกษตรกร (พร้อม Masking)
  static Future<Map<String, dynamic>?> getFarmerData({
    required String farmerId,
    required String token,
  }) async {
    try {
      print('👤 Get Farmer Data: $farmerId');

      final response = await http.get(
        Uri.parse('$baseUrl/farmer/$farmerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Farmer Data Retrieved');
          
          final farmerData = data['data'];
          print('📋 Masked: ${farmerData['_masked']}');
          print('🔍 Has _unmasked_data: ${farmerData['_unmasked_data'] != null}');
          print('🔍 _unmasked_data content: ${farmerData['_unmasked_data']}');
          
          if (farmerData['_temporary_access'] != null) {
            print('⏰ Temporary Access Active');
            print('   Expires: ${farmerData['_temporary_access']['expires_at']}');
          }
          
          return data;
        }
      }

      return null;
    } catch (e) {
      print('❌ Get Farmer Data error: $e');
      return null;
    }
  }

  /// ยกเลิก Temporary Access
  static Future<bool> revokeAccess({
    required String accessId,
    required String token,
  }) async {
    try {
      print('🔒 Revoke Access: $accessId');

      final response = await http.post(
        Uri.parse('$baseUrl/revoke-access'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'access_id': accessId,
        }),
      );

      print('📡 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Access Revoked');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Revoke Access error: $e');
      return false;
    }
  }
}
