import 'package:flutter/material.dart';

/// ⚠️ WARNING: READ BEFORE MODIFYING! ⚠️
/// 
/// This is the SINGLE SOURCE OF TRUTH for all admin navigation.
/// Before adding new admin routes/screens:
/// 
/// 1. ✅ Check SCREEN_INVENTORY.md for existing screens
/// 2. ✅ Check if feature can be added to /admin-dashboard tabs
/// 3. ✅ Update SCREEN_INVENTORY.md if adding new screen
/// 4. ✅ Document why new screen is needed (can't extend existing)
/// 
/// ⚠️ DON'T create separate user management screens!
///    All user management goes to /admin-dashboard
/// 
/// See: D:\Code\_KNOWLEDGE_BASE\TROUBLESHOOTING\ADMIN_SCREEN_DUPLICATION_REFACTOR_2025-10-21.md

/// Centralized Admin Navigation Configuration
/// ใช้ร่วมกันระหว่าง Sidebar, Dashboard Cards, และอื่นๆ
/// ป้องกันการ hardcode route ซ้ำๆ
class AdminNavigationConfig {
  static const String adminDashboardRoute = '/admin-dashboard';
  static const String adminRolesRoute = '/admin-roles';
  static const String adminPermissionsRoute = '/admin-permissions';
  static const String seedDataRoute = '/seed-data';

  /// Admin Menu Items - ใช้ได้ทั้ง Sidebar และ Dashboard
  static final List<AdminMenuItem> menuItems = [
    AdminMenuItem(
      id: 'admin_dashboard',
      icon: Icons.dashboard,
      label: 'RBAC Dashboard',
      description: 'จัดการผู้ใช้ Roles และสิทธิ์ (4 tabs)',
      route: adminDashboardRoute,
      color: const Color(0xFFDC143C), // สีแดงเข้ม - เน้นข้อมูล Sensitive (ตรงกับ Header)
      emoji: '📊',
      order: 98, // ย้ายไปท้ายสุด (ก่อน Seed Data ที่เป็น 99)
    ),
    // ❌ REMOVED: admin_roles (ซ้ำกับ Tab "Roles" ใน RBAC Dashboard)
    // ❌ REMOVED: admin_permissions (ซ้ำกับ Tab "Permission Matrix" ใน RBAC Dashboard)
    AdminMenuItem(
      id: 'seed_data',
      icon: Icons.science,
      label: '🛠️ Seed Data (Dev)',
      description: 'เติมข้อมูลทดสอบ',
      route: seedDataRoute,
      color: const Color(0xFF4682B4),
      emoji: '🛠️',
      order: 99,
      isDevTool: true,
    ),
  ];

  /// Get menu items sorted by order
  static List<AdminMenuItem> getSortedMenuItems() {
    final items = List<AdminMenuItem>.from(menuItems);
    items.sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  /// Get dashboard cards (exclude dev tools)
  static List<AdminMenuItem> getDashboardCards() {
    return menuItems
        .where((item) => !item.isDevTool)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Get sidebar items (include all)
  static List<AdminMenuItem> getSidebarItems() {
    return getSortedMenuItems();
  }

  /// Get menu item by route
  static AdminMenuItem? getMenuItemByRoute(String route) {
    try {
      return menuItems.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }
}

/// Admin Menu Item Model
class AdminMenuItem {
  final String id;
  final IconData icon;
  final String label;
  final String description;
  final String route;
  final Color color;
  final String emoji;
  final int order;
  final bool isDevTool;

  const AdminMenuItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
    required this.color,
    required this.emoji,
    this.order = 0,
    this.isDevTool = false,
  });

  /// สร้าง Drawer Item
  Widget toDrawerItem(BuildContext context, Function(String) onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => onTap(route),
    );
  }

  /// สร้าง Dashboard Card
  Widget toDashboardCard(BuildContext context, Function(String) onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onTap(route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
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
}
