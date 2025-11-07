import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/production_auth_provider.dart';
import '../providers/rbac_provider.dart';
import '../config/admin_navigation_config.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  String? _selectedRoute;

  // Grouped menu items
  final List<DrawerGroup> _menuGroups = [
    DrawerGroup(
      title: '🐄 ฟาร์มและปศุสัตว์',
      color: Color(0xFF8B4513),
      items: [
        DrawerItem(icon: Icons.assignment, label: 'สำรวจปศุสัตว์', route: '/survey'),
        DrawerItem(icon: Icons.bar_chart, label: 'สถิติการสำรวจ', route: '/survey-list'),
        DrawerItem(icon: Icons.pets, label: 'จัดการปศุสัตว์', route: '/livestock-management'),
        DrawerItem(icon: Icons.inventory, label: 'จัดการการผลิต', route: '/production-management'),
        DrawerItem(icon: Icons.home_work, label: 'ทะเบียนฟาร์ม', route: '/farm-list'),
        DrawerItem(icon: Icons.medical_services, label: 'จัดการสุขภาพ', route: '/health-management'),
        DrawerItem(icon: Icons.vaccines, label: 'บริหารวัคซีน', route: '/vaccination'),
        DrawerItem(icon: Icons.child_care, label: 'จัดการการผสมพันธุ์', route: '/breeding'),
        DrawerItem(icon: Icons.grass, label: 'จัดการอาหารสัตว์', route: '/feed-management'),
      ],
    ),
    DrawerGroup(
      title: '💰 การเงินและการค้า',
      color: Color(0xFF228B22),
      items: [
        DrawerItem(icon: Icons.account_balance_wallet, label: 'การเงิน', route: '/financial'),
        DrawerItem(icon: Icons.trending_up, label: 'วิเคราะห์กำไร-ขาดทุน', route: '/profit-loss'),
        DrawerItem(icon: Icons.storefront, label: 'ตลาดนัดปศุสัตว์', route: '/market'),
        DrawerItem(icon: Icons.analytics, label: 'Social Analytics', route: '/social-analytics'),
        DrawerItem(icon: Icons.local_shipping, label: 'ขนส่ง', route: '/transport-list'),
        DrawerItem(icon: Icons.receipt_long, label: 'ประวัติธุรกรรม', route: '/trading-list'),
      ],
    ),
    DrawerGroup(
      title: '👥 ชุมชนและวิจัย',
      color: Color(0xFFDAA520),
      items: [
        DrawerItem(icon: Icons.groups, label: 'กลุ่มเกษตรกร', route: '/farmer-group'),
        DrawerItem(icon: Icons.savings, label: 'กองทุนกลุ่ม', route: '/group-fund'),
        DrawerItem(icon: Icons.science, label: 'วิจัยและพัฒนา', route: '/research-development'),
        DrawerItem(icon: Icons.assessment, label: 'รายงานโปรเจกต์', route: '/project-report'),
        DrawerItem(icon: Icons.forum, label: 'ชุมชนออนไลน์', route: '/community'),
      ],
    ),
    DrawerGroup(
      title: '⚙️ เครื่องมือ',
      color: Color(0xFF4682B4),
      items: [
        DrawerItem(icon: Icons.search, label: 'ค้นหาข้อมูล', route: '/market'),  // ✅ ใช้ /market แทน (มี search ใน market แล้ว)
        DrawerItem(icon: Icons.calendar_today, label: 'ปฏิทินกิจกรรม', route: '/calendar'),
        DrawerItem(icon: Icons.map, label: 'แผนที่และ GPS', route: '/map'),
        DrawerItem(icon: Icons.bar_chart, label: 'รายงานและวิเคราะห์', route: '/analytics'),
        DrawerItem(icon: Icons.feedback, label: 'ข้อเสนอแนะ', route: '/feedback'),
        DrawerItem(icon: Icons.menu_book, label: 'คู่มือการเลี้ยง', route: '/handbook'),
        DrawerItem(icon: Icons.notifications, label: 'การแจ้งเตือน', route: '/notifications'),
      ],
    ),
  ];
  
  // RBAC Admin Group (แสดงเฉพาะ SUPER_ADMIN) - ใช้ centralized config
  DrawerGroup get _rbacAdminGroup {
    final adminItems = AdminNavigationConfig.getSidebarItems();
    return DrawerGroup(
      title: '🔐 RBAC Administration',
      color: const Color(0xFFDC143C),
      items: adminItems.map((item) => DrawerItem(
        icon: item.icon,
        label: item.label,
        route: item.route,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(productionAuthProvider);
    final user = authState.user;
    final dashPerms = ref.watch(dashboardPermissionsProvider);
    
    return Drawer(
      child: Column(
        children: [
          // Header with User Info
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF228B22), Color(0xFF8B4513)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?['display_name']?.substring(0, 1) ?? 'U',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF228B22),
                ),
              ),
            ),
            accountName: Text(
              user?['display_name'] ?? 'ผู้ใช้',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'เกษตรกร | อ.เนินสง่า, จ.ชัยภูมิ',
              style: TextStyle(fontSize: 14),
            ),
          ),
          
          // Home Button
          ListTile(
            leading: Icon(Icons.home, color: Color(0xFF228B22)),
            title: Text('หน้าแรก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              context.go('/dashboard');
            },
          ),
          
          Divider(),
          
          // Navigation Menu Groups
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _menuGroups.length + (dashPerms.canAccessAdminDashboard ? 1 : 0),
              itemBuilder: (context, groupIndex) {
                // แสดง RBAC Admin Group แรกสุด (ถ้ามีสิทธิ์)
                if (dashPerms.canAccessAdminDashboard) {
                  if (groupIndex == 0) {
                    return _buildMenuGroup(context, _rbacAdminGroup);
                  }
                  final group = _menuGroups[groupIndex - 1];
                  return _buildMenuGroup(context, group);
                } else {
                  final group = _menuGroups[groupIndex];
                  return _buildMenuGroup(context, group);
                }
              },
            ),
          ),
          
          Divider(),
          
          // Settings
          ListTile(
            leading: Icon(Icons.settings, color: Color(0xFF4682B4)),
            title: Text('ตั้งค่า', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          
          // Logout Button - Show only for authenticated users
          if (authState.isAuthenticated)
            ListTile(
              leading: Icon(Icons.logout, color: Color(0xFFCD5C5C)),
              title: Text(
                'ออกจากระบบ',
                style: TextStyle(fontSize: 16, color: Color(0xFFCD5C5C)),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(productionAuthProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          
          SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildMenuGroup(BuildContext context, DrawerGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            group.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: group.color,
            ),
          ),
        ),
        ...group.items.map((item) => _buildMenuItem(context, item, group.color)),
        SizedBox(height: 8),
      ],
    );
  }
  
  Widget _buildMenuItem(BuildContext context, DrawerItem item, Color groupColor) {
    final isSelected = _selectedRoute == item.route;
    
    return ListTile(
      leading: Icon(
        item.icon,
        size: 22,
        color: isSelected ? groupColor : Colors.grey[700],
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontSize: 15,
          color: isSelected ? groupColor : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: groupColor.withOpacity(0.1),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: () {
        setState(() {
          _selectedRoute = item.route;
        });
        Navigator.pop(context);
        
        // Handle Coming Soon routes
        final comingSoonRoutes = [
          '/health-management', '/vaccination', '/breeding', 
          '/feed-management', '/profit-loss',
          '/group-fund', '/community', '/calendar', '/map',
          '/analytics', '/handbook', '/notifications', '/settings'
        ];
        
        if (comingSoonRoutes.contains(item.route)) {
          _showComingSoon(context, item.label);
        } else {
          context.go(item.route);
        }
      },
    );
  }
  
  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(featureName),
        content: Text('ฟีเจอร์นี้กำลังพัฒนา\nจะเปิดใช้งานในเวอร์ชันถัดไป'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String label;
  final String route;

  DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class DrawerGroup {
  final String title;
  final Color color;
  final List<DrawerItem> items;

  DrawerGroup({
    required this.title,
    required this.color,
    required this.items,
  });
}
