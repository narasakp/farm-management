import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchResult {
  final String id;
  final String type; // 'livestock', 'survey', 'transaction' (ไม่มี 'user', 'audit', 'auth')
  final String title;
  final String subtitle;
  final String description;
  final String? createdAt;
  final Map<String, dynamic> data;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    this.createdAt,
    required this.data,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'].toString(),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'],
      data: json['data'] ?? {},
    );
  }
}

class SearchResults {
  final List<SearchResult> livestock;
  final List<SearchResult> surveys;
  final List<SearchResult> transactions;
  final int total;

  SearchResults({
    required this.livestock,
    required this.surveys,
    required this.transactions,
    required this.total,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      livestock: (json['livestock'] as List?)
              ?.map((item) => SearchResult.fromJson(item))
              .toList() ??
          [],
      surveys: (json['surveys'] as List?)
              ?.map((item) => SearchResult.fromJson(item))
              .toList() ??
          [],
      transactions: (json['transactions'] as List?)
              ?.map((item) => SearchResult.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }

  List<SearchResult> get all {
    return [...livestock, ...surveys, ...transactions];
  }
}

class SearchService {
  static const String baseUrl = 'http://localhost:3000/api/search';

  /// ค้นหาข้อมูล
  static Future<SearchResults?> search(
    String query,
    String token, {
    String? category,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'q': query,
        if (category != null && category != 'ทั้งหมด') 'category': category,
      });

      print('🔍 Searching: $query (category: ${category ?? "all"})');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SearchResults.fromJson(data['results']);
        }
      }
      return null;
    } catch (e) {
      print('❌ Search error: $e');
      return null;
    }
  }
}
