import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int selectedIndex = 0;

  final List<DrawerItem> drawerItems = [
    DrawerItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'แดชบอร์ด',
      route: '/dashboard',
    ),
    DrawerItem(
      icon: Icons.agriculture_outlined,
      selectedIcon: Icons.agriculture,
      label: 'ฟาร์มของฉัน',
      route: '/farms',
    ),
    DrawerItem(
      icon: Icons.pets_outlined,
      selectedIcon: Icons.pets,
      label: 'ปศุสัตว์',
      route: '/livestock',
    ),
    DrawerItem(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'การเงิน',
      route: '/financial',
    ),
    DrawerItem(
      icon: Icons.store_outlined,
      selectedIcon: Icons.store,
      label: 'ตลาด',
      route: '/market',
    ),
    DrawerItem(
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping,
      label: 'ขนส่ง',
      route: '/transport',
    ),
    DrawerItem(
      icon: Icons.group_outlined,
      selectedIcon: Icons.group,
      label: 'กลุ่มเกษตรกร',
      route: '/groups',
    ),
    DrawerItem(
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      label: 'แบบสำรวจ',
      route: '/survey',
    ),
    DrawerItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'รายงาน',
      route: '/reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.firstName.substring(0, 1) ?? 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? 'ผู้ใช้',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user?.phoneNumber ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                final item = drawerItems[index];
                final isSelected = selectedIndex == index;
                
                return ListTile(
                  leading: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    Navigator.pop(context);
                    // TODO: Implement navigation
                  },
                );
              },
            ),
          ),
          
          const Divider(),
          
          // Logout Button
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'ออกจากระบบ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
