import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rbac_provider.dart';
import '../providers/production_auth_provider.dart';

/// Widget สำหรับโหลด RBAC permissions หลัง login
/// 
/// วิธีใช้: ครอบ MaterialApp ด้วย RbacInitializer
/// ```dart
/// RbacInitializer(
///   child: MaterialApp(...)
/// )
/// ```
class RbacInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const RbacInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<RbacInitializer> createState() => _RbacInitializerState();
}

class _RbacInitializerState extends ConsumerState<RbacInitializer> {
  @override
  void initState() {
    super.initState();
    // โหลด permissions หลัง widget build เสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPermissions();
    });
  }

  void _loadPermissions() {
    final authState = ref.read(productionAuthProvider);
    
    if (authState.isAuthenticated && authState.accessToken != null) {
      // โหลด permissions
      ref.read(rbacProvider.notifier).loadPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<ProductionAuthState>(productionAuthProvider, (previous, next) {
      if (next.isAuthenticated && next.accessToken != null) {
        // User logged in - load permissions
        _loadPermissions();
      } else if (!next.isAuthenticated) {
        // User logged out - reset permissions
        ref.read(rbacProvider.notifier).reset();
      }
    });

    return widget.child;
  }
}

/// Extension สำหรับเช็คว่าควรโหลด RBAC หรือไม่
extension RbacCheck on WidgetRef {
  /// ตรวจสอบว่า RBAC พร้อมใช้งานหรือไม่
  bool get isRbacReady {
    final rbacState = read(rbacProvider);
    return rbacState.permissions != null;
  }

  /// โหลด RBAC permissions ด้วยตนเอง
  Future<void> loadRbacPermissions() async {
    final authState = read(productionAuthProvider);
    
    if (authState.isAuthenticated && authState.accessToken != null) {
      await read(rbacProvider.notifier).loadPermissions();
    }
  }
}
