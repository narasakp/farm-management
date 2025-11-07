import 'dart:convert';
import 'package:http/http.dart' as http;

/// Admin Service สำหรับจัดการ Users, Roles, และ Permissions
/// ใช้ได้เฉพาะ SUPER_ADMIN เท่านั้น
class AdminService {
  static const String baseUrl = 'http://localhost:3000/api/admin';

  // ==================== USER MANAGEMENT ====================

  /// ดึงรายชื่อ users ทั้งหมด
  static Future<List<AdminUser>?> getAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final usersList = data['users'] as List;
        print('📧 [ADMIN_SERVICE] Received ${usersList.length} users from API');
        
        final users = usersList.map((json) => AdminUser.fromJson(json)).toList();
        
        // Debug: แสดง 3 users แรกพร้อม email
        if (users.isNotEmpty) {
          for (var i = 0; i < (users.length > 3 ? 3 : users.length); i++) {
            print('📧 [ADMIN_SERVICE] User ${i+1}: ${users[i].username}, Email: ${users[i].email}');
          }
        }
        
        return users;
      }
      return null;
    } catch (e) {
      print('Error fetching users: $e');
      return null;
    }
  }

  /// ดูรายละเอียด user
  static Future<AdminUserDetail?> getUserDetail(String token, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminUserDetail.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching user detail: $e');
      return null;
    }
  }

  /// เปลี่ยน role ของ user
  static Future<bool> changeUserRole(
    String token,
    int userId,
    String newRole,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/role'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'role': newRole}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error changing user role: $e');
      return false;
    }
  }

  /// เปิด/ปิดการใช้งาน user
  static Future<bool> toggleUserStatus(
    String token,
    int userId,
    bool isActive,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_active': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error toggling user status: $e');
      return false;
    }
  }

  /// ลบผู้ใช้ (CASCADE DELETE related records)
  static Future<bool> deleteUser(
    String token,
    int userId,
  ) async {
    try {
      final url = '$baseUrl/users/$userId';
      print('🗑️ [DELETE] URL: $url');
      print('🗑️ [DELETE] User ID: $userId');
      
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🗑️ [DELETE] Status: ${response.statusCode}');
      print('🗑️ [DELETE] Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [DELETE] Success!');
        return true;
      } else {
        print('❌ [DELETE] Failed with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ [DELETE] Exception: $e');
      return false;
    }
  }

  // ==================== ROLE MANAGEMENT ====================

  /// ดึง roles ทั้งหมด
  static Future<List<AdminRole>?> getAllRoles(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final roles = (data['roles'] as List)
            .map((json) => AdminRole.fromJson(json))
            .toList();
        return roles;
      }
      return null;
    } catch (e) {
      print('Error fetching roles: $e');
      return null;
    }
  }

  /// ดึง permissions ของ role
  static Future<List<AdminPermission>?> getRolePermissions(
    String token,
    String roleCode,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/roles/$roleCode/permissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final permissions = (data['permissions'] as List)
            .map((json) => AdminPermission.fromJson(json))
            .toList();
        return permissions;
      }
      return null;
    } catch (e) {
      print('Error fetching role permissions: $e');
      return null;
    }
  }

  /// อัปเดต permissions ของ role
  static Future<bool> updateRolePermissions(
    String token,
    String roleCode,
    List<String> permissionCodes,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/roles/$roleCode/permissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'permission_codes': permissionCodes}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating role permissions: $e');
      return false;
    }
  }

  // ==================== PERMISSION MANAGEMENT ====================

  /// ดึง permissions ทั้งหมด
  static Future<AdminPermissionsData?> getAllPermissions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/permissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminPermissionsData.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching permissions: $e');
      return null;
    }
  }

  /// ดึง permission matrix
  static Future<PermissionMatrix?> getPermissionMatrix(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/permission-matrix'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PermissionMatrix.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching permission matrix: $e');
      return null;
    }
  }

  // ==================== STATISTICS ====================

  /// ดึงสถิติภาพรวม
  static Future<AdminStats?> getStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AdminStats.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching stats: $e');
      return null;
    }
  }
}

// ==================== MODELS ====================

/// User Model สำหรับ Admin
class AdminUser {
  final int id;
  final String username;
  final String? email;
  final String displayName;
  final String role;
  final String? roleName;
  final String? phone;
  final bool isActive;
  final bool isVerified;
  final String? provinceCode;
  final String? amphoeCode;
  final String? tambonCode;
  final String createdAt;
  final String? lastLoginAt;

  AdminUser({
    required this.id,
    required this.username,
    this.email,
    required this.displayName,
    required this.role,
    this.roleName,
    this.phone,
    required this.isActive,
    required this.isVerified,
    this.provinceCode,
    this.amphoeCode,
    this.tambonCode,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      displayName: json['display_name'],
      role: json['role'],
      roleName: json['role_name'],
      phone: json['phone'],
      isActive: json['is_active'] == 1,
      isVerified: json['is_verified'] == 1,
      provinceCode: json['province_code'],
      amphoeCode: json['amphoe_code'],
      tambonCode: json['tambon_code'],
      createdAt: json['created_at'],
      lastLoginAt: json['last_login_at'],
    );
  }
}

