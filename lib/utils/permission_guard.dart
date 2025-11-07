import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rbac_provider.dart';

/// Widget สำหรับซ่อน/แสดง UI ตาม Permission
class PermissionGuard extends ConsumerWidget {
  final String? permissionCode;
  final List<String>? anyPermissions; // มีอย่างน้อย 1
  final List<String>? allPermissions; // ต้องมีทั้งหมด
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionGuard({
    Key? key,
    this.permissionCode,
    this.anyPermissions,
    this.allPermissions,
    required this.child,
    this.fallback,
    this.showFallback = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacState = ref.watch(rbacProvider);
    final permissions = rbacState.permissions;

    if (permissions == null) {
      return showFallback
          ? (fallback ?? const SizedBox.shrink())
          : const SizedBox.shrink();
    }

    bool hasAccess = false;

    if (permissionCode != null) {
      hasAccess = permissions.hasPermission(permissionCode!);
    } else if (anyPermissions != null && anyPermissions!.isNotEmpty) {
      hasAccess = permissions.hasAnyPermission(anyPermissions!);
    } else if (allPermissions != null && allPermissions!.isNotEmpty) {
      hasAccess = permissions.hasAllPermissions(allPermissions!);
    }

    if (hasAccess) {
      return child;
    }

    return showFallback
        ? (fallback ?? const SizedBox.shrink())
        : const SizedBox.shrink();
  }
}

/// Widget สำหรับตรวจสอบ Role
class RoleGuard extends ConsumerWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const RoleGuard({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.showFallback = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacState = ref.watch(rbacProvider);
    final permissions = rbacState.permissions;

    if (permissions == null) {
      return showFallback
          ? (fallback ?? const SizedBox.shrink())
          : const SizedBox.shrink();
    }

    final hasAccess = allowedRoles.contains(permissions.role);

    if (hasAccess) {
      return child;
    }

    return showFallback
        ? (fallback ?? const SizedBox.shrink())
        : const SizedBox.shrink();
  }
}

/// Mixin สำหรับตรวจสอบ Permission ใน Widget
mixin PermissionMixin {
  /// ตรวจสอบ permission และแสดง error dialog
  Future<bool> checkPermissionWithDialog(
    BuildContext context,
    WidgetRef ref,
    String permissionCode, {
    String? message,
  }) async {
    final rbacState = ref.read(rbacProvider);
    final hasPermission = rbacState.permissions?.hasPermission(permissionCode) ?? false;

    if (!hasPermission) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ไม่มีสิทธิ์เข้าถึง'),
          content: Text(
            message ?? 'คุณไม่มีสิทธิ์ในการใช้งานฟีเจอร์นี้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ตรวจสอบ'),
            ),
          ],
        ),
      );
    }

    return hasPermission;
  }

  /// ตรวจสอบ permission และแสดง SnackBar
  bool checkPermissionWithSnackBar(
    BuildContext context,
    WidgetRef ref,
    String permissionCode, {
    String? message,
  }) {
    final rbacState = ref.read(rbacProvider);
    final hasPermission = rbacState.permissions?.hasPermission(permissionCode) ?? false;

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ?? 'คุณไม่มีสิทธิ์ในการใช้งานฟีเจอร์นี้',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return hasPermission;
  }
}

/// Extension สำหรับ WidgetRef
extension PermissionExtension on WidgetRef {
  /// ตรวจสอบ permission แบบง่าย
  bool hasPermission(String permissionCode) {
    final rbacState = read(rbacProvider);
    return rbacState.permissions?.hasPermission(permissionCode) ?? false;
  }

  /// ตรวจสอบหลาย permissions (ต้องมีทั้งหมด)
  bool hasAllPermissions(List<String> permissionCodes) {
    final rbacState = read(rbacProvider);
    return rbacState.permissions?.hasAllPermissions(permissionCodes) ?? false;
  }

  /// ตรวจสอบหลาย permissions (มีอย่างน้อย 1)
  bool hasAnyPermission(List<String> permissionCodes) {
    final rbacState = read(rbacProvider);
    return rbacState.permissions?.hasAnyPermission(permissionCodes) ?? false;
  }

  /// ตรวจสอบ role
  bool hasRole(String role) {
    final rbacState = read(rbacProvider);
    return rbacState.permissions?.role == role;
  }

  /// ตรวจสอบหลาย roles
  bool hasAnyRole(List<String> roles) {
    final rbacState = read(rbacProvider);
    final userRole = rbacState.permissions?.role;
    return userRole != null && roles.contains(userRole);
  }

  /// ดึงข้อมูล permissions
  UserPermissions? get permissions {
    final rbacState = read(rbacProvider);
    return rbacState.permissions;
  }
}

/// Permission Constants
class Permissions {
  // Dashboard
  static const dashboardOwn = 'dashboard.own';
  static const dashboardTambon = 'dashboard.tambon';
  static const dashboardAmphoe = 'dashboard.amphoe';
  static const dashboardAll = 'dashboard.all';
  static const dashboardMarket = 'dashboard.market';
  static const dashboardTransport = 'dashboard.transport';
  static const dashboardGroup = 'dashboard.group';

  // Farms
  static const farmsCrud = 'farms.crud';
  static const farmsRead = 'farms.read';
  static const farmsSummary = 'farms.summary';

  // Livestock
  static const livestockCrud = 'livestock.crud';
  static const livestockRead = 'livestock.read';
  static const livestockMarket = 'livestock.market';
  static const livestockSummary = 'livestock.summary';

  // Health
  static const healthCrud = 'health.crud';
  static const healthRead = 'health.read';

  // Breeding
  static const breedingCrud = 'breeding.crud';
  static const breedingRead = 'breeding.read';

  // Feed
  static const feedCrud = 'feed.crud';
  static const feedRead = 'feed.read';

  // Production
  static const productionCrud = 'production.crud';
  static const productionRead = 'production.read';
  static const productionSummary = 'production.summary';

  // Finance
  static const financeOwn = 'finance.own';
  static const financeFund = 'finance.fund';

  // Trading
  static const tradingCrud = 'trading.crud';
  static const tradingRead = 'trading.read';

  // Transport
  static const transportBook = 'transport.book';
  static const transportRead = 'transport.read';
  static const transportCrud = 'transport.crud';

  // Groups
  static const groupsMember = 'groups.member';
  static const groupsCrud = 'groups.crud';

  // Surveys
  static const surveysCrud = 'surveys.crud';
  static const surveysRead = 'surveys.read';

  // Research
  static const researchCrud = 'research.crud';

  // Reports
  static const reportsOwn = 'reports.own';
  static const reportsTambon = 'reports.tambon';
  static const reportsAmphoe = 'reports.amphoe';
  static const reportsAll = 'reports.all';
  static const reportsGroup = 'reports.group';
}

/// Role Constants
class Roles {
  static const superAdmin = 'SUPER_ADMIN';
  static const amphoeOfficer = 'AMPHOE_OFFICER';
  static const tambonOfficer = 'TAMBON_OFFICER';
  static const farmer = 'FARMER';
  static const researcher = 'RESEARCHER';
  static const trader = 'TRADER';
  static const transporter = 'TRANSPORTER';
  static const groupLeader = 'GROUP_LEADER';

  static const List<String> allRoles = [
    superAdmin,
    amphoeOfficer,
    tambonOfficer,
    farmer,
    researcher,
    trader,
    transporter,
    groupLeader,
  ];

  static const List<String> officers = [
    superAdmin,
    amphoeOfficer,
    tambonOfficer,
  ];

  static const List<String> users = [
    farmer,
    trader,
    transporter,
    groupLeader,
  ];
}
