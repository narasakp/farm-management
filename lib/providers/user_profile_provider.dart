import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../config/api_config.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _currentProfile;
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get currentProfile => _currentProfile;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user profile
  Future<UserProfile?> loadUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/profile/$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentProfile = UserProfile.fromJson(data['user']);
          _isLoading = false;
          notifyListeners();
          return _currentProfile;
        }
      }

      _errorMessage = 'ไม่สามารถโหลดข้อมูลโปรไฟล์ได้';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      print('❌ [UserProfileProvider] Error loading profile: $e');
      _errorMessage = 'เกิดข้อผิดพลาด';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/profile/leaderboard/top?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> leaderboardJson = data['leaderboard'] ?? [];
          _leaderboard = leaderboardJson
              .map((entry) => LeaderboardEntry.fromJson(entry))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      print('❌ [UserProfileProvider] Error loading leaderboard: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
