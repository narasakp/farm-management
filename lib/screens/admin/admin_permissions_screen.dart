import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/admin_service.dart';
import '../../providers/production_auth_provider.dart';
import '../../widgets/app_bars/standard_app_bar.dart';

/// Permission Matrix Screen
class AdminPermissionsScreen extends ConsumerStatefulWidget {
  const AdminPermissionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends ConsumerState<AdminPermissionsScreen> {
  PermissionMatrix? permissionMatrix;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMatrix();
  }

  Future<void> _loadMatrix() async {
    final token = ref.read(productionAuthProvider).accessToken;
    if (token == null) return;

    setState(() => isLoading = true);
    final result = await AdminService.getPermissionMatrix(token);
    
    if (result != null && mounted) {
      setState(() {
        permissionMatrix = result;
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
        title: 'Permission Matrix',
        onBackPressed: () => context.go('/admin-dashboard'),
        showSearch: false,  // ไม่มี search icon
        customActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatrix,
            tooltip: 'รีเฟรช',
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : permissionMatrix == null
              ? const Center(child: Text('ไม่สามารถโหลดข้อมูลได้'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'สิทธิ์การเข้าถึงแต่ละ Role',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildPermissionMatrixTable(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPermissionMatrixTable() {
    final matrix = permissionMatrix!;

    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
      columnSpacing: 20,
      columns: [
        const DataColumn(
          label: SizedBox(
            width: 200,
            child: Text(
              'Permission',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...matrix.roles.map((role) {
          return DataColumn(
            label: RotatedBox(
              quarterTurns: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  role.roleCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
      rows: matrix.permissions.map((perm) {
        return DataRow(
          cells: [
            DataCell(
              SizedBox(
                width: 200,
                child: Text(
                  perm.permissionCode,
                  style: const TextStyle(fontSize: 12),
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
                  child: Icon(
                    hasPermission ? Icons.check_circle : Icons.cancel,
                    color: hasPermission ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}
