import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/production_auth_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/standard_snackbar.dart';

class AdminUsersNewScreen extends ConsumerStatefulWidget {
  const AdminUsersNewScreen({super.key});

  @override
  ConsumerState<AdminUsersNewScreen> createState() => _AdminUsersNewScreenState();
}

class _AdminUsersNewScreenState extends ConsumerState<AdminUsersNewScreen> {
  List<AdminUser> _users = [];
  List<AdminRole> _roles = [];
  bool _isLoading = false;
  String? _filterByRole; // null = แสดงทั้งหมด

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    final authState = ref.read(productionAuthProvider);
    if (authState.accessToken != null) {
      final token = authState.accessToken!;
      
      // โหลด users และ roles พร้อมกัน
      final results = await Future.wait([
        AdminService.getAllUsers(token),
        AdminService.getAllRoles(token),
      ]);
      
      if (mounted) {
        setState(() {
          _users = results[0] as List<AdminUser>? ?? [];
          _roles = results[1] as List<AdminRole>? ?? [];
          _isLoading = false;
        });
        print('✅ [NEW SCREEN] Loaded ${_users.length} users, ${_roles.length} roles');
        for (var user in _users.take(3)) {
          print('✅ [NEW SCREEN] User: ${user.username}, Email: ${user.email}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // กรองผู้ใช้ตาม role
    final filteredUsers = _filterByRole == null
        ? _users
        : _users.where((user) => user.role == _filterByRole).toList();

    return Column(
      children: [
          // Header - Minimal Design
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                // จำนวนผู้ใช้
                Expanded(
                  child: Text(
                    _filterByRole == null
                        ? 'ผู้ใช้งานทั้งหมด (${_users.length})'
                        : 'ผู้ใช้งาน: ${_getRoleNameByCode(_filterByRole!)} (${filteredUsers.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                // ปุ่มตัวกรอง
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _filterByRole != null ? Colors.blue : Colors.grey.shade700,
                    size: 22,
                  ),
                  onPressed: _showFilterDialog,
                  tooltip: 'ตัวกรอง',
                ),
                // ปุ่ม Refresh
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                  onPressed: _loadUsers,
                  tooltip: 'รีเฟรช',
                ),
              ],
            ),
          ),
          
          // User List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              'ไม่พบผู้ใช้งาน',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                            if (_filterByRole != null) ...[
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() => _filterByRole = null);
                                },
                                child: Text('แสดงทั้งหมด'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display Name + Role Badge + Menu
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.displayName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user.role),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.roleName ?? user.role,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Menu 3 จุด
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) => _handleMenuAction(value, user),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'change_role',
                                  child: Row(
                                    children: [
                                      Icon(Icons.swap_horiz, size: 20),
                                      SizedBox(width: 12),
                                      Text('เปลี่ยน Role'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'toggle_status',
                                  child: Row(
                                    children: [
                                      Icon(
                                        user.isActive ? Icons.cancel : Icons.check_circle,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(user.isActive ? 'ปิดการใช้งาน' : 'เปิดการใช้งาน'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'view_details',
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 20),
                                      SizedBox(width: 12),
                                      Text('ดูรายละเอียด'),
                                    ],
                                  ),
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text('ลบผู้ใช้', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 12),
                        
                        // Username
                        _buildInfoRow(Icons.person, 'Username', '@${user.username}'),
                        SizedBox(height: 8),
                        
                        // Email - แสดงชัดเจน
                        _buildInfoRow(
                          Icons.email,
                          'อีเมล',
                          user.email ?? 'ไม่มีอีเมล',
                          valueColor: user.email != null ? Colors.blue.shade700 : Colors.red.shade600,
                        ),
                        SizedBox(height: 8),
                        
                        // Phone
                        if (user.phone != null)
                          _buildInfoRow(Icons.phone, 'เบอร์โทร', user.phone!),
                        
                        // Status
                        if (user.phone != null) SizedBox(height: 8),
                        _buildInfoRow(
                          user.isActive ? Icons.check_circle : Icons.cancel,
                          'สถานะ',
                          user.isActive ? 'ใช้งาน' : 'ระงับ',
                          valueColor: user.isActive ? Colors.green : Colors.red,
                        ),
                        
                        SizedBox(height: 8),
                        
                        // Created Date
                        _buildInfoRow(Icons.calendar_today, 'สร้างเมื่อ', _formatDate(user.createdAt)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
  }

  // ==================== FILTER DIALOG ====================

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ตัวกรองผู้ใช้งาน'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.people, color: Colors.grey.shade700),
                title: Text('ทั้งหมด (${_users.length})'),
                trailing: _filterByRole == null ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() => _filterByRole = null);
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ..._roles.map((role) {
                final isSelected = _filterByRole == role.roleCode;
                // นับจำนวนผู้ใช้ที่มี role นี้
                final userCount = _users.where((u) => u.role == role.roleCode).length;
                
                return ListTile(
                  leading: Icon(
                    Icons.badge,
                    color: _getRoleColor(role.roleCode),
                  ),
                  title: Text('${role.roleName} ($userCount)'),
                  trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    setState(() => _filterByRole = role.roleCode);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ปิด'),
          ),
        ],
      ),
    );
  }

  String _getRoleNameByCode(String roleCode) {
    final role = _roles.firstWhere(
      (r) => r.roleCode == roleCode,
      orElse: () => AdminRole(
        roleId: 0,
        roleCode: roleCode,
        roleName: roleCode,
        level: 0,
        isActive: true,
        permissionCount: 0,
        userCount: 0,
      ),
    );
    return role.roleName;
  }

  // ==================== MENU ACTIONS ====================

  Future<void> _handleMenuAction(String action, AdminUser user) async {
    print('🔍 [DEBUG] Menu action: $action for user: ${user.username}');
    
    final authState = ref.read(productionAuthProvider);
    final token = authState.accessToken;
    if (token == null) {
      print('❌ [DEBUG] No access token!');
      return;
    }

    print('✅ [DEBUG] Token: ${token.substring(0, 20)}...');

    switch (action) {
      case 'change_role':
        print('🔄 [DEBUG] Opening change role dialog');
        await _showChangeRoleDialog(token, user);
        break;
      case 'toggle_status':
        print('🔄 [DEBUG] Toggling user status');
        await _toggleUserStatus(token, user);
        break;
      case 'view_details':
        print('🔍 [DEBUG] Showing user details');
        await _showUserDetailsDialog(token, user);
        break;
      case 'delete':
        print('🗑️ [DEBUG] Deleting user');
        await _deleteUser(token, user);
        break;
    }
  }

  Future<void> _showChangeRoleDialog(String token, AdminUser user) async {
    String? selectedRole = user.role;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เปลี่ยน Role: ${user.displayName}'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Role ปัจจุบัน: ${user.roleName ?? user.role}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role ใหม่',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role.roleCode,
                    child: Text(role.roleName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedRole = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedRole),
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (result != null && result != user.role) {
      print('🔄 [DEBUG] Changing role from ${user.role} to $result for user ID: ${user.id}');
      final success = await AdminService.changeUserRole(token, user.id, result);
      print('✅ [DEBUG] Change role result: $success');
      
      if (success && mounted) {
        StandardSnackbar.showSuccess(context, 'เปลี่ยน Role สำเร็จ');
        await _loadUsers();
      } else if (!success && mounted) {
        StandardSnackbar.showError(context, 'ไม่สามารถเปลี่ยน Role ได้');
      }
    }
  }

  Future<void> _toggleUserStatus(String token, AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'ปิดการใช้งาน?' : 'เปิดการใช้งาน?'),
        content: Text(
          user.isActive
              ? 'คุณต้องการปิดการใช้งาน ${user.displayName} หรือไม่?'
              : 'คุณต้องการเปิดการใช้งาน ${user.displayName} หรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.red : Colors.green,
            ),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print('🔄 [DEBUG] Toggling status for user ID: ${user.id}, current: ${user.isActive}, new: ${!user.isActive}');
      final success = await AdminService.toggleUserStatus(
        token,
        user.id,
        !user.isActive,
      );
      print('✅ [DEBUG] Toggle status result: $success');
      
      if (success && mounted) {
        StandardSnackbar.showSuccess(
          context,
          user.isActive ? 'ปิดการใช้งานสำเร็จ' : 'เปิดการใช้งานสำเร็จ',
        );
        await _loadUsers();
      } else if (!success && mounted) {
        StandardSnackbar.showError(context, 'ไม่สามารถเปลี่ยนสถานะได้');
      }
    }
  }

  Future<void> _showUserDetailsDialog(String token, AdminUser user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Username', user.username),
              _buildDetailRow('Email', user.email ?? '-'),
              _buildDetailRow('Phone', user.phone ?? '-'),
              _buildDetailRow('Role', user.roleName ?? user.role),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Verified', user.isVerified ? 'Yes' : 'No'),
              _buildDetailRow('จังหวัด', user.provinceCode ?? '-'),
              _buildDetailRow('อำเภอ', user.amphoeCode ?? '-'),
              _buildDetailRow('ตำบล', user.tambonCode ?? '-'),
              _buildDetailRow('สร้างเมื่อ', user.createdAt),
              _buildDetailRow('Login ล่าสุด', user.lastLoginAt ?? 'Never'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String token, AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('ยืนยันการลบผู้ใช้'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณต้องการลบผู้ใช้ "${user.displayName}" (@${user.username}) หรือไม่?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'คำเตือน',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• จะลบข้อมูลที่เกี่ยวข้องทั้งหมด',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '• ไม่สามารถกู้คืนได้',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '• กรุณาตรวจสอบให้แน่ใจก่อนดำเนินการ',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลบผู้ใช้'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print('🗑️ [DEBUG] Deleting user ID: ${user.id}, username: ${user.username}');
      
      // แสดง loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final success = await AdminService.deleteUser(token, user.id);
      print('✅ [DEBUG] Delete user result: $success');
      
      // ปิด loading
      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        StandardSnackbar.showSuccess(context, 'ลบผู้ใช้สำเร็จ');
        await _loadUsers();
      } else if (mounted) {
        print('❌ [DEBUG] Delete failed! success=$success');
        StandardSnackbar.showError(context, 'ไม่สามารถลบผู้ใช้ได้');
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return Colors.purple.shade700;
      case 'OFFICER_AMPHOE':
        return Colors.blue.shade700;
      case 'OFFICER_TAMBON':
        return Colors.blue.shade500;
      case 'GROUP_LEADER':
        return Colors.orange.shade600;
      case 'TRADER':
        return Colors.brown.shade600;
      case 'TRANSPORTER':
        return Colors.teal.shade600;
      case 'RESEARCHER':
        return Colors.indigo.shade600;
      default:
        return Colors.green.shade600;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
