import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/livestock_survey_detailed.dart';

class LivestockSurveyService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // สำหรับเก็บ JWT Token
  static String? _accessToken;
  
  static void setAccessToken(String token) {
    _accessToken = token;
  }
  
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  // สร้างข้อมูลสำรวจใหม่
  static Future<Map<String, dynamic>> createSurvey(LivestockSurveyDetailed survey) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/surveys'),
        headers: _headers,
        body: jsonEncode(survey.toApiJson()),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'surveyId': data['surveyId'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  // ดึงรายการข้อมูลสำรวจ
  static Future<Map<String, dynamic>> getSurveys({
    int page = 1,
    int limit = 10,
    String? animalType,
    String? surveyorId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (animalType != null) queryParams['animal_type'] = animalType;
      if (surveyorId != null) queryParams['surveyor_id'] = surveyorId;
      
      final uri = Uri.parse('$baseUrl/surveys').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final surveys = (data['data'] as List)
            .map((json) => LivestockSurveyDetailed.fromJson(json))
            .toList();
            
        return {
          'success': true,
          'surveys': surveys,
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'เกิดข้อผิดพลาดในการดึงข้อมูล',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  // ดึงข้อมูลสำรวจรายการเดียว
  static Future<Map<String, dynamic>> getSurvey(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'survey': LivestockSurveyDetailed.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'ไม่พบข้อมูลสำรวจ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  // อัปเดตข้อมูลสำรวจ
  static Future<Map<String, dynamic>> updateSurvey(String id, LivestockSurveyDetailed survey) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: _headers,
        body: jsonEncode(survey.toApiJson()),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'เกิดข้อผิดพลาดในการแก้ไขข้อมูล',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  // ลบข้อมูลสำรวจ
  static Future<Map<String, dynamic>> deleteSurvey(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/surveys/$id'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'เกิดข้อผิดพลาดในการลบข้อมูล',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  // ดึงสถิติข้อมูลสำรวจ
  static Future<Map<String, dynamic>> getSurveyStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surveys/stats/summary'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'stats': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'เกิดข้อผิดพลาดในการดึงสถิติ',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้: $e',
      };
    }
  }

  // ตรวจสอบสถานะการเชื่อมต่อ
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ฟังก์ชันช่วยสำหรับจัดการ Error
  static String getErrorMessage(dynamic error) {
    if (error is Map<String, dynamic>) {
      return error['message'] ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
    }
    return error.toString();
  }
}

// Extension สำหรับ HTTP Response
extension HttpResponseExtension on http.Response {
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  
  Map<String, dynamic> get jsonData {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      return {'error': 'Invalid JSON response'};
    }
  }
}
