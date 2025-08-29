import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farm_provider.dart';
import '../../providers/survey_provider.dart';
import '../../providers/financial_provider.dart';
import '../../utils/responsive_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final farmProvider = context.read<FarmProvider>();
    await farmProvider.loadSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('แดชบอร์ด'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting
              _buildHeader(),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              
              // สถิติรวม - Desktop Style
              Consumer<FarmProvider>(
                builder: (context, farmProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'สถิติรวม',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
                      ResponsiveLayout(
                        mobile: Column(
                          children: [
                            _buildStatCard(
                              'ปศุสัตว์ทั้งหมด',
                              '410',
                              Icons.pets,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            _buildStatCard(
                              'ฟาร์มทั้งหมด',
                              '3',
                              Icons.home,
                              Colors.green,
                            ),
                          ],
                        ),
                        tablet: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'ปศุสัตว์ทั้งหมด',
                                '410',
                                Icons.pets,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'ฟาร์มทั้งหมด',
                                '3',
                                Icons.home,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'รายการซื้อขาย',
                                '12',
                                Icons.shopping_cart,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'รายการขนส่ง',
                                '8',
                                Icons.local_shipping,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        desktop: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'ปศุสัตว์ทั้งหมด',
                                '410',
                                Icons.pets,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'ฟาร์มทั้งหมด',
                                '3',
                                Icons.home,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'รายการซื้อขาย',
                                '12',
                                Icons.shopping_cart,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'รายการขนส่ง',
                                '8',
                                Icons.local_shipping,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              // เมนูหลัก
              const Text(
                'เมนูหลัก',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ResponsiveGrid(
                mobileColumns: 2,
                tabletColumns: 3,
                desktopColumns: 4,
                spacing: ResponsiveHelper.getCardSpacing(context),
                children: [
                  _buildActionCard(
                    '📋',
                    'สำรวจปศุสัตว์',
                    'แบบฟอร์มสำรวจดิจิทัล',
                    () => context.go('/survey'),
                  ),
                  _buildActionCard(
                    '🐮',
                    'จัดการปศุสัตว์',
                    'บันทึกข้อมูลสัตว์',
                    () => context.go('/livestock'),
                  ),
                  _buildActionCard(
                    '💰',
                    'การเงิน',
                    'บันทึกรายรับ-รายจ่าย',
                    () => context.go('/financial'),
                  ),
                  _buildActionCard(
                    '🏪',
                    'ตลาดออนไลน์',
                    'ซื้อ-ขายปศุสัตว์ - UPDATED',
                    () => context.go('/market'),
                  ),
                  _buildActionCard(
                    '🚛',
                    'ขนส่ง',
                    'จองรถขนส่งสัตว์',
                    () => context.go('/transport'),
                  ),
                  _buildActionCard(
                    '👥',
                    'กลุ่มเกษตรกร',
                    'จัดการกลุ่มชุมชน',
                    () => context.go('/farmer-group'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final now = DateTime.now();
        final formatter = DateFormat('EEEE, d MMMM yyyy', 'th');
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สวัสดี, เกษตรกร!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Friday, 29 August 2025',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$featureName'),
        content: const Text('ฟีเจอร์นี้กำลังพัฒนา\nจะเปิดใช้งานในเวอร์ชันถัดไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