/// User Detail with Permissions
class AdminUserDetail {
  final AdminUser user;
  final List<AdminPermission> permissions;

  AdminUserDetail({
    required this.user,
    required this.permissions,
  });

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) {
    return AdminUserDetail(
      user: AdminUser.fromJson(json['user']),
      permissions: (json['permissions'] as List)
          .map((p) => AdminPermission.fromJson(p))
          .toList(),
    );
  }
}

/// Role Model
class AdminRole {
  final int roleId;
  final String roleCode;
  final String roleName;
  final String? description;
  final int level;
  final bool isActive;
  final int permissionCount;
  final int userCount;

  AdminRole({
    required this.roleId,
    required this.roleCode,
    required this.roleName,
    this.description,
    required this.level,
    required this.isActive,
    required this.permissionCount,
    required this.userCount,
  });

  factory AdminRole.fromJson(Map<String, dynamic> json) {
    return AdminRole(
      roleId: json['role_id'],
      roleCode: json['role_code'],
      roleName: json['role_name'],
      description: json['description'],
      level: json['level'],
      isActive: json['is_active'] == 1,
      permissionCount: json['permission_count'] ?? 0,
      userCount: json['user_count'] ?? 0,
    );
  }
}

/// Permission Model
class AdminPermission {
  final int permissionId;
  final String permissionCode;
  final String resource;
  final String action;
  final String? description;

  AdminPermission({
    required this.permissionId,
    required this.permissionCode,
    required this.resource,
    required this.action,
    this.description,
  });

  factory AdminPermission.fromJson(Map<String, dynamic> json) {
    return AdminPermission(
      permissionId: json['permission_id'],
      permissionCode: json['permission_code'],
      resource: json['resource'],
      action: json['action'],
      description: json['description'],
    );
  }
}

/// Permissions Data with Grouping
class AdminPermissionsData {
  final List<AdminPermission> permissions;
  final Map<String, List<AdminPermission>> grouped;
  final int total;

  AdminPermissionsData({
    required this.permissions,
    required this.grouped,
    required this.total,
  });

  factory AdminPermissionsData.fromJson(Map<String, dynamic> json) {
    final permissions = (json['permissions'] as List)
        .map((p) => AdminPermission.fromJson(p))
        .toList();

    final grouped = <String, List<AdminPermission>>{};
    (json['grouped'] as Map<String, dynamic>).forEach((key, value) {
      grouped[key] = (value as List)
          .map((p) => AdminPermission.fromJson(p))
          .toList();
    });

    return AdminPermissionsData(
      permissions: permissions,
      grouped: grouped,
      total: json['total'],
    );
  }
}

/// Permission Matrix
class PermissionMatrix {
  final List<AdminRole> roles;
  final List<AdminPermission> permissions;
  final Map<String, Map<String, bool>> matrix;

  PermissionMatrix({
    required this.roles,
    required this.permissions,
    required this.matrix,
  });

  factory PermissionMatrix.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List)
        .map((r) => AdminRole.fromJson(r))
        .toList();

    final permissions = (json['permissions'] as List)
        .map((p) => AdminPermission.fromJson(p))
        .toList();

    final matrix = <String, Map<String, bool>>{};
    (json['matrix'] as Map<String, dynamic>).forEach((roleCode, perms) {
      matrix[roleCode] = {};
      (perms as Map<String, dynamic>).forEach((permCode, hasPermission) {
        matrix[roleCode]![permCode] = hasPermission as bool;
      });
    });

    return PermissionMatrix(
      roles: roles,
      permissions: permissions,
      matrix: matrix,
    );
  }

  /// เช็คว่า role มี permission หรือไม่
  bool hasPermission(String roleCode, String permissionCode) {
    return matrix[roleCode]?[permissionCode] ?? false;
  }
}

/// Admin Statistics
class AdminStats {
  final int totalUsers;
  final int activeUsers;
  final int totalRoles;
  final int totalPermissions;
  final List<RoleUserCount> usersByRole;

  AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalRoles,
    required this.totalPermissions,
    required this.usersByRole,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      totalRoles: json['total_roles'] ?? 0,
      totalPermissions: json['total_permissions'] ?? 0,
      usersByRole: (json['users_by_role'] as List?)
              ?.map((r) => RoleUserCount.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class RoleUserCount {
  final String role;
  final String roleCode;
  final int count;

  RoleUserCount({
    required this.role,
    required this.roleCode,
    required this.count,
  });

  factory RoleUserCount.fromJson(Map<String, dynamic> json) {
    return RoleUserCount(
      role: json['role'],
      roleCode: json['role_code'] ?? json['role'], // fallback to role if role_code not available
      count: json['count'],
    );
  }
}
