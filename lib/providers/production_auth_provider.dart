import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/production_auth_service.dart';

// Auth state class
class ProductionAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final String? accessToken;

  const ProductionAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
    this.accessToken,
  });

  ProductionAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    String? accessToken,
  }) {
    return ProductionAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}

// Auth notifier
class ProductionAuthNotifier extends StateNotifier<ProductionAuthState> {
  final ProductionAuthService _authService;

  ProductionAuthNotifier(this._authService) : super(const ProductionAuthState()) {
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final isValid = await _authService.validateToken();
        if (isValid) {
          final user = await _authService.getCurrentUser();
          final accessToken = await _authService.getAccessToken();
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
            accessToken: accessToken,
          );
        } else {
          await _authService.logout();
          state = state.copyWith(isAuthenticated: false, isLoading: false);
        }
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'เกิดข้อผิดพลาดในการตรวจสอบสถานะการเข้าสู่ระบบ',
      );
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.login(username, password);
      
      if (result['success']) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: {
            'id': result['userId'],
            'username': username,
            'role': result['userRole'],
            'display_name': result['displayName'],
            'email': result['email'],
          },
          accessToken: result['accessToken'],
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: result['error'],
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
      );
      
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
      };
    }
  }

  // Register method (Named Parameters - Safe from parameter order bugs)
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String displayName,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.register(
        username: username,
        password: password,
        email: email,
        displayName: displayName,
        role: role,
      );
      
      state = state.copyWith(isLoading: false);
      
      if (!result['success']) {
        state = state.copyWith(error: result['error']);
      }
      
      return result;
    } catch (e) {
      print('❌ Registration provider error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'เกิดข้อผิดพลาดในการสร้างบัญชี: $e',
      );
      
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการสร้างบัญชี: $e',
      };
    }
  }

  // Reset password method
  Future<Map<String, dynamic>> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.resetPassword(email, "dummy");
      state = state.copyWith(isLoading: false);
      
      if (!result['success']) {
        state = state.copyWith(error: result['error']);
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'เกิดข้อผิดพลาดในการรีเซ็ตรหัสผ่าน',
      );
      
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการรีเซ็ตรหัสผ่าน',
      };
    }
  }

  // Logout method
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authService.logout();
      state = const ProductionAuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'เกิดข้อผิดพลาดในการออกจากระบบ',
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final result = await _authService.refreshToken();
      if (result['success']) {
        state = state.copyWith(accessToken: result['access_token']);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Get auth headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    return await _authService.getAuthHeaders();
  }
}

// Providers
final productionAuthServiceProvider = Provider<ProductionAuthService>((ref) {
  return ProductionAuthService();
});

final productionAuthProvider = StateNotifierProvider<ProductionAuthNotifier, ProductionAuthState>((ref) {
  final authService = ref.watch(productionAuthServiceProvider);
  return ProductionAuthNotifier(authService);
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(productionAuthProvider).isAuthenticated;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(productionAuthProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(productionAuthProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(productionAuthProvider).error;
});
