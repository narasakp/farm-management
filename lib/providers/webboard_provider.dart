import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/thread.dart';
import '../models/thread_reply.dart';
import '../config/api_config.dart';

class WebboardProvider with ChangeNotifier {
  List<Thread> _threads = [];
  Map<String, List<ThreadReply>> _repliesByThread = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Thread> get threads => _threads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get replies for a specific thread
  List<ThreadReply> getReplies(String threadId) {
    return _repliesByThread[threadId] ?? [];
  }

  // Filter threads by category
  List<Thread> getThreadsByCategory(ThreadCategory category) {
    return _threads.where((t) => t.category == category).toList();
  }

  // Filter threads by status
  List<Thread> getThreadsByStatus(ThreadStatus status) {
    return _threads.where((t) => t.status == status).toList();
  }

  // Search threads
  List<Thread> searchThreads(String query) {
    final lowerQuery = query.toLowerCase();
    return _threads.where((t) => 
      t.title.toLowerCase().contains(lowerQuery) ||
      t.content.toLowerCase().contains(lowerQuery) ||
      t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
    ).toList();
  }

  // Load threads from API
  Future<void> loadThreads({
    ThreadCategory? category,
    ThreadStatus? status,
    String? search,
    String? sort,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category.toString().split('.').last;
      if (status != null) queryParams['status'] = status.toString().split('.').last;
      if (search != null) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/forum/threads').replace(queryParameters: queryParams);
      print('🔍 [WebboardProvider] Loading threads from: $uri');
      
      final response = await http.get(uri);
      print('📡 [WebboardProvider] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 [WebboardProvider] Response data: ${data['success']}, items: ${data['threads']?.length ?? 0}');
        
        if (data['success'] == true) {
          _threads = (data['threads'] as List)
              .map((item) => Thread.fromJson(item))
              .toList();
          print('✅ [WebboardProvider] Loaded ${_threads.length} threads');
        }
      } else {
        print('❌ [WebboardProvider] HTTP Error: ${response.statusCode}');
        _errorMessage = 'HTTP Error: ${response.statusCode}';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ [WebboardProvider] Error loading threads: $e');
      print('📋 Stack trace: $stackTrace');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load thread detail with replies
  Future<Thread?> loadThreadDetail(String threadId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId');
      print('🔍 [WebboardProvider] Loading thread detail: $uri');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final thread = Thread.fromJson(data['thread']);
          
          // Update thread in list
          final index = _threads.indexWhere((t) => t.id == threadId);
          if (index != -1) {
            _threads[index] = thread;
          } else {
            _threads.add(thread);
          }
          
          // Load replies
          if (data['replies'] != null) {
            _repliesByThread[threadId] = (data['replies'] as List)
                .map((item) => ThreadReply.fromJson(item))
                .toList();
          }
          
          _isLoading = false;
          notifyListeners();
          return thread;
        }
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      print('❌ [WebboardProvider] Error loading thread detail: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Create new thread
  Future<Map<String, dynamic>> createThread({
    required String title,
    required String content,
    required ThreadCategory category,
    required List<String> tags,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? email,
    String? phone,
    List<PlatformFile>? files,
  }) async {
    try {
      print('📝 [WebboardProvider] Creating new thread...');
      
      List<String> uploadedFiles = [];
      if (files != null && files.isNotEmpty) {
        uploadedFiles = await uploadFiles(files);
      }

      final body = {
        'title': title,
        'content': content,
        'category': category.toString().split('.').last,
        'tags': tags,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'email': email,
        'phone': phone,
        'attachments': uploadedFiles,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Reload threads
        await loadThreads();
        return {'success': true, 'threadId': data['threadId']};
      }

      return {'success': false, 'message': data['message'] ?? 'Failed to create thread'};
    } catch (e) {
      print('❌ [WebboardProvider] Error creating thread: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Create reply
  Future<Map<String, dynamic>> createReply({
    required String threadId,
    required String content,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    String? parentReplyId,
    List<PlatformFile>? files,
  }) async {
    try {
      print('💬 [WebboardProvider] Creating reply for thread: $threadId');
      
      List<String> uploadedFiles = [];
      if (files != null && files.isNotEmpty) {
        uploadedFiles = await uploadFiles(files);
      }

      final body = {
        'threadId': threadId,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'parentReplyId': parentReplyId,
        'attachments': uploadedFiles,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/replies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Reload thread detail
        await loadThreadDetail(threadId);
        return {'success': true, 'replyId': data['replyId']};
      }

      return {'success': false, 'message': data['message'] ?? 'Failed to create reply'};
    } catch (e) {
      print('❌ [WebboardProvider] Error creating reply: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Vote thread
  Future<bool> voteThread(String threadId, String userId, String voteType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'voteType': voteType}),
      );

      if (response.statusCode == 200) {
        await loadThreadDetail(threadId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error voting thread: $e');
      return false;
    }
  }

  // Vote reply
  Future<bool> voteReply(String replyId, String userId, String voteType) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/replies/$replyId/vote'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'voteType': voteType}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [WebboardProvider] Error voting reply: $e');
      return false;
    }
  }

  // Accept answer
  Future<bool> acceptAnswer(String threadId, String replyId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/accept-answer/$replyId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await loadThreadDetail(threadId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error accepting answer: $e');
      return false;
    }
  }

  // Upload files
  Future<List<String>> uploadFiles(List<PlatformFile> files) async {
    try {
      if (files.isEmpty) return [];
      
      print('📤 [WebboardProvider] Uploading ${files.length} files...');
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/upload/webboard');
      final request = http.MultipartRequest('POST', uri);
      
      for (var file in files) {
        if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'files',
            file.bytes!,
            filename: file.name,
          ));
        }
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final urls = List<String>.from(data['fileUrls']);
          print('✅ [WebboardProvider] Uploaded ${urls.length} files');
          return urls;
        }
      }
      
      print('❌ [WebboardProvider] Upload failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ [WebboardProvider] Error uploading files: $e');
      return [];
    }
  }

