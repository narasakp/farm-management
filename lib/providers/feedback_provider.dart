import 'package:flutter/foundation.dart';
import '../models/feedback.dart';

class FeedbackProvider with ChangeNotifier {
  List<Feedback> _feedbacks = [];
  bool _isLoading = false;

  List<Feedback> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

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

  // Add new feedback
  Future<bool> addFeedback(Feedback feedback) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      _feedbacks.add(feedback);
      _feedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update feedback status (for admin)
  Future<bool> updateFeedbackStatus(String feedbackId, FeedbackStatus status, {String? adminResponse}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      final index = _feedbacks.indexWhere((f) => f.id == feedbackId);
      if (index != -1) {
        _feedbacks[index] = _feedbacks[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          adminResponse: adminResponse,
          respondedAt: adminResponse != null ? DateTime.now() : null,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete feedback
  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      _feedbacks.removeWhere((f) => f.id == feedbackId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
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

  // Load sample data
  void loadSampleData() {
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
        status: FeedbackStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    notifyListeners();
  }

  // Initialize provider
  void initialize() {
    loadSampleData();
  }
}
