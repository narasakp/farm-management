import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart'; // เพิ่ม import file_picker
import '../models/feedback.dart';
import '../config/api_config.dart';

class FeedbackProvider with ChangeNotifier {
  List<Feedback> _feedbacks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Feedback> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get feedbacks by status
  List<Feedback> getFeedbacksByStatus(FeedbackStatus status) {
    return _feedbacks.where((feedback) => feedback.status == status).toList();
  }

  // Get feedbacks by type
  List<Feedback> getFeedbacksByType(FeedbackType type) {
    return _feedbacks.where((feedback) => feedback.type == type).toList();
  }

  // Get feedbacks by user
  List<Feedback> getFeedbacksByUser(String userId) {
    return _feedbacks.where((feedback) => feedback.userId == userId).toList();
  }

  // Load feedbacks from API
  Future<void> loadFeedbacks({String? userId, String? status, String? type, String? category}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final queryParams = <String, String>{};
      if (userId != null) queryParams['userId'] = userId;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback').replace(queryParameters: queryParams);
      print('🔍 [FeedbackProvider] Loading feedbacks from: $uri');
      
      final response = await http.get(uri);
      print('📡 [FeedbackProvider] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 [FeedbackProvider] Response data: ${data['success']}, items: ${data['data']?.length ?? 0}');
        
        if (data['success'] == true) {
          _feedbacks = (data['data'] as List)
              .map((item) {
                try {
                  final feedback = Feedback.fromJson(item);
                  print('📊 [FeedbackProvider] Feedback: ${feedback.subject}');
                  print('   replyCount from API: ${item['replyCount'] ?? item['reply_count']}');
                  print('   replyCount parsed: ${feedback.replyCount}');
                  return feedback;
                } catch (e) {
                  print('❌ [FeedbackProvider] Error parsing item: $item');
                  print('   Error: $e');
                  rethrow;
                }
              })
              .toList();
          print('✅ [FeedbackProvider] Loaded ${_feedbacks.length} feedbacks');
        }
      } else {
        print('❌ [FeedbackProvider] HTTP Error: ${response.statusCode}');
        _errorMessage = 'HTTP Error: ${response.statusCode}';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ [FeedbackProvider] Error loading feedbacks: $e');
      print('📋 Stack trace: $stackTrace');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload files and return URLs
  Future<List<String>> uploadFiles(List<PlatformFile> files) async {
    try {
      if (files.isEmpty) return [];
      
      print('📤 [FeedbackProvider] Uploading ${files.length} files...');
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/upload/feedback');
      final request = http.MultipartRequest('POST', uri);
      
      // Add files to request
      for (var file in files) {
        if (file.bytes != null) {
          // Web: ใช้ bytes
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              file.bytes!,
              filename: file.name,
            ),
          );
        } else if (file.path != null) {
          // Mobile: ใช้ path
          request.files.add(
            await http.MultipartFile.fromPath('files', file.path!),
          );
        }
      }
      
      print('📡 [FeedbackProvider] Sending upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 [FeedbackProvider] Upload response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['files'] != null) {
          final urls = (data['files'] as List)
              .map((file) => file['url'] as String)
              .toList();
          print('✅ [FeedbackProvider] Uploaded ${urls.length} files');
          return urls;
        }
      } else if (response.statusCode == 413) {
        final data = json.decode(response.body);
        _errorMessage = data['error'] ?? 'ไฟล์มีขนาดใหญ่เกินไป';
        print('❌ [FeedbackProvider] File too large: $_errorMessage');
      } else {
        print('❌ [FeedbackProvider] Upload failed: ${response.statusCode}');
        print('   Body: ${response.body}');
      }
      
