import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farmer_group_provider.dart';
import '../../models/farmer_group.dart';
import '../../utils/app_theme.dart';

class FarmerGroupScreen extends StatefulWidget {
  const FarmerGroupScreen({super.key});

  @override
  State<FarmerGroupScreen> createState() => _FarmerGroupScreenState();
}

class _FarmerGroupScreenState extends State<FarmerGroupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerGroupProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กลุ่มเกษตรกร'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'กลุ่ม', icon: Icon(Icons.groups)),
            Tab(text: 'สมาชิก', icon: Icon(Icons.people)),
            Tab(text: 'กิจกรรม', icon: Icon(Icons.event)),
            Tab(text: 'กองทุน', icon: Icon(Icons.account_balance)),
            Tab(text: 'สถิติ', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Consumer<FarmerGroupProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadData(),
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildGroupsTab(provider),
              _buildMembersTab(provider),
              _buildActivitiesTab(provider),
              _buildFundsTab(provider),
              _buildStatisticsTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGroupsTab(FarmerGroupProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.activeGroups.length,
        itemBuilder: (context, index) {
          final group = provider.activeGroups[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  group.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.description),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${group.memberCount} คน'),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${group.tambon}, ${group.amphoe}'),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('ดูรายละเอียด')),
                  const PopupMenuItem(value: 'edit', child: Text('แก้ไข')),
                  const PopupMenuItem(value: 'members', child: Text('จัดการสมาชิก')),
                ],
                onSelected: (value) {
                  setState(() => _selectedGroupId = group.id);
                  switch (value) {
                    case 'view':
                      _showGroupDetails(group);
                      break;
                    case 'edit':
                      _showEditGroupDialog(group);
                      break;
                    case 'members':
                      _tabController.animateTo(1);
                      break;
                  }
                },
              ),
              onTap: () {
                setState(() => _selectedGroupId = group.id);
                _showGroupDetails(group);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMembersTab(FarmerGroupProvider provider) {
    final members = _selectedGroupId != null
        ? provider.getMembersByGroup(_selectedGroupId!)
        : <GroupMember>[];

    return Column(
      children: [
        if (_selectedGroupId == null)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'กรุณาเลือกกลุ่มจากแท็บ "กลุ่ม" เพื่อดูสมาชิก',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: member.membershipType == 'leader'
                          ? Colors.orange
                          : member.membershipType == 'committee'
                              ? Colors.blue
                              : Colors.green,
                      child: Icon(
                        member.membershipType == 'leader'
                            ? Icons.star
                            : member.membershipType == 'committee'
                                ? Icons.admin_panel_settings
                                : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('สมาชิก ${member.farmerId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (member.role != null) Text('ตำแหน่ง: ${member.role}'),
                        Text('เข้าร่วม: ${_formatDate(member.joinDate)}'),
                        Text('เงินสมทบ: ${_formatCurrency(member.contributionAmount)}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        member.membershipType == 'leader'
                            ? 'หัวหน้า'
                            : member.membershipType == 'committee'
                                ? 'กรรมการ'
                                : 'สมาชิก',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: member.membershipType == 'leader'
                          ? Colors.orange[100]
                          : member.membershipType == 'committee'
                              ? Colors.blue[100]
                              : Colors.green[100],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActivitiesTab(FarmerGroupProvider provider) {
    final activities = _selectedGroupId != null
        ? provider.getActivitiesByGroup(_selectedGroupId!)
        : <GroupActivity>[];

    return Column(
      children: [
        if (_selectedGroupId == null)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'กรุณาเลือกกลุ่มจากแท็บ "กลุ่ม" เพื่อดูกิจกรรม',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getActivityColor(activity.status),
                      child: Icon(
                        _getActivityIcon(activity.activityType),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(_formatDate(activity.scheduledDate)),
                            const SizedBox(width: 16),
                            if (activity.location != null) ...[
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(activity.location!),
                            ],
                          ],
                        ),
                        if (activity.budget != null)
                          Text('ง예산: ${_formatCurrency(activity.budget!)}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(_getStatusText(activity.status)),
                      backgroundColor: _getActivityColor(activity.status).withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFundsTab(FarmerGroupProvider provider) {
    final funds = _selectedGroupId != null
        ? provider.getFundsByGroup(_selectedGroupId!)
        : <GroupFund>[];

    return Column(
      children: [
        if (_selectedGroupId == null)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'กรุณาเลือกกลุ่มจากแท็บ "กลุ่ม" เพื่อดูกองทุน',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: funds.length,
              itemBuilder: (context, index) {
                final fund = funds[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fund.fundName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Chip(
                              label: Text(_getFundTypeText(fund.fundType)),
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                            ),
                          ],
                        ),
                        if (fund.description != null) ...[
                          const SizedBox(height: 8),
                          Text(fund.description!),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('เงินทุนรวม', style: TextStyle(color: Colors.grey[600])),
                                  Text(
                                    _formatCurrency(fund.totalAmount),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('เงินคงเหลือ', style: TextStyle(color: Colors.grey[600])),
                                  Text(
                                    _formatCurrency(fund.availableAmount),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('อัตราดอกเบี้ย: ${fund.interestRate}% ต่อปี'),
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

  Widget _buildStatisticsTab(FarmerGroupProvider provider) {
    if (_selectedGroupId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'กรุณาเลือกกลุ่มจากแท็บ "กลุ่ม" เพื่อดูสถิติ',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final stats = provider.getGroupStatistics(_selectedGroupId!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สถิติกลุ่ม: ${stats['groupName']}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStatCard('จำนวนสมาชิก', '${stats['memberCount']} คน', Icons.people, Colors.blue),
          _buildStatCard('กิจกรรมที่ดำเนินการ', '${stats['activeActivities']} กิจกรรม', Icons.event, Colors.orange),
          _buildStatCard('เงินทุนรวม', _formatCurrency(stats['totalFunds']), Icons.account_balance, Colors.green),
          _buildStatCard('เงินคงเหลือ', _formatCurrency(stats['availableFunds']), Icons.savings, Colors.teal),
          _buildStatCard('เงินออมสุทธิ', _formatCurrency(stats['netSavings']), Icons.trending_up, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600])),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('สร้างกลุ่มใหม่'),
        content: const Text('ฟีเจอร์นี้จะพัฒนาในเวอร์ชันถัดไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showGroupDetails(FarmerGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('รายละเอียด: ${group.description}'),
              const SizedBox(height: 8),
              Text('เลขทะเบียน: ${group.registrationNumber}'),
              Text('ก่อตั้งเมื่อ: ${_formatDate(group.establishedDate)}'),
              Text('ที่อยู่: ${group.tambon}, ${group.amphoe}, ${group.province}'),
              Text('จำนวนสมาชิก: ${group.memberCount} คน'),
              Text('เงินทุนรวม: ${_formatCurrency(group.totalFundAmount)}'),
              if (group.notes != null) ...[
                const SizedBox(height: 8),
                Text('หมายเหตุ: ${group.notes}'),
              ],
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

  void _showEditGroupDialog(FarmerGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขกลุ่ม'),
        content: const Text('ฟีเจอร์นี้จะพัฒนาในเวอร์ชันถัดไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year + 543}';
  }

  String _formatCurrency(double amount) {
    return '฿${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  Color _getActivityColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'planned':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'meeting':
        return Icons.meeting_room;
      case 'training':
        return Icons.school;
      case 'event':
        return Icons.event;
      case 'project':
        return Icons.work;
      default:
        return Icons.event;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'เสร็จสิ้น';
      case 'ongoing':
        return 'กำลังดำเนินการ';
      case 'planned':
        return 'วางแผน';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  String _getFundTypeText(String type) {
    switch (type) {
      case 'savings':
        return 'เงินออม';
      case 'loan':
        return 'เงินกู้';
      case 'emergency':
        return 'เงินฉุกเฉิน';
      case 'investment':
        return 'เงินลงทุน';
      default:
        return type;
    }
  }
}
