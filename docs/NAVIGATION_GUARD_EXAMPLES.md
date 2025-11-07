# 🎯 Navigation Guard - ตัวอย่างการใช้งาน

## 📦 ตัวอย่างที่ 1: Dashboard Cards

### **Before (ไม่มี Guard)** ❌

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView(
      children: [
        DashboardCard(
          title: 'ปศุสัตว์',
          icon: Icons.pets,
          onTap: () {
            context.go('/livestock');  // ❌ ไม่เช็ค auth
          },
        ),
      ],
    );
  }
}
```

**ปัญหา:** Guest คลิก → Login อัตโนมัติ

---

### **After (ใช้ Guard)** ✅

```dart
import '../utils/navigation_guard.dart';

class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView(
      children: [
        DashboardCard(
          title: 'ปศุสัตว์',
          icon: Icons.pets,
          onTap: () {
            NavigationGuard.safeNavigate(
              context: context,
              ref: ref,
              path: '/livestock',
            );
          },
        ),
      ],
    );
  }
}
```

**ผลลัพธ์:** Guest คลิก → แสดง dialog "ต้องเข้าสู่ระบบ"

---

## 🔗 ตัวอย่างที่ 2: Text Link

### **Before** ❌

```dart
GestureDetector(
  onTap: () => context.go('/admin-dashboard'),
  child: Text(
    'ไปหน้า Admin',
    style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
  ),
)
```

---

### **After** ✅

```dart
import 'package:flutter/gestures.dart';

RichText(
  text: TextSpan(
    text: 'ไปหน้า ',
    style: TextStyle(color: Colors.black),
    children: [
      TextSpan(
        text: 'Admin',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            NavigationGuard.safeNavigate(
              context: context,
              ref: ref,
              path: '/admin-dashboard',
            );
          },
      ),
    ],
  ),
)
```

---

## 🏠 ตัวอย่างที่ 3: Home Button

### **Before** ❌

```dart
IconButton(
  icon: Icon(Icons.home),
  onPressed: () => context.go('/dashboard'), // ❌ Hardcoded
)
```

---

### **After** ✅

```dart
IconButton(
  icon: Icon(Icons.home),
  onPressed: () => NavigationGuard.navigateToHome(context, ref),
)
```

**Smart:**
- User → `/dashboard`
- Guest → `/market`

---

## 🎨 ตัวอย่างที่ 4: Custom Button

### **Full Example**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/navigation_guard.dart';

class CustomNavigationButton extends ConsumerWidget {
  final String title;
  final IconData icon;
  final String targetPath;
  final bool requiresAuth;

  const CustomNavigationButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.targetPath,
    this.requiresAuth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF228B22), // Green
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      onPressed: () {
        if (requiresAuth) {
          // Protected route
          NavigationGuard.safeNavigate(
            context: context,
            ref: ref,
            path: targetPath,
          );
        } else {
          // Public route
          context.go(targetPath);
        }
      },
    );
  }
}

// Usage:
CustomNavigationButton(
  title: 'จัดการปศุสัตว์',
  icon: Icons.pets,
  targetPath: '/livestock',
  requiresAuth: true,  // ✅ จะเช็ค auth
)

CustomNavigationButton(
  title: 'ตลาดซื้อขาย',
  icon: Icons.store,
  targetPath: '/market',
  requiresAuth: false,  // ✅ ไม่เช็ค auth
)
```

---

## 📋 ตัวอย่างที่ 5: List Items

### **ListView with Safe Navigation**

```dart
class MenuList extends ConsumerWidget {
  final menuItems = [
    {'title': 'แดชบอร์ด', 'path': '/dashboard', 'icon': Icons.dashboard, 'protected': true},
    {'title': 'ตลาด', 'path': '/market', 'icon': Icons.store, 'protected': false},
    {'title': 'ติดต่อ', 'path': '/contact-admin', 'icon': Icons.contact_support, 'protected': false},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ListTile(
          leading: Icon(item['icon'] as IconData),
          title: Text(item['title'] as String),
          onTap: () {
            if (item['protected'] == true) {
              NavigationGuard.safeNavigate(
                context: context,
                ref: ref,
                path: item['path'] as String,
              );
            } else {
              context.go(item['path'] as String);
            }
          },
        );
      },
    );
  }
}
```

---

## 🔄 ตัวอย่างที่ 6: Drawer Menu

### **App Drawer with Guard**

```dart
class AppDrawer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(productionAuthProvider);

    return Drawer(
      child: ListView(
        children: [
          // Header
          UserAccountsDrawerHeader(
            accountName: Text(authState.user?.username ?? 'Guest'),
            accountEmail: Text(authState.user?.email ?? 'ยังไม่ได้เข้าสู่ระบบ'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          // Public menu
          ListTile(
            leading: Icon(Icons.store),
            title: Text('ตลาดซื้อขาย'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/market');
            },
          ),

          // Protected menu
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('จัดการปศุสัตว์'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              NavigationGuard.safeNavigate(
                context: context,
                ref: ref,
                path: '/livestock',
              );
            },
          ),

          Divider(),

          // Login/Logout
          if (!authState.isAuthenticated)
            ListTile(
              leading: Icon(Icons.login),
              title: Text('เข้าสู่ระบบ'),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            )
          else
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('ออกจากระบบ'),
              onTap: () {
                Navigator.pop(context);
                // Show logout confirmation
              },
            ),
        ],
      ),
    );
  }
}
```

---

## 🎯 Quick Reference

### **Navigation Methods**

| Method | Use Case | Guest Behavior |
|--------|----------|----------------|
| `safeNavigate()` | Protected routes | Show dialog |
| `navigateToHome()` | Home button | → /market |
| `navigateOrBack()` | With fallback | Show dialog, stay on page |
| `context.go()` | Public routes | Navigate normally |

### **Route Types**

| Type | Examples | Requires Auth? |
|------|----------|----------------|
| **Public** | /market, /contact-admin, /register | ❌ No |
| **Protected** | /dashboard, /livestock, /admin | ✅ Yes |

### **Best Practice Pattern**

```dart
// 1. Import
import '../utils/navigation_guard.dart';

// 2. Use ConsumerWidget for ref
class MyScreen extends ConsumerWidget {
  
  // 3. Safe navigate in onTap/onPressed
  onTap: () {
    NavigationGuard.safeNavigate(
      context: context,
      ref: ref,
      path: '/protected-route',
    );
  }
}
```

---

**ใช้ Navigation Guard ทุกครั้ง เพื่อป้องกัน Auto Login Bug!** 🛡️✅