      return [];
    } catch (e) {
      print('❌ [FeedbackProvider] Upload error: $e');
      _errorMessage = 'เกิดข้อผิดพลาดในการอัปโหลดไฟล์: $e';
      return [];
    }
  }

  // Add new feedback
  Future<bool> addFeedback(Feedback feedback) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': feedback.id,
          'userId': feedback.userId,
          'userName': feedback.userName,
          'email': feedback.email,
          'phone': feedback.phone,
          'type': feedback.type.name,
          'category': feedback.category.name,
          'subject': feedback.subject,
          'message': feedback.message,
          'rating': feedback.rating,
          'attachments': json.encode(feedback.attachments),
          'priority': feedback.priority.name,
          'status': 'pending', // ส่ง feedback ใหม่เป็น pending เสมอ
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await loadFeedbacks(); // Reload list
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['error'] ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        _errorMessage = data['error'] ?? 'ข้อมูลไม่ถูกต้อง';
        _isLoading = false;
        notifyListeners();
        return false;
      } else if (response.statusCode >= 500) {
        _errorMessage = 'เซิร์ฟเวอร์ขัดข้อง (${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _errorMessage = 'ไม่สามารถเชื่อมต่อได้ (${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error adding feedback: $e');
      if (e.toString().contains('SocketException')) {
        _errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้\nกรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
      } else if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'หมดเวลาการเชื่อมต่อ\nกรุณาลองใหม่อีกครั้ง';
      } else if (e.toString().contains('FormatException')) {
        _errorMessage = 'รูปแบบข้อมูลไม่ถูกต้อง';
      } else {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update feedback status (for admin)
  Future<bool> updateFeedbackStatus(String feedbackId, FeedbackStatus status, {String? adminResponse, String? respondedByUserName}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status.name,
          'adminResponse': adminResponse,
          'respondedByUserName': respondedByUserName,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          await loadFeedbacks(); // Reload list
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Error updating feedback: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'total': _feedbacks.length,
      'pending': _feedbacks.where((f) => f.status == FeedbackStatus.pending).length,
      'inProgress': _feedbacks.where((f) => f.status == FeedbackStatus.inProgress).length,
      'resolved': _feedbacks.where((f) => f.status == FeedbackStatus.resolved).length,
      'closed': _feedbacks.where((f) => f.status == FeedbackStatus.closed).length,
      'suggestions': _feedbacks.where((f) => f.type == FeedbackType.suggestion).length,
      'bugs': _feedbacks.where((f) => f.type == FeedbackType.bug).length,
      'features': _feedbacks.where((f) => f.type == FeedbackType.feature).length,
      'complaints': _feedbacks.where((f) => f.type == FeedbackType.complaint).length,
      'compliments': _feedbacks.where((f) => f.type == FeedbackType.compliment).length,
    };
  }

  // Get average rating
  double getAverageRating() {
    if (_feedbacks.isEmpty) return 0.0;
    final totalRating = _feedbacks.fold<int>(0, (sum, feedback) => sum + feedback.rating);
    return totalRating / _feedbacks.length;
  }

  // Vote feedback (up or down)
  Future<bool> voteFeedback({
    required String feedbackId,
    required String userId,
    required String voteType, // 'up' or 'down'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'voteType': voteType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload feedbacks to get updated votes
          await loadFeedbacks();
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error voting feedback: $e');
      return false;
    }
  }

  // Increment views counter
  Future<void> incrementViews(String feedbackId) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/views'),
      );
      // Don't reload feedbacks, just increment locally for better performance
      final index = _feedbacks.indexWhere((f) => f.id == feedbackId);
      if (index != -1) {
        _feedbacks[index] = _feedbacks[index].copyWith(
          views: _feedbacks[index].views + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // Load sample data (for development only - no longer used)
  void loadSampleData() {
    // Deprecated: Now using real API
    _feedbacks = [
      Feedback(
        id: '1',
        userId: 'user1',
        userName: 'สมชาย ใจดี',
        email: 'somchai@email.com',
        phone: '081-234-5678',
        type: FeedbackType.suggestion,
        category: FeedbackCategory.ui,
        subject: 'ปรับปรุงหน้าจอให้ใช้งานง่ายขึ้น',
        message: 'ควรเพิ่มขนาดตัวอักษรให้ใหญ่ขึ้น เพื่อให้ผู้สูงอายุอ่านได้ง่ายขึ้น และปรับสีให้เด่นชัดมากกว่านี้',
        rating: 4,
        priority: FeedbackPriority.high,
        status: FeedbackStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        adminResponse: 'ขอบคุณสำหรับข้อเสนอแนะ เราได้ปรับปรุงขนาดตัวอักษรแล้ว',
        respondedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Feedback(
        id: '2',
        userId: 'user2',
        userName: 'สมหญิง รักษ์ดี',
        email: 'somying@email.com',
        phone: '082-345-6789',
        type: FeedbackType.bug,
        category: FeedbackCategory.export,
        subject: 'ไฟล์ Excel ส่งออกไม่ได้',
        message: 'เมื่อกดส่งออกข้อมูลเป็น Excel แล้วไฟล์เปิดไม่ได้ มีข้อผิดพลาด',
        rating: 2,
        priority: FeedbackPriority.urgent,
        status: FeedbackStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        adminResponse: 'ปัญหาได้รับการแก้ไขแล้ว ตอนนี้ส่งออกเป็น CSV แทน Excel',
        respondedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Feedback(
        id: '3',
        userId: 'user3',
        userName: 'วิชาญ เกษตรกร',
        email: 'wichan@email.com',
        phone: '083-456-7890',
        type: FeedbackType.feature,
        category: FeedbackCategory.livestock,
        subject: 'ขอเพิ่มฟีเจอร์แจ้งเตือนวัคซีน',
        message: 'อยากให้มีระบบแจ้งเตือนเมื่อถึงเวลาฉีดวัคซีนให้ปศุสัตว์',
        rating: 5,
        priority: FeedbackPriority.medium,
        status: FeedbackStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Feedback(
        id: '4',
        userId: 'user4',
        userName: 'มาลี สวนผล',
        email: 'malee@email.com',
        phone: '084-567-8901',
        type: FeedbackType.compliment,
        category: FeedbackCategory.ui,
        subject: 'ชื่นชมระบบใหม่',
        message: 'ระบบใหม่ใช้งานง่ายมาก ตัวอักษรใหญ่อ่านง่าย ขอบคุณมากค่ะ',
        rating: 5,
        priority: FeedbackPriority.low,
        status: FeedbackStatus.closed,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Feedback(
        id: '5',
        userId: 'user5',
        userName: 'บุญมี ปศุสัตว์',
        email: 'boonmee@email.com',
        phone: '085-678-9012',
        type: FeedbackType.suggestion,
        category: FeedbackCategory.survey,
        subject: 'เพิ่มข้อมูลในแบบสำรวจ',
        message: 'ควรเพิ่มช่องบันทึกโรคประจำตัวของปศุสัตว์ในแบบสำรวจด้วย',
        rating: 4,
        priority: FeedbackPriority.medium,
        status: FeedbackStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    notifyListeners();
  }

  // Initialize provider
  void initialize() {
    loadFeedbacks(); // Load from API instead of sample data
  }

  // Edit feedback
  Future<bool> editFeedback(String feedbackId, {String? subject, String? message, String? editedBy}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId');
      print('✏️ [FeedbackProvider] Editing feedback: $feedbackId by $editedBy');
      
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          if (subject != null) 'subject': subject,
          if (message != null) 'message': message,
          if (editedBy != null) 'editedBy': editedBy,
        }),
      );
      
      print(' [FeedbackProvider] Edit response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload feedbacks to get updated data
          await loadFeedbacks();
          print(' [FeedbackProvider] Feedback edited successfully');
          return true;
        }
      }
      
      print(' [FeedbackProvider] Failed to edit feedback');
      return false;
    } catch (e) {
      print(' [FeedbackProvider] Error editing feedback: $e');
      return false;
    }
  }

  // Delete feedback (Soft Delete)
  Future<bool> deleteFeedback(
    String feedbackId, {
    String? deletedBy,
    String? adminId,
    String? adminUsername,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId');
      print(' [FeedbackProvider] Soft deleting feedback: $feedbackId');
      
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deletedBy': deletedBy,
          'adminId': adminId,
          'adminUsername': adminUsername,
        }),
      );
      
      print(' [FeedbackProvider] Delete response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove from local list
          _feedbacks.removeWhere((f) => f.id == feedbackId);
          notifyListeners();
          print(' [FeedbackProvider] Feedback deleted successfully');
          return true;
        }
      }
      
      print(' [FeedbackProvider] Failed to delete feedback');
      return false;
    } catch (e) {
      print(' [FeedbackProvider] Error deleting feedback: $e');
      return false;
    }
  }

  // Get hidden feedback (soft deleted)
  Future<List<Feedback>> getHiddenFeedback() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback/hidden');
      print(' [FeedbackProvider] Getting hidden feedback');
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> feedbacksJson = data['data'];
          return feedbacksJson.map((json) => Feedback.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print(' [FeedbackProvider] Error getting hidden feedback: $e');
      return [];
    }
  }

  // Restore feedback from soft delete
  Future<bool> restoreFeedback(
    String feedbackId, {
    String? restoredBy,
    String? adminId,
    String? adminUsername,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/restore');
      print(' [FeedbackProvider] Restoring feedback: $feedbackId');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'restoredBy': restoredBy,
          'adminId': adminId,
          'adminUsername': adminUsername,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload feedbacks to get updated data
          await loadFeedbacks();
          print(' [FeedbackProvider] Feedback restored successfully');
          return true;
        }
      }
      
      print(' [FeedbackProvider] Failed to restore feedback');
      return false;
    } catch (e) {
      print(' [FeedbackProvider] Error restoring feedback: $e');
      return false;
    }
  }
}
