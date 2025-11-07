import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/admin_service.dart';
import '../../providers/production_auth_provider.dart';
import '../../widgets/app_bars/standard_app_bar.dart';

/// จัดการ Roles Screen
class AdminRolesScreen extends ConsumerStatefulWidget {
  const AdminRolesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends ConsumerState<AdminRolesScreen> {
  List<AdminRole> roles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final token = ref.read(productionAuthProvider).accessToken;
    if (token == null) return;

    setState(() => isLoading = true);
    final result = await AdminService.getAllRoles(token);
    
    if (result != null && mounted) {
      setState(() {
        roles = result;
        isLoading = false;
      });
    } else if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,  // ชั้นที่ 1: Admin screen
        title: 'จัดการ Roles',
        onBackPressed: () => context.go('/admin-dashboard'),
        showSearch: false,  // ไม่มี search icon
        customActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoles,
            tooltip: 'รีเฟรช',
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Roles ทั้งหมด: ${roles.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
            ),
    );
  }

  Widget _buildRoleCard(AdminRole role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role.roleCode),
          child: Text(
            'L${role.level}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          role.roleName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (role.description != null)
              Text(role.description!),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.security, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${role.permissionCount ?? 0} permissions'),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('${role.userCount ?? 0} users'),
              ],
            ),
          ],
        ),
        trailing: role.roleCode != 'SUPER_ADMIN'
            ? const Icon(Icons.chevron_right)
            : const Chip(
                label: Text('Protected', style: TextStyle(fontSize: 11)),
                padding: EdgeInsets.symmetric(horizontal: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
        onTap: role.roleCode != 'SUPER_ADMIN'
            ? () => _showRoleDetails(role)
            : null,
        isThreeLine: true,
      ),
    );
  }

  Color _getRoleColor(String roleCode) {
    switch (roleCode) {
      case 'SUPER_ADMIN':
        return Colors.red.shade700;
      case 'AMPHOE_OFFICER':
      case 'TAMBON_OFFICER':
        return Colors.blue.shade700;
      case 'RESEARCHER':
        return Colors.purple.shade700;
      case 'GROUP_LEADER':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _showRoleDetails(AdminRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(role.roleName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Role Code', role.roleCode),
            _buildDetailRow('Level', role.level.toString()),
            _buildDetailRow('Permissions', '${role.permissionCount ?? 0}'),
            _buildDetailRow('Users', '${role.userCount ?? 0}'),
            _buildDetailRow('Status', role.isActive ? 'Active' : 'Inactive'),
            if (role.description != null)
              _buildDetailRow('Description', role.description!),
          ],
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
}
