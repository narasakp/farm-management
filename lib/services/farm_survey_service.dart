import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/survey_form.dart';

class FarmSurveyService {
  static const String baseUrl = 'http://localhost:3000/api';

  // บันทึกข้อมูลการสำรวจ
  Future<bool> submitSurvey(FarmSurvey survey) async {
    try {
      // Debug log
      if (survey.gpsLocation != null) {
        print('📍 Frontend sending GPS: ${survey.gpsLocation}');
      } else {
        print('⚠️ No GPS to send');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/farm-surveys'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': survey.id,
          'farmerId': survey.farmerId,
          'surveyorId': survey.surveyorId,
          'surveyDate': survey.surveyDate.toIso8601String(),
          'farmerInfo': {
            'title': survey.farmerInfo.title,
            'firstName': survey.farmerInfo.firstName,
            'lastName': survey.farmerInfo.lastName,
            'idCard': survey.farmerInfo.idCard,
            'phoneNumber': survey.farmerInfo.phoneNumber,
            'photoBase64': survey.farmerInfo.photoBase64,
            'address': {
              'houseNumber': survey.farmerInfo.address.houseNumber,
              'village': survey.farmerInfo.address.village,
              'moo': survey.farmerInfo.address.moo,
              'tambon': survey.farmerInfo.address.tambon,
              'amphoe': survey.farmerInfo.address.amphoe,
              'province': survey.farmerInfo.address.province,
              'postalCode': survey.farmerInfo.address.postalCode,  // ← เพิ่ม postalCode!
            },
          },
          'livestockData': survey.livestockData.map((livestock) => {
            'type': livestock.type.name, // enum name
            'ageGroup': livestock.ageGroup,
            'count': livestock.count,
            'dailyMilkProduction': livestock.dailyMilkProduction,
          }).toList(),
          'cropArea': survey.cropArea,
          'notes': survey.notes,
          'gpsLocation': survey.gpsLocation,  // ← เพิ่ม GPS!
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Survey saved successfully: ${data['surveyId']}');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Error saving survey: ${error['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Exception in submitSurvey: $e');
      return false;
    }
  }

  // ดึงรายการข้อมูลการสำรวจ
  Future<List<FarmSurvey>> getSurveys({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/farm-surveys?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final surveys = (data['data'] as List).map((json) {
          // Debug log
          if (json['farmerInfo']?['photoBase64'] != null) {
            final photoLength = (json['farmerInfo']['photoBase64'] as String).length;
            print('📸 Found photo for ${json['farmerInfo']['firstName']}: ${photoLength} chars');
          } else {
            print('⚠️ No photo for ${json['farmerInfo']['firstName']}');
          }
          return FarmSurvey.fromJson(json);
        }).toList();
        return surveys;
      } else {
        print('❌ Error fetching surveys: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception in getSurveys: $e');
      return [];
    }
  }

  // อัปเดตข้อมูลการสำรวจ
  Future<bool> updateSurvey(FarmSurvey survey) async {
    try {
      // Debug log
      if (survey.gpsLocation != null) {
        print('📍 Frontend sending GPS UPDATE: ${survey.gpsLocation}');
      } else {
        print('⚠️ No GPS to send (UPDATE)');
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/farm-surveys/${survey.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'surveyDate': survey.surveyDate.toIso8601String(),
          'farmerInfo': {
            'title': survey.farmerInfo.title,
            'firstName': survey.farmerInfo.firstName,
            'lastName': survey.farmerInfo.lastName,
            'idCard': survey.farmerInfo.idCard,
            'phoneNumber': survey.farmerInfo.phoneNumber,
            'photoBase64': survey.farmerInfo.photoBase64,
            'address': {
              'houseNumber': survey.farmerInfo.address.houseNumber,
              'village': survey.farmerInfo.address.village,
              'moo': survey.farmerInfo.address.moo,
              'tambon': survey.farmerInfo.address.tambon,
              'amphoe': survey.farmerInfo.address.amphoe,
              'province': survey.farmerInfo.address.province,
              'postalCode': survey.farmerInfo.address.postalCode,  // ← เพิ่ม postalCode!
            },
          },
          'livestockData': survey.livestockData.map((livestock) => {
            'type': livestock.type.name,
            'ageGroup': livestock.ageGroup,
            'count': livestock.count,
            'dailyMilkProduction': livestock.dailyMilkProduction,
          }).toList(),
          'cropArea': survey.cropArea,
          'notes': survey.notes,
          'gpsLocation': survey.gpsLocation,  // ← เพิ่ม GPS!
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Survey updated successfully: ${survey.id}');
        return true;
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.body}');
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'ไม่สามารถอัปเดตข้อมูลได้');
        } catch (jsonError) {
          throw Exception('เกิดข้อผิดพลาด (HTTP ${response.statusCode})');
        }
      }
    } catch (e) {
      print('❌ Exception in updateSurvey: $e');
      rethrow; // ส่ง exception ต่อไปยัง provider
    }
  }

  // ดึงสถิติปศุสัตว์จากฐานข้อมูล (สำหรับ Dashboard)
  Future<Map<String, dynamic>> getLivestockStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/livestock'),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['data'] as Map<String, dynamic>;
      } else {
        print('❌ Error fetching statistics: ${response.statusCode}');
        return {
          'totalLivestock': 0,
          'totalFarms': 0,
          'livestockByType': <String, int>{}
        };
      }
    } catch (e) {
      print('❌ Exception in getLivestockStatistics: $e');
      return {
        'totalLivestock': 0,
        'totalFarms': 0,
        'livestockByType': <String, int>{}
      };
    }
  }
}
