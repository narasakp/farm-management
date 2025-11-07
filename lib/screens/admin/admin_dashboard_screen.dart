import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/admin_service.dart';
import '../../providers/production_auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/tab_navigation_mixin.dart';
import 'admin_users_new_screen.dart';

/// RBAC Admin Dashboard Screen
/// สำหรับ SUPER_ADMIN จัดการ Users, Roles, และ Permissions
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin, TabNavigationMixin {
  late TabController _tabController;
  
  // Data
  List<AdminUser> users = [];
  List<AdminRole> roles = [];
  PermissionMatrix? permissionMatrix;
  AdminStats? stats;
  
  // Loading states
  bool isLoadingUsers = false;
  bool isLoadingRoles = false;
  bool isLoadingMatrix = false;
  bool isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // เริ่มต้น Tab Navigation (ใช้ mixin)
    initTabNavigation(_tabController, initialTab: 0, fallbackRoute: '/dashboard');
    
    _loadInitialData();
  }

  @override
  void dispose() {
    disposeTabNavigation(); // ปิด Tab Navigation (ใช้ mixin)
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authState = ref.read(productionAuthProvider);
    final token = authState.accessToken;

    if (token == null) return;

    // Load all data in parallel
    await Future.wait([
      _loadUsers(token),
      _loadRoles(token),
      _loadStats(token),
    ]);
  }

  Future<void> _loadUsers(String token) async {
    setState(() => isLoadingUsers = true);
    final result = await AdminService.getAllUsers(token);
    if (result != null && mounted) {
      setState(() {
        users = result;
        isLoadingUsers = false;
      });
    } else if (mounted) {
      setState(() => isLoadingUsers = false);
    }
  }

  Future<void> _loadRoles(String token) async {
    setState(() => isLoadingRoles = true);
    final result = await AdminService.getAllRoles(token);
    if (result != null && mounted) {
      setState(() {
        roles = result;
        isLoadingRoles = false;
      });
    } else if (mounted) {
      setState(() => isLoadingRoles = false);
    }
  }

  Future<void> _loadPermissionMatrix(String token) async {
    setState(() => isLoadingMatrix = true);
    final result = await AdminService.getPermissionMatrix(token);
    if (result != null && mounted) {
      setState(() {
        permissionMatrix = result;
        isLoadingMatrix = false;
      });
    } else if (mounted) {
      setState(() => isLoadingMatrix = false);
    }
  }

  Future<void> _loadStats(String token) async {
    setState(() => isLoadingStats = true);
    final result = await AdminService.getStats(token);
    if (result != null && mounted) {
      setState(() {
        stats = result;
        isLoadingStats = false;
      });
    } else if (mounted) {
      setState(() => isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RBAC Admin Dashboard'),
        backgroundColor: const Color(0xFFDC143C), // สีแดงเข้ม - เน้นข้อมูล Sensitive
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => handleSmartBackPress(),
          tooltip: backButtonTooltip, // ใช้ tooltip จาก mixin
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ออกจากระบบ?'),
                  content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
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
                      child: const Text('ออกจากระบบ'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(productionAuthProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
            tooltip: 'ออกจากระบบ',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'ภาพรวม'),
            Tab(icon: Icon(Icons.people), text: 'ผู้ใช้งาน'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Roles'),
            Tab(icon: Icon(Icons.grid_on), text: 'Permission Matrix'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          AdminUsersNewScreen(),
          _buildRolesTab(),
          _buildPermissionMatrixTab(),
        ],
      ),
    );
  }

  // ==================== OVERVIEW TAB ====================

  Widget _buildOverviewTab() {
    if (isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (stats == null) {
      return const Center(child: Text('ไม่สามารถโหลดข้อมูลได้'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สถิติภาพรวม',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'ผู้ใช้งานทั้งหมด',
                  '${stats!.totalUsers}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'ผู้ใช้งานที่ Active',
                  '${stats!.activeUsers}',
                  Icons.verified_user,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Roles ทั้งหมด',
                  '${stats!.totalRoles}',
                  Icons.admin_panel_settings,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Permissions ทั้งหมด',
                  '${stats!.totalPermissions}',
                  Icons.security,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions Section
          Text(
            'การจัดการ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // Contact Settings Card
          Card(
            elevation: 2,
            child: InkWell(
              onTap: () => context.go('/admin-contact-settings'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.contact_support,
                        color: Color(0xFF1976D2),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ตั้งค่าข้อมูลติดต่อผู้ดูแลระบบ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'จัดการข้อมูลติดต่อที่แสดงในระบบ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF8B4513),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Users by Role
          Text(
            'ผู้ใช้งานแต่ละ Role',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: stats!.usersByRole.map((roleCount) {
                  return InkWell(
                    onTap: () {
                      // Navigate to Users Tab
                      navigateToTab(1);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              roleCount.role,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  '${roleCount.count} คน',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _getRoleColor(roleCount.roleCode),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    // Determine which tab to navigate to
    int? targetTab;
    if (title.contains('ผู้ใช้งาน')) {
      targetTab = 1; // Users Tab
    } else if (title.contains('Roles') || title.contains('Role')) {
      targetTab = 2; // Roles Tab
    } else if (title.contains('Permission')) {
      targetTab = 3; // Permission Matrix Tab
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: targetTab != null
            ? () {
                navigateToTab(targetTab!);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (targetTab != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== USERS TAB ====================

  Color _getRoleColor(String roleCode) {
    switch (roleCode) {
      case 'SUPER_ADMIN':
        return const Color(0xFF5D4037); // น้ำตาลเข้ม (Primary Brown)
      case 'AMPHOE_OFFICER':
      case 'TAMBON_OFFICER':
        return const Color(0xFF1976D2); // น้ำเงินเข้ม (Primary Blue)
      case 'RESEARCHER':
        return const Color(0xFF2E7D32); // เขียวเข้ม (Primary Green)
      case 'GROUP_LEADER':
        return const Color(0xFFFF9800); // ส้ม (Primary Orange)
      default:
        return const Color(0xFF8D6E63); // น้ำตาลอ่อน (Light Brown)
    }
  }

  // ==================== ROLES TAB ====================

  Widget _buildRolesTab() {
    if (isLoadingRoles) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Roles ทั้งหมด (${roles.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  final token = ref.read(productionAuthProvider).accessToken;
                  if (token != null) await _loadRoles(token);
                },
              ),
            ],
          ),
        ),

        // Roles List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return _buildRoleCard(role);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(AdminRole role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getRoleColor(role.roleCode).withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getRoleColor(role.roleCode),
                  _getRoleColor(role.roleCode).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRoleColor(role.roleCode).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'L${role.level}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  role.roleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (role.roleCode == 'SUPER_ADMIN')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield, size: 14, color: Colors.red.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Protected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              if (role.description != null)
                Text(
                  role.description!,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRoleStat(
                    Icons.security,
                    '${role.permissionCount}',
                    'permissions',
                    Colors.blue,
                  ),
                  const SizedBox(width: 24),
                  _buildRoleStat(
                    Icons.people,
                    '${role.userCount}',
                    'users',
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
          trailing: role.roleCode != 'SUPER_ADMIN'
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue.shade700,
                    onPressed: () => _showEditRolePermissionsDialog(role),
                    tooltip: 'แก้ไข Permissions',
                  ),
                )
              : null,
          isThreeLine: true,
        ),
      ),
    );
  }

  Widget _buildRoleStat(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showEditRolePermissionsDialog(AdminRole role) async {
    final token = ref.read(productionAuthProvider).accessToken;
    if (token == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRolePermissionsScreen(
          role: role,
          token: token,
        ),
      ),
    ).then((edited) {
      if (edited == true) {
        _loadRoles(token);
      }
    });
  }

  // ==================== PERMISSION MATRIX TAB ====================

  Widget _buildPermissionMatrixTab() {
    if (permissionMatrix == null && !isLoadingMatrix) {
      // Load matrix when tab is first opened
      final token = ref.read(productionAuthProvider).accessToken;
      if (token != null) {
        _loadPermissionMatrix(token);
      }
    }

    if (isLoadingMatrix) {
      return const Center(child: CircularProgressIndicator());
    }

    if (permissionMatrix == null) {
      return const Center(child: Text('ไม่สามารถโหลด Permission Matrix ได้'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Permission Matrix',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: _buildPermissionMatrixTable(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionMatrixTable() {
    final matrix = permissionMatrix!;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowHeight: 80,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFFDC143C).withOpacity(0.1), // ให้ตรงกับ Header
          ),
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: [
            DataColumn(
              label: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Permission',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            ...matrix.roles.map((role) {
              return DataColumn(
                label: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role.roleCode).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role.roleCode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRoleColor(role.roleCode),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
          rows: matrix.permissions.asMap().entries.map((entry) {
            final index = entry.key;
            final perm = entry.value;
            final isEvenRow = index % 2 == 0;
            
            return DataRow(
              color: MaterialStateProperty.all(
                isEvenRow ? Colors.grey.shade50 : Colors.white,
              ),
              cells: [
                DataCell(
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      perm.permissionCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ...matrix.roles.map((role) {
                  final hasPermission = matrix.hasPermission(
                    role.roleCode,
                    perm.permissionCode,
                  );
                  return DataCell(
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasPermission
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                        ),
                        child: Icon(
                          hasPermission ? Icons.check_circle : Icons.cancel,
                          color: hasPermission
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
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
      
      // ปิด loading
      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        showSuccessSnackBar(context, 'ลบผู้ใช้สำเร็จ');
        await _loadUsers(token);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถลบผู้ใช้ได้ กรุณาลองใหม่'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ==================== EDIT ROLE PERMISSIONS SCREEN ====================

class EditRolePermissionsScreen extends ConsumerStatefulWidget {
  final AdminRole role;
  final String token;

  const EditRolePermissionsScreen({
    Key? key,
    required this.role,
    required this.token,
  }) : super(key: key);

  @override
  ConsumerState<EditRolePermissionsScreen> createState() =>
      _EditRolePermissionsScreenState();
}

class _EditRolePermissionsScreenState
    extends ConsumerState<EditRolePermissionsScreen> {
  AdminPermissionsData? allPermissions;
  List<AdminPermission> rolePermissions = [];
  Set<String> selectedPermissions = {};
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final permsData = await AdminService.getAllPermissions(widget.token);
    final rolePerms = await AdminService.getRolePermissions(
      widget.token,
      widget.role.roleCode,
    );

    if (permsData != null && rolePerms != null && mounted) {
      setState(() {
        allPermissions = permsData;
        rolePermissions = rolePerms;
        selectedPermissions = rolePerms.map((p) => p.permissionCode).toSet();
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _savePermissions() async {
    setState(() => isSaving = true);

    final success = await AdminService.updateRolePermissions(
      widget.token,
      widget.role.roleCode,
      selectedPermissions.toList(),
    );

    if (mounted) {
      setState(() => isSaving = false);

      if (success) {
        showSuccessSnackBar(context, 'บันทึกสำเร็จ');
        Navigator.pop(context, true);
      } else {
        showErrorSnackBar(context, 'บันทึกไม่สำเร็จ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไข Permissions: ${widget.role.roleName}'),
        actions: [
          if (!isLoading && allPermissions != null)
            TextButton.icon(
              onPressed: isSaving ? null : _savePermissions,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('บันทึก'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allPermissions == null
              ? const Center(child: Text('ไม่สามารถโหลดข้อมูลได้'))
              : _buildPermissionsList(),
      bottomNavigationBar: !isLoading && allPermissions != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSaving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('ยกเลิก'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _savePermissions,
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(isSaving ? 'กำลังบันทึก...' : 'บันทึกการเปลี่ยนแปลง'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF228B22),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPermissionsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เลือก Permissions สำหรับ ${widget.role.roleName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('เลือกแล้ว: ${selectedPermissions.length}/${allPermissions!.total}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Permissions grouped by resource
        ...allPermissions!.grouped.entries.map((entry) {
          final resource = entry.key;
          final perms = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                resource.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${perms.length} permissions'),
              children: perms.map((perm) {
                return CheckboxListTile(
                  title: Text(perm.permissionCode),
                  subtitle: Text(perm.description ?? ''),
                  value: selectedPermissions.contains(perm.permissionCode),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedPermissions.add(perm.permissionCode);
                      } else {
                        selectedPermissions.remove(perm.permissionCode);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
