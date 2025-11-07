import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/true_google_oauth_service.dart';
import '../services/facebook_oauth_service.dart';

class SocialAuthState {
  final bool isAuthenticated;
  final bool isGoogleLoading;
  final bool isFacebookLoading;
  final bool isLineLoading;
  final bool isAppleLoading;
  final String? error;
  final String? provider;
  final String? userEmail;
  final String? userName;
  final String? userId;
  final String? photoUrl;  // 🆕 เพิ่ม Avatar URL

  SocialAuthState({
    this.isAuthenticated = false,
    this.isGoogleLoading = false,
    this.isFacebookLoading = false,
    this.isLineLoading = false,
    this.isAppleLoading = false,
    this.error,
    this.provider,
    this.userEmail,
    this.userName,
    this.userId,
    this.photoUrl,  // 🆕
  });

  SocialAuthState copyWith({
    bool? isAuthenticated,
    bool? isGoogleLoading,
    bool? isFacebookLoading,
    bool? isLineLoading,
    bool? isAppleLoading,
    String? error,
    String? provider,
    String? userEmail,
    String? userName,
    String? userId,
    String? photoUrl,  // 🆕
  }) {
    return SocialAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isFacebookLoading: isFacebookLoading ?? this.isFacebookLoading,
      isLineLoading: isLineLoading ?? this.isLineLoading,
      isAppleLoading: isAppleLoading ?? this.isAppleLoading,
      error: error,
      provider: provider ?? this.provider,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
      photoUrl: photoUrl ?? this.photoUrl,  // 🆕
    );
  }
}

class SocialAuthNotifier extends StateNotifier<SocialAuthState> {
  SocialAuthNotifier() : super(SocialAuthState());

  Future<bool> loginWithGoogle() async {
    // Clear any previous errors first
    state = state.copyWith(error: null);
    
    // Add small delay to prevent UI flicker
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(isGoogleLoading: true);
    
    try {
      final result = await TrueGoogleOAuthService.signInWithGoogle();
      
      if (result != null && result['success'] == true) {
        print('✅ Google OAuth JWT received, sending to backend...');
        
        // Send to backend for authentication
        final backendResult = await TrueGoogleOAuthService.sendToBackend(result);
        
        if (backendResult != null && backendResult['success'] == true) {
          print('✅ Backend authentication successful');
          
          // Store tokens in SharedPreferences (same as ProductionAuthService)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', backendResult['access_token']);
          await prefs.setString('refresh_token', backendResult['refresh_token']);
          await prefs.setString('user_data', jsonEncode({
            'id': backendResult['user']['id'],
            'username': backendResult['user']['username'],
            'email': backendResult['user']['email'],
            'role': backendResult['user']['role'],
            'display_name': backendResult['user']['displayName'],
            'photo_url': result['photo_url'],  // 🆕 เก็บ Avatar URL
          }));
          print('✅ Tokens and user data stored in SharedPreferences');
          
          state = state.copyWith(
            isGoogleLoading: false,
            isAuthenticated: true,
            provider: 'Google',
            userEmail: result['email'],
            userName: result['name'],
            userId: result['uid'] ?? 'google_user',
            photoUrl: result['photo_url'],  // 🆕 เก็บ Avatar URL
          );
          await AuthService().saveLoginState(true);
          return true;
        } else {
          print('❌ Backend authentication failed: ${backendResult?['message']}');
          state = state.copyWith(
            isGoogleLoading: false,
            error: backendResult?['message'] ?? 'Backend authentication failed',
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isGoogleLoading: false,
          error: result?['error'] ?? 'Google login failed',
        );
        return false;
      }
    } catch (e) {
      print('❌ Google OAuth error: $e');
      state = state.copyWith(
        isGoogleLoading: false,
        error: 'Google login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    // Clear any previous errors first
    state = state.copyWith(error: null);
    
    // Add small delay to prevent UI flicker
    await Future.delayed(const Duration(milliseconds: 100));
    
    state = state.copyWith(isFacebookLoading: true);
    
    try {
      final result = await FacebookOAuthService.signInWithFacebook();
      
      if (result != null && result['success'] == true) {
        print('✅ Facebook OAuth successful, sending to backend...');
        
        // Send to backend for authentication
        final backendResult = await FacebookOAuthService.sendToBackend(result);
        
        if (backendResult != null && backendResult['success'] == true) {
          print('✅ Backend authentication successful');
          
          // Store tokens in SharedPreferences (same as Google OAuth)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', backendResult['access_token']);
          await prefs.setString('refresh_token', backendResult['refresh_token']);
          await prefs.setString('user_data', jsonEncode({
            'id': backendResult['user']['id'],
            'username': backendResult['user']['username'],
            'email': backendResult['user']['email'],
            'role': backendResult['user']['role'],
            'display_name': backendResult['user']['displayName'],
            'photo_url': result['photo_url'],  // 🆕 เก็บ Avatar URL
          }));
          print('✅ Tokens and user data stored in SharedPreferences');
          
          state = state.copyWith(
            isFacebookLoading: false,
            isAuthenticated: true,
            provider: 'Facebook',
            userEmail: result['email'],
            userName: result['name'],
            userId: result['user_id'] ?? 'facebook_user',
            photoUrl: result['photo_url'],  // 🆕 เก็บ Avatar URL
          );
          await AuthService().saveLoginState(true);
          return true;
        } else {
          print('❌ Backend authentication failed: ${backendResult?['message']}');
          state = state.copyWith(
            isFacebookLoading: false,
            error: backendResult?['message'] ?? 'Backend authentication failed',
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isFacebookLoading: false,
          error: result?['error'] ?? 'Facebook login failed',
        );
        return false;
      }
    } catch (e) {
      print('❌ Facebook OAuth error: $e');
      state = state.copyWith(
        isFacebookLoading: false,
        error: 'Facebook login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> loginWithLINE() async {
    state = state.copyWith(isLineLoading: true, error: null);
    
    try {
      // LINE OAuth not configured yet
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        isLineLoading: false,
        error: 'LINE login is not configured yet. Please contact administrator.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLineLoading: false,
        error: 'LINE login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(isAppleLoading: true, error: null);
    
    try {
      // Apple OAuth not configured yet
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        isAppleLoading: false,
        error: 'Apple login is not configured yet. Please contact administrator.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isAppleLoading: false,
        error: 'Apple login failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await TrueGoogleOAuthService.signOut(); // Call the static method
    await AuthService().clearLoginState(); // Clear saved login state
    state = SocialAuthState(); // Reset state
  }

  void signOut() {
    logout();
  }
}

final socialAuthProvider = StateNotifierProvider<SocialAuthNotifier, SocialAuthState>((ref) {
  return SocialAuthNotifier();
});
