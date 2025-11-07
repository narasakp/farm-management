import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rbac_service.dart';
import 'production_auth_provider.dart';

// Export UserPermissions for use in other files
export '../services/rbac_service.dart' show UserPermissions, Permission;

/// RBAC State
class RbacState {
  final UserPermissions? permissions;
  final bool isLoading;
  final String? error;

  RbacState({
    this.permissions,
    this.isLoading = false,
    this.error,
  });

  RbacState copyWith({
    UserPermissions? permissions,
    bool? isLoading,
    String? error,
  }) {
    return RbacState(
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// RBAC Provider
class RbacNotifier extends StateNotifier<RbacState> {
  final String? token;

  RbacNotifier(this.token) : super(RbacState());

  /// โหลด permissions
  Future<void> loadPermissions() async {
    if (token == null || token!.isEmpty) {
      state = state.copyWith(error: 'No token available');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final permissions = await RbacService.getMyPermissions(token!);

      if (permissions != null) {
        state = state.copyWith(
          permissions: permissions,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load permissions',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// ตรวจสอบ permission
  bool hasPermission(String permissionCode) {
    return state.permissions?.hasPermission(permissionCode) ?? false;
  }

  /// ตรวจสอบหลาย permissions (ต้องมีทั้งหมด)
  bool hasAllPermissions(List<String> permissionCodes) {
    return state.permissions?.hasAllPermissions(permissionCodes) ?? false;
  }

  /// ตรวจสอบหลาย permissions (มีอย่างน้อย 1)
  bool hasAnyPermission(List<String> permissionCodes) {
    return state.permissions?.hasAnyPermission(permissionCodes) ?? false;
  }

  /// ตรวจสอบว่ามีสิทธิ์เข้าถึง resource หรือไม่
  bool canAccess(String resource, String action) {
    return state.permissions?.canAccess(resource, action) ?? false;
  }

  /// รีเซ็ต state
  void reset() {
    state = RbacState();
  }
}

/// Provider สำหรับ RBAC (ดึง token จาก auth provider อัตโนมัติ)
final rbacProvider =
    StateNotifierProvider<RbacNotifier, RbacState>((ref) {
  // Watch token from auth provider
  final authState = ref.watch(productionAuthProvider);
  final token = authState.isAuthenticated ? authState.accessToken : null;
  
  return RbacNotifier(token);
});

/// Provider สำหรับตรวจสอบ permission แบบง่าย
final hasPermissionProvider = Provider.family<bool, String>((ref, permissionCode) {
  final rbacState = ref.watch(rbacProvider);
  return rbacState.permissions?.hasPermission(permissionCode) ?? false;
});

/// Provider สำหรับ role shortcuts
final roleCheckProvider = Provider((ref) {
  final rbacState = ref.watch(rbacProvider);
  final permissions = rbacState.permissions;

  return RoleCheck(
    isAdmin: permissions?.isAdmin ?? false,
    isAmphoeOfficer: permissions?.isAmphoeOfficer ?? false,
    isTambonOfficer: permissions?.isTambonOfficer ?? false,
    isFarmer: permissions?.isFarmer ?? false,
    isResearcher: permissions?.isResearcher ?? false,
    isTrader: permissions?.isTrader ?? false,
    isTransporter: permissions?.isTransporter ?? false,
    isGroupLeader: permissions?.isGroupLeader ?? false,
    role: permissions?.role,
    roleName: permissions?.roleName,
    level: permissions?.level,
  );
});

/// Role Check Helper
class RoleCheck {
  final bool isAdmin;
  final bool isAmphoeOfficer;
  final bool isTambonOfficer;
  final bool isFarmer;
  final bool isResearcher;
  final bool isTrader;
  final bool isTransporter;
  final bool isGroupLeader;
  final String? role;
  final String? roleName;
  final int? level;

  RoleCheck({
    required this.isAdmin,
    required this.isAmphoeOfficer,
    required this.isTambonOfficer,
    required this.isFarmer,
    required this.isResearcher,
    required this.isTrader,
    required this.isTransporter,
    required this.isGroupLeader,
    this.role,
    this.roleName,
    this.level,
  });

  /// ตรวจสอบว่าเป็นเจ้าหน้าที่หรือไม่
  bool get isOfficer => isAmphoeOfficer || isTambonOfficer;

  /// ตรวจสอบว่าเป็นผู้ใช้ระดับสูงหรือไม่
  bool get isHighLevel => isAdmin || isAmphoeOfficer;
}

/// Provider สำหรับ dashboard permissions
final dashboardPermissionsProvider = Provider((ref) {
  final rbacState = ref.watch(rbacProvider);
  final permissions = rbacState.permissions;

  if (permissions == null) {
    return DashboardPermissions.none();
  }

  return DashboardPermissions(
    canViewDashboard: permissions.hasAnyPermission([
      'dashboard.own',
      'dashboard.tambon',
      'dashboard.amphoe',
      'dashboard.all',
      'dashboard.market',
      'dashboard.transport',
      'dashboard.group',
    ]),
    canManageFarms: permissions.hasPermission('farms.crud'),
    canViewFarms: permissions.hasAnyPermission(['farms.read', 'farms.crud']),
    canManageLivestock: permissions.hasPermission('livestock.crud'),
    canViewLivestock: permissions.hasAnyPermission(['livestock.read', 'livestock.crud', 'livestock.market']),
    canManageFinance: permissions.hasPermission('finance.own'),
    canManageTrading: permissions.hasPermission('trading.crud'),
    canViewTrading: permissions.hasAnyPermission(['trading.read', 'trading.crud']),
    canManageTransport: permissions.hasPermission('transport.crud'),
    canBookTransport: permissions.hasAnyPermission(['transport.book', 'transport.read']),
    canManageGroups: permissions.hasPermission('groups.crud'),
    canViewGroups: permissions.hasAnyPermission(['groups.member', 'groups.crud']),
    canManageSurveys: permissions.hasPermission('surveys.crud'),
    canViewSurveys: permissions.hasPermission('surveys.read'),
    canManageResearch: permissions.hasPermission('research.crud'),
    canViewReports: permissions.hasAnyPermission([
      'reports.own',
      'reports.tambon',
      'reports.amphoe',
      'reports.all',
      'reports.group',
    ]),
    canAccessAdminDashboard: permissions.isAdmin,
  );
});

/// Dashboard Permissions Helper
class DashboardPermissions {
  final bool canViewDashboard;
  final bool canManageFarms;
  final bool canViewFarms;
  final bool canManageLivestock;
  final bool canViewLivestock;
  final bool canManageFinance;
  final bool canManageTrading;
  final bool canViewTrading;
  final bool canManageTransport;
  final bool canBookTransport;
  final bool canManageGroups;
  final bool canViewGroups;
  final bool canManageSurveys;
  final bool canViewSurveys;
  final bool canManageResearch;
  final bool canViewReports;
  final bool canAccessAdminDashboard;

  DashboardPermissions({
    required this.canViewDashboard,
    required this.canManageFarms,
    required this.canViewFarms,
    required this.canManageLivestock,
    required this.canViewLivestock,
    required this.canManageFinance,
    required this.canManageTrading,
    required this.canViewTrading,
    required this.canManageTransport,
    required this.canBookTransport,
    required this.canManageGroups,
    required this.canViewGroups,
    required this.canManageSurveys,
    required this.canViewSurveys,
    required this.canManageResearch,
    required this.canViewReports,
    required this.canAccessAdminDashboard,
  });

  factory DashboardPermissions.none() {
    return DashboardPermissions(
      canViewDashboard: false,
      canManageFarms: false,
      canViewFarms: false,
      canManageLivestock: false,
      canViewLivestock: false,
      canManageFinance: false,
      canManageTrading: false,
      canViewTrading: false,
      canManageTransport: false,
      canBookTransport: false,
      canManageGroups: false,
      canViewGroups: false,
      canManageSurveys: false,
      canViewSurveys: false,
      canManageResearch: false,
      canViewReports: false,
      canAccessAdminDashboard: false,
    );
  }
}
