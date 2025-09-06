import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
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
      body: Container(
        color: Colors.white,
        child: RefreshIndicator(
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
                              onTap: () => context.go('/livestock-management'),
                            ),
                            const SizedBox(height: 12),
                            _buildStatCard(
                              'ฟาร์มทั้งหมด',
                              '3',
                              Icons.home,
                              Colors.green,
                              onTap: () => context.go('/farm-list'),
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
                                onTap: () => context.go('/livestock-management'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'ฟาร์มทั้งหมด',
                                '3',
                                Icons.home,
                                Colors.green,
                                onTap: () => context.go('/farm-list'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'รายการซื้อขาย',
                                '12',
                                Icons.shopping_cart,
                                Colors.orange,
                                onTap: () => context.go('/trading-list'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'รายการขนส่ง',
                                '8',
                                Icons.local_shipping,
                                Colors.purple,
                                onTap: () => context.go('/transport-list'),
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
                                onTap: () => context.go('/livestock-management'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'ฟาร์มทั้งหมด',
                                '3',
                                Icons.home,
                                Colors.green,
                                onTap: () => context.go('/farm-list'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'รายการซื้อขาย',
                                '12',
                                Icons.shopping_cart,
                                Colors.orange,
                                onTap: () => context.go('/trading-list'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'รายการขนส่ง',
                                '8',
                                Icons.local_shipping,
                                Colors.purple,
                                onTap: () => context.go('/transport-list'),
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
                    '📊',
                    'รายการสำรวจ',
                    'ดูผลการสำรวจทั้งหมด',
                    () => context.go('/survey-list'),
                  ),
                  _buildActionCard(
                    '🐮',
                    'จัดการปศุสัตว์',
                    'บันทึกข้อมูลสัตว์',
                    () => context.go('/livestock-management'),
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
                    () => context.go('/transport-list'),
                  ),
                  _buildActionCard(
                    '🌾👨‍🌾',
                    'กลุ่มเกษตรกร',
                    'จัดการกลุ่มชุมชน',
                    () => context.go('/farmer-group'),
                  ),
                  _buildActionCard(
                    '📈',
                    'รายงานโปรเจกต์',
                    'ติดตามความคืบหน้า',
                    () => context.go('/project-report'),
                  ),
                  _buildActionCard(
                    '🏥',
                    'จัดการสุขภาพ',
                    'บันทึกการรักษาและวัคซีน',
                    () => context.go('/health-management'),
                  ),
                  _buildActionCard(
                    '🐣',
                    'จัดการการผสมพันธุ์',
                    'ติดตามการผสมและการคลอด',
                    () => context.go('/breeding-management'),
                  ),
                  _buildActionCard(
                    '📦',
                    'จัดการการผลิต',
                    'บันทึกผลผลิตและคุณภาพ',
                    () => context.go('/production-management'),
                  ),
                  _buildActionCard(
                    '🌾',
                    'จัดการอาหารสัตว์',
                    'คลังอาหารและตารางให้อาหาร',
                    () => context.go('/feed-management'),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final now = DateTime.now();
        final dateString = '${now.day}/${now.month}/${now.year}';
        
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
              dateString,
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
