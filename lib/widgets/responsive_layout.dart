import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/app_drawer.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).equals(MOBILE);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบบริหารจัดการฟาร์มปศุสัตว์'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: isDesktop ? null : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: Row(
        children: [
          if (isDesktop)
            const SizedBox(
              width: 280,
              child: SidebarNavigation(),
            ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
