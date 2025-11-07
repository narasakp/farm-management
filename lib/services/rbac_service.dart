import 'dart:convert';
import 'package:http/http.dart' as http;

/// RBAC Service
/// จัดการการตรวจสอบ Permissions และ Roles
class RbacService {
  static const String baseUrl = 'http://localhost:3000/api/rbac';

  /// ดึงข้อมูล permissions ของผู้ใช้ปัจจุบัน
  static Future<UserPermissions?> getMyPermissions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me/permissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserPermissions.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error getting permissions: $e');
      return null;
    }
  }

  /// ตรวจสอบว่ามี permission หรือไม่
  static Future<bool> checkPermission(
    String token,
    String permissionCode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-permission'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'permission_code': permissionCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['has_permission'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  /// ดึงรายการ roles ทั้งหมด
  static Future<List<Role>> getRoles(String token) async {
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
        final List<dynamic> rolesJson = data['data'];
        return rolesJson.map((json) => Role.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting roles: $e');
      return [];
    }
  }

  /// ดึง permissions ของ role
  static Future<List<Permission>> getRolePermissions(
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
        final List<dynamic> permissionsJson = data['permissions'];
        return permissionsJson
            .map((json) => Permission.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting role permissions: $e');
      return [];
    }
  }

  /// เปลี่ยน role ของผู้ใช้
  static Future<bool> updateUserRole(
    String token,
    int userId,
    String role, {
    String? tambonCode,
    String? amphoeCode,
    String? provinceCode,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/role'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'role': role,
          'tambon_code': tambonCode,
          'amphoe_code': amphoeCode,
          'province_code': provinceCode,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  /// ดึง audit logs
  static Future<List<AuditLog>> getAuditLogs(
    String token, {
    int limit = 100,
    int offset = 0,
    int? userId,
    String? action,
    String? resource,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (userId != null) 'user_id': userId.toString(),
        if (action != null) 'action': action,
        if (resource != null) 'resource': resource,
      };

      final uri = Uri.parse('$baseUrl/audit-logs')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> logsJson = data['data'];
        return logsJson.map((json) => AuditLog.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting audit logs: $e');
      return [];
    }
  }
}

/// User Permissions Model
class UserPermissions {
  final int userId;
  final String username;
  final String role;
  final String roleName;
  final int level;
  final String? tambonCode;
  final String? amphoeCode;
  final String? provinceCode;
  final List<Permission> permissions;

  UserPermissions({
    required this.userId,
    required this.username,
    required this.role,
    required this.roleName,
    required this.level,
    this.tambonCode,
    this.amphoeCode,
    this.provinceCode,
    required this.permissions,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      userId: json['user_id'],
      username: json['username'],
      role: json['role'],
      roleName: json['role_name'],
      level: json['level'],
      tambonCode: json['tambon_code'],
      amphoeCode: json['amphoe_code'],
      provinceCode: json['province_code'],
      permissions: (json['permissions'] as List)
          .map((p) => Permission.fromJson(p))
          .toList(),
    );
  }

  /// ตรวจสอบว่ามี permission หรือไม่
  bool hasPermission(String permissionCode) {
    return permissions.any((p) => p.code == permissionCode);
  }

  /// ตรวจสอบว่ามีหลาย permissions หรือไม่
  bool hasAllPermissions(List<String> permissionCodes) {
    return permissionCodes.every((code) => hasPermission(code));
  }

  /// ตรวจสอบว่ามีอย่างน้อย 1 permission
  bool hasAnyPermission(List<String> permissionCodes) {
    return permissionCodes.any((code) => hasPermission(code));
  }

  /// ตรวจสอบว่ามีสิทธิ์เข้าถึง resource หรือไม่
  bool canAccess(String resource, String action) {
    return permissions.any(
      (p) => p.resource == resource && p.action == action,
    );
  }

  /// ตรวจสอบว่าเป็น Admin หรือไม่
  bool get isAdmin => role == 'SUPER_ADMIN';

  /// ตรวจสอบว่าเป็นเจ้าหน้าที่อำเภอหรือไม่
  bool get isAmphoeOfficer => role == 'AMPHOE_OFFICER';

  /// ตรวจสอบว่าเป็นเจ้าหน้าที่ตำบลหรือไม่
  bool get isTambonOfficer => role == 'TAMBON_OFFICER';

  /// ตรวจสอบว่าเป็นเกษตรกรหรือไม่
  bool get isFarmer => role == 'FARMER';

  /// ตรวจสอบว่าเป็นนักวิจัยหรือไม่
  bool get isResearcher => role == 'RESEARCHER';

  /// ตรวจสอบว่าเป็นพ่อค้าหรือไม่
  bool get isTrader => role == 'TRADER';

  /// ตรวจสอบว่าเป็นผู้ขนส่งหรือไม่
  bool get isTransporter => role == 'TRANSPORTER';

  /// ตรวจสอบว่าเป็นผู้นำกลุ่มหรือไม่
  bool get isGroupLeader => role == 'GROUP_LEADER';
}

/// Permission Model
class Permission {
  final String code;
  final String resource;
  final String action;

  Permission({
    required this.code,
    required this.resource,
    required this.action,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      code: json['code'],
      resource: json['resource'],
      action: json['action'],
    );
  }
}

/// Role Model
class Role {
  final int roleId;
  final String roleName;
  final String roleCode;
  final String? description;
  final int level;
  final bool isActive;
  final int? permissionCount;

  Role({
    required this.roleId,
    required this.roleName,
    required this.roleCode,
    this.description,
    required this.level,
    required this.isActive,
    this.permissionCount,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['role_id'],
      roleName: json['role_name'],
      roleCode: json['role_code'],
      description: json['description'],
      level: json['level'],
      isActive: json['is_active'] == 1,
      permissionCount: json['permission_count'],
    );
  }
}

/// Audit Log Model
class AuditLog {
  final int logId;
  final int? userId;
  final String? username;
  final String? role;
  final String action;
  final String? resource;
  final int? resourceId;
  final String? details;
  final String? ipAddress;
  final String? userAgent;
  final bool success;
  final DateTime createdAt;

  AuditLog({
    required this.logId,
    this.userId,
    this.username,
    this.role,
    required this.action,
    this.resource,
    this.resourceId,
    this.details,
    this.ipAddress,
    this.userAgent,
    required this.success,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      logId: json['log_id'],
      userId: json['user_id'],
      username: json['username'],
      role: json['role'],
      action: json['action'],
      resource: json['resource'],
      resourceId: json['resource_id'],
      details: json['details'],
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      success: json['success'] == 1,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
