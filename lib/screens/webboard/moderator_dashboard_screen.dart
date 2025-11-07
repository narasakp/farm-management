import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/webboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/thread.dart';
import '../../widgets/app_bars/standard_app_bar.dart';
import '../../widgets/standard_snackbar.dart';
import '../../widgets/ban_user_dialog.dart';
import '../../utils/app_theme.dart';
import '../../config/api_config.dart';

class ModeratorDashboardScreen extends StatefulWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  State<ModeratorDashboardScreen> createState() => _ModeratorDashboardScreenState();
}

class _ModeratorDashboardScreenState extends State<ModeratorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _bannedUsers = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadModeratorData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadModeratorData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load reports
      final reportsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/moderator/reports?status=pending'),
      );

      // Load banned users
      final bannedUsersResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/moderator/banned-users'),
      );

      // Load stats
      final statsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/moderator/stats'),
      );

      if (mounted) {
        setState(() {
          if (reportsResponse.statusCode == 200) {
            final reportsData = json.decode(reportsResponse.body);
            _reports = List<Map<String, dynamic>>.from(reportsData['reports'] ?? []);
          }

          if (bannedUsersResponse.statusCode == 200) {
            final bannedData = json.decode(bannedUsersResponse.body);
            _bannedUsers = List<Map<String, dynamic>>.from(bannedData['bans'] ?? []);
          }

          if (statsResponse.statusCode == 200) {
            final statsData = json.decode(statsResponse.body);
            _stats = statsData['stats'] ?? {};
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading moderator data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    
    // Check if user is admin/moderator
    if (user?.role != 'ADMIN' && user?.role != 'MODERATOR') {
      return Scaffold(
        appBar: const StandardAppBar(
          type: AppBarType.main,
          title: 'Moderator Dashboard',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'คุณไม่มีสิทธิ์เข้าถึงหน้านี้',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: StandardAppBar(
        type: AppBarType.main,
        title: 'Moderator Dashboard',
        customActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModeratorData,
            tooltip: 'รีเฟรช',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.report), text: 'รายงาน'),
            Tab(icon: Icon(Icons.block), text: 'ผู้ใช้ที่ถูกแบน'),
            Tab(icon: Icon(Icons.analytics), text: 'สถิติ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          _buildBannedUsersTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            Text(
              'ไม่มีรายงานที่รอดำเนินการ',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report['type'] ?? 'ไม่ระบุ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  report['created_at'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report['title'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report['reason'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'รายงานโดย: ${report['reporter_name'] ?? 'ไม่ระบุ'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (report['description'] != null && report['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'รายละเอียด: ${report['description']}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _viewReportedContent(report),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('ดูเนื้อหา'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _banUserFromReport(report),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('แบนผู้ใช้'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteReportedContent(report),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('ลบเนื้อหา'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _dismissReport(report),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('ยกเลิกรายงาน'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannedUsersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bannedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'ไม่มีผู้ใช้ที่ถูกแบน',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bannedUsers.length,
      itemBuilder: (context, index) {
        final user = _bannedUsers[index];
        return _buildBannedUserCard(user);
      },
    );
  }

  Widget _buildBannedUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user['username']?[0].toUpperCase() ?? '?'),
        ),
        title: Text(user['username'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เหตุผล: ${user['ban_reason'] ?? 'ไม่ระบุ'}'),
            Text(
              'แบนจนถึง: ${user['ban_until'] ?? 'ถาวร'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _unbanUser(user['user_id'], user['username']),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('ปลดแบน'),
        ),
      ),
    );
  }

  Future<void> _unbanUser(String userId, String username) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการปลดแบน'),
        content: Text('คุณต้องการปลดแบนผู้ใช้ "$username" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('ปลดแบน'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/moderator/unban-user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'unbannedBy': currentUser.id.toString(),
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          StandardSnackbar.showSuccess(context, 'ปลดแบนผู้ใช้สำเร็จ');
          await _loadModeratorData();
        } else {
          StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
        }
      }
    } catch (e) {
      print('Error unbanning user: $e');
      if (mounted) {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
      }
    }
  }

  Future<void> _viewReportedContent(Map<String, dynamic> report) async {
    final contentType = report['content_type'];
    final contentId = report['content_id'];

    if (contentType == 'thread') {
      context.push('/thread/$contentId');
    } else if (contentType == 'reply') {
      // Need to get thread_id from reply
      // For now, show error
      StandardSnackbar.showInfo(context, 'กรุณาไปดูในหน้ากระทู้โดยตรง');
    }
  }

  Future<void> _banUserFromReport(Map<String, dynamic> report) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    // Get reported user info from content
    // For now, use reporter_id as placeholder (should fetch from content)
    final userId = report['reporter_id']; // TODO: Get actual content author
    final username = report['reporter_name']; // TODO: Get actual content author name

    showDialog(
      context: context,
      builder: (context) => BanUserDialog(
        userId: userId,
        username: username,
        onBan: (reason, banType, banUntil) async {
          try {
            final response = await http.post(
              Uri.parse('${ApiConfig.baseUrl}/api/moderator/ban-user'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'userId': userId,
                'username': username,
                'bannedBy': currentUser.id.toString(),
                'reason': reason,
                'banType': banType,
                'banUntil': banUntil,
              }),
            );

            if (mounted) {
              if (response.statusCode == 200) {
                StandardSnackbar.showSuccess(context, 'แบนผู้ใช้สำเร็จ');
                await _reviewReport(report['id'], 'banned');
                await _loadModeratorData();
              } else {
                StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
              }
            }
          } catch (e) {
            print('Error banning user: $e');
            if (mounted) {
              StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteReportedContent(Map<String, dynamic> report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบเนื้อหานี้หรือไม่?'),
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
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final contentType = report['content_type'];
      final contentId = report['content_id'];
      final endpoint = contentType == 'thread' 
        ? '/api/forum/threads/$contentId'
        : '/api/forum/replies/$contentId';

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          StandardSnackbar.showSuccess(context, 'ลบเนื้อหาสำเร็จ');
          await _reviewReport(report['id'], 'deleted');
          await _loadModeratorData();
        } else {
          StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
        }
      }
    } catch (e) {
      print('Error deleting content: $e');
      if (mounted) {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
      }
    }
  }

  Future<void> _dismissReport(Map<String, dynamic> report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกรายงาน'),
        content: const Text('คุณต้องการยกเลิกรายงานนี้หรือไม่? (ไม่มีการดำเนินการ)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _reviewReport(report['id'], 'dismissed');
      if (mounted) {
        StandardSnackbar.showSuccess(context, 'ยกเลิกรายงานสำเร็จ');
        await _loadModeratorData();
      }
    } catch (e) {
      print('Error dismissing report: $e');
      if (mounted) {
        StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
      }
    }
  }

  Future<void> _reviewReport(String reportId, String action) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return;

    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/moderator/reports/$reportId/review'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': action,
        'reviewerId': currentUser.id.toString(),
      }),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สถิติการดูแล',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'รายงานที่รอดำเนินการ',
            '${_stats['pendingReports'] ?? 0}',
            Icons.report_problem,
            Colors.orange,
          ),
          _buildStatCard(
            'กระทู้ที่ถูกลบ',
            '${_stats['deletedThreads'] ?? 0}',
            Icons.delete,
            Colors.red,
          ),
          _buildStatCard(
            'ผู้ใช้ที่ถูกแบน',
            '${_stats['bannedUsers'] ?? 0}',
            Icons.block,
            Colors.red,
          ),
          _buildStatCard(
            'การดำเนินการวันนี้',
            '${_stats['actionsToday'] ?? 0}',
            Icons.today,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
