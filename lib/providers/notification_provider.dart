/// Notification Provider
/// จัดการ state และ API calls สำหรับ notifications

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  Timer? _pollTimer;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Base URL - แก้ตาม environment ของคุณ
  static const String _baseUrl = 'http://localhost:3000/api';

  /// Initialize provider and start polling
  void initialize(String userId) {
    if (userId.isEmpty) return;
    
    // Load initial data
    loadNotifications(userId);
    loadUnreadCount(userId);
    
    // Start polling every 30 seconds
    startPolling(userId);
  }

  /// Load all notifications
  Future<void> loadNotifications(String userId) async {
    if (userId.isEmpty) {
      debugPrint('⚠️ [NotificationProvider] userId is empty, skipping load');
      return;
    }
    
    debugPrint('📬 [NotificationProvider] Loading notifications for userId: $userId');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '$_baseUrl/notifications?user_id=$userId';
      debugPrint('🌐 [NotificationProvider] GET: $url');
      
      final response = await http.get(Uri.parse(url));
      
      debugPrint('📡 [NotificationProvider] Response status: ${response.statusCode}');
      debugPrint('📡 [NotificationProvider] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('✅ [NotificationProvider] Received ${data.length} notifications');
        
        _notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        _error = null;
        
        debugPrint('📋 [NotificationProvider] Parsed notifications:');
        for (var notif in _notifications) {
          debugPrint('  - ${notif.id}: ${notif.title} (read: ${notif.isRead})');
        }
      } else {
        _error = 'Failed to load notifications: ${response.statusCode}';
        debugPrint('❌ [NotificationProvider] Error: $_error');
      }
    } catch (e) {
      _error = 'Error loading notifications: $e';
      debugPrint('❌ [NotificationProvider] Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('🔄 [NotificationProvider] notifyListeners() called');
    }
  }

  /// Load unread count only (faster)
  Future<void> loadUnreadCount(String userId) async {
    if (userId.isEmpty) {
      debugPrint('⚠️ [NotificationProvider] userId is empty, skipping unread count');
      return;
    }

    try {
      final url = '$_baseUrl/notifications/unread-count?user_id=$userId';
      debugPrint('🔔 [NotificationProvider] GET unread count: $url');
      
      final response = await http.get(Uri.parse(url));
      
      debugPrint('📡 [NotificationProvider] Unread count response: ${response.statusCode}');
      debugPrint('📡 [NotificationProvider] Unread count body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _unreadCount = data['unreadCount'] as int;
        debugPrint('✅ [NotificationProvider] Unread count updated: $_unreadCount');
        notifyListeners();
        debugPrint('🔄 [NotificationProvider] notifyListeners() called for unread count');
      } else {
        debugPrint('❌ [NotificationProvider] Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [NotificationProvider] Exception loading unread count: $e');
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId, String userId) async {
    debugPrint('📖 [NotificationProvider] markAsRead called: $notificationId');
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
      );

      debugPrint('📡 [NotificationProvider] markAsRead response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          debugPrint('✅ [NotificationProvider] Marked as read. New unread count: $_unreadCount');
          notifyListeners();
          
          // Reload unread count from server to ensure sync
          await loadUnreadCount(userId);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ [NotificationProvider] Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    debugPrint('📚 [NotificationProvider] markAllAsRead called for userId: $userId');
    try {
      final url = '$_baseUrl/notifications/mark-all-read';
      final body = json.encode({'user_id': userId});
      
      debugPrint('🌐 [NotificationProvider] PATCH: $url');
      debugPrint('📦 [NotificationProvider] Body: $body');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('📡 [NotificationProvider] markAllAsRead response: ${response.statusCode}');
      debugPrint('📡 [NotificationProvider] markAllAsRead body: ${response.body}');

      if (response.statusCode == 200) {
        // Update local state
        _notifications = _notifications.map((n) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();
        _unreadCount = 0;
        debugPrint('✅ [NotificationProvider] All marked as read. Unread count: $_unreadCount');
        notifyListeners();
        
        // Reload to ensure sync
        await Future.wait([
          loadNotifications(userId),
          loadUnreadCount(userId),
        ]);
        
        return true;
      }
      debugPrint('❌ [NotificationProvider] markAllAsRead failed: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('❌ [NotificationProvider] Error marking all as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
      );

      if (response.statusCode == 200) {
        // Update local state
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('🔔 Error deleting notification: $e');
      return false;
    }
  }

  /// Start polling for new notifications
  void startPolling(String userId, {Duration interval = const Duration(seconds: 30)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (timer) {
      loadUnreadCount(userId);
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Refresh notifications (pull-to-refresh)
  Future<void> refresh(String userId) async {
    await Future.wait([
      loadNotifications(userId),
      loadUnreadCount(userId),
    ]);
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
