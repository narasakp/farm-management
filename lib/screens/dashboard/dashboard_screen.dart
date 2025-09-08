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
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF228B22).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.home_rounded, size: 28),
            color: const Color(0xFF228B22).withOpacity(0.8),
            onPressed: () => context.go('/dashboard'),
            tooltip: 'หน้าแรก',
          ),
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
                      Text(
                        'สถิติรวม',
                        style: Theme.of(context).textTheme.headlineMedium,
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
                                const Color(0xFF8B4513), // Brown
                                onTap: () => context.go('/livestock-management'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'ฟาร์มทั้งหมด',
                                '3',
                                Icons.agriculture,
                                const Color(0xFF228B22), // Forest Green
                                onTap: () => context.go('/farm-list'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'รายการซื้อขาย',
                                '12',
                                Icons.storefront,
                                const Color(0xFFDAA520), // Golden Rod
                                onTap: () => context.go('/trading-list'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'รายการขนส่ง',
                                '8',
                                Icons.local_shipping,
                                const Color(0xFF4682B4), // Steel Blue
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
                                const Color(0xFF8B4513), // Brown
                                onTap: () => context.go('/livestock-management'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'ฟาร์มทั้งหมด',
                                '3',
                                Icons.agriculture,
                                const Color(0xFF228B22), // Forest Green
                                onTap: () => context.go('/farm-list'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'รายการซื้อขาย',
                                '12',
                                Icons.storefront,
                                const Color(0xFFDAA520), // Golden Rod
                                onTap: () => context.go('/trading-list'),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildStatCard(
                                'รายการขนส่ง',
                                '8',
                                Icons.local_shipping,
                                const Color(0xFF4682B4), // Steel Blue
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
              Text(
                'เมนูหลัก',
                style: Theme.of(context).textTheme.headlineMedium,
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
                    backgroundColor: const Color(0xFF8B4513), // Brown
                  ),
                  _buildActionCard(
                    '📊',
                    'รายการสำรวจ',
                    'ดูผลการสำรวจทั้งหมด',
                    () => context.go('/survey-list'),
                    backgroundColor: const Color(0xFF228B22), // Forest Green
                  ),
                  _buildActionCard(
                    '🐮',
                    'จัดการปศุสัตว์',
                    'บันทึกข้อมูลสัตว์',
                    () => context.go('/livestock-management'),
                    backgroundColor: const Color(0xFFDAA520), // Golden Rod
                  ),
                  _buildActionCard(
                    '💰',
                    'การเงิน',
                    'บันทึกรายรับ-รายจ่าย',
                    () => context.go('/financial'),
                    backgroundColor: const Color(0xFF4682B4), // Steel Blue
                  ),
                  _buildActionCard(
                    '🏪',
                    'ตลาดออนไลน์',
                    'ซื้อ-ขายปศุสัตว์',
                    () => context.go('/market'),
                    backgroundColor: const Color(0xFF8B4513), // Brown
                  ),
                  _buildActionCard(
                    '🚛',
                    'ขนส่ง',
                    'จองรถขนส่งสัตว์',
                    () => context.go('/transport-list'),
                    backgroundColor: const Color(0xFF228B22), // Forest Green
                  ),
                  _buildActionCard(
                    '🌾👨‍🌾',
                    'กลุ่มเกษตรกร',
                    'จัดการกลุ่มชุมชน',
                    () => context.go('/farmer-group'),
                    backgroundColor: const Color(0xFFDAA520), // Golden Rod
                  ),
                  _buildActionCard(
                    '📈',
                    'รายงานโปรเจกต์',
                    'ติดตามความคืบหน้า',
                    () => context.go('/project-report'),
                    backgroundColor: const Color(0xFF4682B4), // Steel Blue
                  ),
                  _buildActionCard(
                    '🏥',
                    'จัดการสุขภาพ',
                    'บันทึกการรักษาและวัคซีน',
                    () => _showComingSoon(context, 'จัดการสุขภาพ'),
                    backgroundColor: const Color(0xFF8B4513), // Brown
                  ),
                  _buildActionCard(
                    '🐣',
                    'จัดการการผสมพันธุ์',
                    'ติดตามการผสมและการคลอด',
                    () => _showComingSoon(context, 'จัดการการผสมพันธุ์'),
                    backgroundColor: const Color(0xFF228B22), // Forest Green
                  ),
                  _buildActionCard(
                    '📦',
                    'จัดการการผลิต',
                    'บันทึกผลผลิตและคุณภาพ',
                    () => _showComingSoon(context, 'จัดการการผลิต'),
                    backgroundColor: const Color(0xFFDAA520), // Golden Rod
                  ),
                  _buildActionCard(
                    '🌾',
                    'จัดการอาหารสัตว์',
                    'คลังอาหารและตารางให้อาหาร',
                    () => _showComingSoon(context, 'จัดการอาหารสัตว์'),
                    backgroundColor: const Color(0xFF4682B4), // Steel Blue
                  ),
                  _buildActionCard(
                    '📊',
                    'รายงานและวิเคราะห์',
                    'วิเคราะห์ข้อมูลและสร้างรายงาน',
                    () => _showComingSoon(context, 'รายงานและวิเคราะห์'),
                    backgroundColor: const Color(0xFF8B4513), // Brown
                  ),
                  _buildActionCard(
                    '🔬',
                    'วิจัยและพัฒนา',
                    'โครงการวิจัยและนวัตกรรม',
                    () => context.go('/research-development'),
                    backgroundColor: const Color(0xFF228B22), // Forest Green
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
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildActionCard(String emoji, String title, String subtitle, VoidCallback onTap, {Color? backgroundColor}) {
    // 4-color palette rotation
    final colors = [
      const Color(0xFF8B4513), // Brown
      const Color(0xFF228B22), // Forest Green  
      const Color(0xFFDAA520), // Golden Rod
      const Color(0xFF4682B4), // Steel Blue
    ];
    
    final colorIndex = title.hashCode.abs() % colors.length;
    final cardColor = backgroundColor ?? colors[colorIndex];
    
    return Card(
      elevation: 4,
      shadowColor: cardColor.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.1),
                cardColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cardColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    emoji,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cardColor.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
