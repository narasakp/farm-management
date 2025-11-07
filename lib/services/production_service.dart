import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/production_record.dart';
import 'production_auth_service.dart';

class ProductionService {
  final String baseUrl = 'http://localhost:3000/api';
  final ProductionAuthService _authService = ProductionAuthService();

  /// Get auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Create production record
  Future<ProductionRecord> createRecord(ProductionRecord record) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/production-records'),
      headers: headers,
      body: jsonEncode(record.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ProductionRecord.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create production record');
    }
  }

  /// Get production records by livestock ID
  Future<List<ProductionRecord>> getRecords(
    String livestockId, {
    String? startDate,
    String? endDate,
    String? productionType,
  }) async {
    final headers = await _getHeaders();
    
    var url = '$baseUrl/production-records/livestock/$livestockId';
    final queryParams = <String, String>{};
    
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (productionType != null) queryParams['productionType'] = productionType;
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> recordsJson = data['data'];
      return recordsJson.map((json) => ProductionRecord.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch production records');
    }
  }

  /// Get production statistics
  Future<List<ProductionStatistics>> getStatistics(
    String livestockId, {
    String? startDate,
    String? endDate,
  }) async {
    final headers = await _getHeaders();
    
    var url = '$baseUrl/production-records/livestock/$livestockId/statistics';
    final queryParams = <String, String>{};
    
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> statsJson = data['data'];
      return statsJson.map((json) => ProductionStatistics.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch statistics');
    }
  }

  /// Update production record
  Future<void> updateRecord(int id, {
    DateTime? productionDate,
    double? quantity,
    String? notes,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{};
    
    if (productionDate != null) {
      body['productionDate'] = productionDate.toIso8601String().split('T')[0];
    }
    if (quantity != null) body['quantity'] = quantity;
    if (notes != null) body['notes'] = notes;

    final response = await http.put(
      Uri.parse('$baseUrl/production-records/$id'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update production record');
    }
  }

  /// Delete production record
  Future<void> deleteRecord(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/production-records/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete production record');
    }
  }
}
