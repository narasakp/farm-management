import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feedback_reply.dart';
import '../config/api_config.dart';

class FeedbackRepliesProvider with ChangeNotifier {
  Map<String, List<FeedbackReply>> _repliesByFeedback = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<FeedbackReply> getRepliesForFeedback(String feedbackId) {
    return _repliesByFeedback[feedbackId] ?? [];
  }

  // Get top-level replies (parent_reply_id = null)
  List<FeedbackReply> getTopLevelReplies(String feedbackId) {
    final replies = _repliesByFeedback[feedbackId] ?? [];
    return replies.where((r) => !r.isNested).toList();
  }

  // Get nested replies for a specific parent
  List<FeedbackReply> getNestedReplies(String feedbackId, String parentReplyId) {
    final replies = _repliesByFeedback[feedbackId] ?? [];
    return replies.where((r) => r.parentReplyId == parentReplyId).toList();
  }

  // Get reply count for a feedback
  int getReplyCount(String feedbackId) {
    return _repliesByFeedback[feedbackId]?.length ?? 0;
  }

  // Load replies for a specific feedback
  Future<void> loadReplies(String feedbackId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _repliesByFeedback[feedbackId] = (data['data'] as List)
              .map((item) => FeedbackReply.fromJson(item))
              .toList();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading replies: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new reply
  Future<bool> addReply({
    required String feedbackId,
    required String userId,
    required String userName,
    required String message,
    String? parentReplyId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'userName': userName,
          'message': message,
          'parentReplyId': parentReplyId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload replies to get the latest data
          await loadReplies(feedbackId);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error adding reply: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Vote reply (up or down)
  Future<bool> voteReply({
    required String feedbackId,
    required String replyId,
    required String userId,
    required String voteType, // 'up' or 'down'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies/$replyId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'voteType': voteType,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload replies to get updated votes
          await loadReplies(feedbackId);
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error voting reply: $e');
      return false;
    }
  }

  // Edit reply
  Future<bool> editReply({
    required String feedbackId,
    required String replyId,
    required String message,
    String? editedBy,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies/$replyId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          if (editedBy != null) 'editedBy': editedBy,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload replies to get updated data
          await loadReplies(feedbackId);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error editing reply: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete reply (Soft Delete)
  Future<bool> deleteReply({
    required String feedbackId,
    required String replyId,
    String? deletedBy,
    String? adminId,
    String? adminUsername,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies/$replyId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deletedBy': deletedBy,
          'adminId': adminId,
          'adminUsername': adminUsername,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload replies to get updated data
          await loadReplies(feedbackId);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error deleting reply: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear replies cache
  void clearCache() {
    _repliesByFeedback.clear();
    notifyListeners();
  }

  // Get hidden replies (soft deleted)
  Future<List<FeedbackReply>> getHiddenReplies() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback/hidden/replies');
      print(' [RepliesProvider] Getting hidden replies');
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> repliesJson = data['data'];
          return repliesJson.map((json) => FeedbackReply.fromJson(json)).toList();
        }
      }
      
      return [];
    } catch (e) {
      print(' [RepliesProvider] Error getting hidden replies: $e');
      return [];
    }
  }

  // Restore reply from soft delete
  Future<bool> restoreReply({
    required String feedbackId,
    required String replyId,
    String? restoredBy,
    String? adminId,
    String? adminUsername,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/feedback/$feedbackId/replies/$replyId/restore');
      print(' [RepliesProvider] Restoring reply: $replyId');
      
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
          // Reload replies for this feedback
          await loadReplies(feedbackId);
          print(' [RepliesProvider] Reply restored successfully');
          return true;
        }
      }
      
      print(' [RepliesProvider] Failed to restore reply');
      return false;
    } catch (e) {
      print(' [RepliesProvider] Error restoring reply: $e');
      return false;
    }
  }
}