  // Pin/Unpin thread (Admin)
  Future<bool> pinThread(String threadId, bool isPinned) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/pin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isPinned': isPinned}),
      );

      if (response.statusCode == 200) {
        await loadThreadDetail(threadId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error pinning thread: $e');
      return false;
    }
  }

  // Lock/Unlock thread (Admin)
  Future<bool> lockThread(String threadId, bool isLocked) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/lock'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isLocked': isLocked}),
      );

      if (response.statusCode == 200) {
        await loadThreadDetail(threadId);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error locking thread: $e');
      return false;
    }
  }

  // Report content (thread or reply)
  Future<bool> reportContent({
    required String contentType,
    required String contentId,
    required String reporterId,
    required String reporterName,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/report'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contentType': contentType,
          'contentId': contentId,
          'reporterId': reporterId,
          'reporterName': reporterName,
          'reason': reason,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ [WebboardProvider] Content reported successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error reporting content: $e');
      return false;
    }
  }

  // Bookmark thread
  Future<bool> bookmarkThread(String threadId, String userId, bool isBookmarked) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/bookmark'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'isBookmarked': isBookmarked}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ [WebboardProvider] Error bookmarking thread: $e');
      return false;
    }
  }

  // Get thread status (bookmark/follow)
  Future<Map<String, bool>> getThreadStatus(String threadId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/status?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'isBookmarked': data['isBookmarked'] ?? false,
          'isFollowing': data['isFollowing'] ?? false,
        };
      }
      return {'isBookmarked': false, 'isFollowing': false};
    } catch (e) {
      print('❌ [WebboardProvider] Error getting thread status: $e');
      return {'isBookmarked': false, 'isFollowing': false};
    }
  }

  // Get bookmarked threads
  Future<List<Thread>> getBookmarkedThreads(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/bookmarks?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> threadsJson = data['threads'] ?? [];
        return threadsJson.map((json) => Thread.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [WebboardProvider] Error getting bookmarked threads: $e');
      return [];
    }
  }

  // Add/Remove emoji reaction
  Future<bool> toggleReaction({
    required String contentType, // 'thread' or 'reply'
    required String contentId,
    required String userId,
    required String userName,
    required String emoji,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/react'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contentType': contentType,
          'contentId': contentId,
          'userId': userId,
          'userName': userName,
          'emoji': emoji,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error toggling reaction: $e');
      return false;
    }
  }

  // Get reactions for content
  Future<Map<String, dynamic>> getReactions(String contentType, String contentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/reactions/$contentType/$contentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'reactions': data['reactions'] ?? []
          };
        }
      }
      return {'success': false, 'reactions': []};
    } catch (e) {
      print('❌ [WebboardProvider] Error getting reactions: $e');
      return {'success': false, 'reactions': []};
    }
  }

  // Edit thread
  Future<Map<String, dynamic>> editThread({
    required String threadId,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    required String authorId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'content': content,
          'category': category,
          'tags': tags,
          'authorId': authorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Reload threads
          await loadThreads();
          return {'success': true, 'message': data['message']};
        }
      }
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    } catch (e) {
      print('❌ [WebboardProvider] Error editing thread: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    }
  }

  // Delete thread
  Future<Map<String, dynamic>> deleteThread({
    required String threadId,
    required String authorId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'authorId': authorId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove from local list
          _threads.removeWhere((t) => t.id == threadId);
          notifyListeners();
          return {'success': true, 'message': data['message']};
        }
      }
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    } catch (e) {
      print('❌ [WebboardProvider] Error deleting thread: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    }
  }

  // Edit reply
  Future<Map<String, dynamic>> editReply({
    required String replyId,
    required String content,
    required String authorId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/replies/$replyId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': content,
          'authorId': authorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': data['success'], 'message': data['message']};
      }
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    } catch (e) {
      print('❌ [WebboardProvider] Error editing reply: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    }
  }

  // Delete reply
  Future<Map<String, dynamic>> deleteReply({
    required String replyId,
    required String authorId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/replies/$replyId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'authorId': authorId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': data['success'], 'message': data['message']};
      }
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    } catch (e) {
      print('❌ [WebboardProvider] Error deleting reply: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด'};
    }
  }

  // Follow thread
  Future<Map<String, dynamic>> followThread({
    required String threadId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/follow'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'message': data['message'],
          'isFollowing': data['isFollowing']
        };
      }
      return {'success': false, 'message': 'เกิดข้อผิดพลาด', 'isFollowing': false};
    } catch (e) {
      print('❌ [WebboardProvider] Error following thread: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด', 'isFollowing': false};
    }
  }

  // Unfollow thread
  Future<Map<String, dynamic>> unfollowThread({
    required String threadId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/follow'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'],
          'message': data['message'],
          'isFollowing': data['isFollowing']
        };
      }
      return {'success': false, 'message': 'เกิดข้อผิดพลาด', 'isFollowing': true};
    } catch (e) {
      print('❌ [WebboardProvider] Error unfollowing thread: $e');
      return {'success': false, 'message': 'เกิดข้อผิดพลาด', 'isFollowing': true};
    }
  }

  // Check if following thread
  Future<bool> isFollowingThread({
    required String threadId,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/threads/$threadId/is-following?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['isFollowing'] == true;
        }
      }
      return false;
    } catch (e) {
      print('❌ [WebboardProvider] Error checking follow status: $e');
      return false;
    }
  }

  // Get followed threads
  Future<List<Thread>> getFollowedThreads(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/forum/my-followed-threads?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> threadsData = data['threads'] ?? [];
          return threadsData.map((json) => Thread.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ [WebboardProvider] Error getting followed threads: $e');
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
