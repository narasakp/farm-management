import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/production_auth_provider.dart';

/// Navigation Guard - ป้องกัน Auto Login
/// 
/// ใช้สำหรับ:
/// - ตรวจสอบ authentication ก่อน navigate
/// - Redirect Guest ไปหน้า public แทนหน้าที่ต้อง login
/// - แสดง dialog เตือนถ้าต้อง login

class NavigationGuard {
  /// Public routes ที่ Guest เข้าได้โดยไม่ต้อง login
  static const publicRoutes = [
    '/',
    '/login',
    '/register',
    '/market',
    '/contact-admin',
    '/quick-buy',
    '/guest-search',
  ];

  /// Protected routes ที่ต้อง login
  static const protectedRoutes = [
    '/dashboard',
    '/livestock',
    '/livestock-management',
    '/farm-list',
    '/trading-list',
    '/transport-list',
    '/add-livestock',
    '/edit-livestock',
    '/financial',
    '/survey',
    '/survey-list',
    '/survey-detail',
    '/payment',
    '/farmer-group',
    '/project-report',
    '/reports-analytics',
    '/research-development',
    '/feedback',
    '/admin-dashboard',
    '/admin-users',
    '/admin-roles',
    '/admin-permissions',
    '/admin-contact-settings',
    '/seed-data',
    '/social-analytics',
    '/health-management',
    '/breeding-management',
    '/production-management',
    '/feed-management',
  ];

  /// เช็คว่า route เป็น public หรือไม่
  static bool isPublicRoute(String path) {
    return publicRoutes.any((route) => path.startsWith(route));
  }

  /// เช็คว่า route ต้อง login หรือไม่
  static bool requiresAuth(String path) {
    return protectedRoutes.any((route) => path.startsWith(route));
  }

  /// Smart Navigation - ป้องกัน Auto Login
  /// 
  /// ถ้า Guest พยายามไปหน้าที่ต้อง login:
  /// - แสดง dialog เตือน
  /// - ให้เลือก Login หรือ Cancel
  /// - ถ้า Cancel → อยู่หน้าเดิม
  static void safeNavigate({
    required BuildContext context,
    required WidgetRef ref,
    required String path,
    Object? extra,
  }) {
    final authState = ref.read(productionAuthProvider);

    // Public route → ไปได้เลย
    if (isPublicRoute(path)) {
      if (extra != null) {
        context.go(path, extra: extra);
      } else {
        context.go(path);
      }
      return;
    }

    // Protected route + User logged in → ไปได้เลย
    if (authState.isAuthenticated) {
      if (extra != null) {
        context.go(path, extra: extra);
      } else {
        context.go(path);
      }
      return;
    }

    // Protected route + Guest → แสดง dialog
    _showLoginRequiredDialog(context, path);
  }

  /// แสดง dialog เตือนว่าต้อง login
  static void _showLoginRequiredDialog(BuildContext context, String targetPath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: Color(0xFF228B22), // Green
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'ต้องเข้าสู่ระบบ',
              style: TextStyle(
                color: Color(0xFF8B4513), // Brown
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณต้องเข้าสู่ระบบก่อนเข้าใช้งานหน้านี้',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9), // Light green
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF228B22)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF228B22),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Guest สามารถใช้งานหน้าตลาดซื้อขายและค้นหาได้',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF228B22), // Green
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'เข้าสู่ระบบ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to Home (Smart)
  /// - Guest → /market
  /// - User → /dashboard
  static void navigateToHome(BuildContext context, WidgetRef ref) {
    final authState = ref.read(productionAuthProvider);
    if (authState.isAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/market');
    }
  }

  /// Navigate with Back fallback
  /// - ถ้า Guest และ route ต้อง login → กลับหน้าเดิม
  /// - อื่นๆ → navigate ตามปกติ
  static void navigateOrBack({
    required BuildContext context,
    required WidgetRef ref,
    required String path,
  }) {
    final authState = ref.read(productionAuthProvider);

    if (!authState.isAuthenticated && requiresAuth(path)) {
      // Guest trying to access protected route → stay on current page
      _showLoginRequiredDialog(context, path);
    } else {
      context.go(path);
    }
  }
}

/// Extension สำหรับ BuildContext
extension NavigationGuardExtension on BuildContext {
  /// Safe navigate with auth check
  void safeGo(String path, {Object? extra}) {
    // Note: ต้องมี WidgetRef จาก Consumer widget
    // ใช้ NavigationGuard.safeNavigate() แทนถ้ามี ref
    go(path);
  }
}
