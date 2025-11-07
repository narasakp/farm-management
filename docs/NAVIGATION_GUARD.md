# 🛡️ Navigation Guard System

ระบบป้องกัน Auto Login และจัดการ navigation อย่างปลอดภัย

---

## 📋 ปัญหาที่แก้ไข

### **Bug: Auto Login**
Guest คลิกลิงก์/ปุ่ม → ไปหน้าที่ต้อง login → Redirect ไป login → Login สำเร็จ → ไปหน้านั้นอัตโนมัติ

**ตัวอย่าง:**
```
1. Guest อยู่หน้า Register
2. คลิก "ติดต่อผู้ดูแลระบบ" (เดิมลิงก์ผิดไป /dashboard)
3. System redirect ไป /login
4. Login สำเร็จ → ไป /dashboard อัตโนมัติ ❌
5. ผู้ใช้งงว่าทำไมถึง login และเข้า dashboard
```

---

## 🔒 วิธีแก้: Navigation Guard

### **1. Public Routes**
Route ที่ Guest เข้าได้โดยไม่ต้อง login:

```dart
static const publicRoutes = [
  '/',
  '/login',
  '/register',
  '/market',
  '/contact-admin',
  '/quick-buy',
  '/guest-search',
];
```

### **2. Protected Routes**
Route ที่ต้อง login:

```dart
static const protectedRoutes = [
  '/dashboard',
  '/livestock',
  '/financial',
  '/admin-dashboard',
  // ... อื่นๆ
];
```

---

## 🚀 การใช้งาน

### **Method 1: Safe Navigate**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/navigation_guard.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // ✅ Safe navigation - เช็ค auth ก่อน
        NavigationGuard.safeNavigate(
          context: context,
          ref: ref,
          path: '/dashboard',
        );
      },
      child: Text('ไปแดชบอร์ด'),
    );
  }
}
```

**ผลลัพธ์:**
- ✅ **User logged in** → ไป `/dashboard` ได้เลย
- ⚠️ **Guest** → แสดง dialog เตือน "ต้องเข้าสู่ระบบ"
  - ปุ่ม "ยกเลิก" → อยู่หน้าเดิม
  - ปุ่ม "เข้าสู่ระบบ" → ไปหน้า login

---

### **Method 2: Navigate to Home (Smart)**

```dart
// ✅ Smart Home button
IconButton(
  icon: Icon(Icons.home),
  onPressed: () => NavigationGuard.navigateToHome(context, ref),
)
```

**ผลลัพธ์:**
- ✅ **User** → `/dashboard`
- ✅ **Guest** → `/market`

---

### **Method 3: Navigate or Back**

```dart
// ✅ Navigate with fallback
NavigationGuard.navigateOrBack(
  context: context,
  ref: ref,
  path: '/livestock',
);
```

**ผลลัพธ์:**
- ✅ **User** → ไปหน้า `/livestock`
- ⚠️ **Guest** → แสดง dialog, ถ้า cancel → อยู่หน้าเดิม

---

## 📦 Components ที่ใช้ Navigation Guard

### **1. StandardAppBar**
```dart
// Home button ใน AppBarType.detail
IconButton(
  icon: Icon(Icons.home_outlined),
  onPressed: () => NavigationGuard.navigateToHome(context, ref),
)
```

### **2. Dashboard Cards**
```dart
Card(
  onTap: () {
    NavigationGuard.safeNavigate(
      context: context,
      ref: ref,
      path: '/livestock',
    );
  },
)
```

---

## 🎨 Dialog Design

### **Login Required Dialog**

```
┌─────────────────────────────────┐
│ 🔒 ต้องเข้าสู่ระบบ              │
│                                 │
│ คุณต้องเข้าสู่ระบบก่อน          │
│ เข้าใช้งานหน้านี้               │
│                                 │
│ ℹ️ Guest สามารถใช้งาน          │
│   หน้าตลาดซื้อขายและค้นหาได้   │
│                                 │
│         [ยกเลิก]  [เข้าสู่ระบบ]│
└─────────────────────────────────┘
```

**สี:**
- 🟢 Primary: Green (#228B22)
- 🟤 Text: Brown (#8B4513)
- ⚪ Background: White
- 🟢 Info box: Light Green (#E8F5E9)

---

## ✅ Best Practices

### **DO ✅**

1. **ใช้ NavigationGuard สำหรับ protected routes**
   ```dart
   NavigationGuard.safeNavigate(context: context, ref: ref, path: '/dashboard');
   ```

2. **ใช้ navigateToHome แทนการ hardcode path**
   ```dart
   NavigationGuard.navigateToHome(context, ref);
   ```

3. **เพิ่ม route ใหม่ใน publicRoutes/protectedRoutes**
   ```dart
   static const publicRoutes = [
     // ... existing
     '/new-public-page',
   ];
   ```

### **DON'T ❌**

1. **อย่า hardcode navigation ไป protected routes**
   ```dart
   context.go('/dashboard'); // ❌ ไม่เช็ค auth
   ```

2. **อย่าใช้ Navigator.push โดยตรง**
   ```dart
   Navigator.push(...); // ❌ bypass routing system
   ```

3. **อย่าลืมเพิ่ม route ใน guard lists**
   ```dart
   // ❌ Route ใหม่แต่ไม่ได้เพิ่มใน lists
   GoRoute(path: '/new-protected-page')
   ```

---

## 🧪 Testing Checklist

### **Guest Mode Tests**

- [ ] คลิกปุ่ม/ลิงก์ไปหน้า protected → แสดง dialog
- [ ] คลิก "ยกเลิก" ใน dialog → อยู่หน้าเดิม
- [ ] คลิก "เข้าสู่ระบบ" ใน dialog → ไปหน้า login
- [ ] คลิก Home button → ไป /market (ไม่ login)
- [ ] เข้าหน้า public routes ได้ทุกหน้า

### **User Mode Tests**

- [ ] คลิกปุ่ม/ลิงก์ไปหน้า protected → ไปได้เลย
- [ ] คลิก Home button → ไป /dashboard
- [ ] คลิก Back button → กลับหน้าเดิม
- [ ] Logout → ไปหน้า login

---

## 🔄 Maintenance

### **เพิ่ม Public Route ใหม่**

```dart
// lib/utils/navigation_guard.dart
static const publicRoutes = [
  // ... existing
  '/new-public-page',  // เพิ่มบรรทัดนี้
];
```

### **เพิ่ม Protected Route ใหม่**

```dart
// lib/utils/navigation_guard.dart
static const protectedRoutes = [
  // ... existing
  '/new-protected-page',  // เพิ่มบรรทัดนี้
];
```

### **Custom Dialog**

```dart
// Override dialog ได้โดยแก้
NavigationGuard._showLoginRequiredDialog(context, targetPath);
```

---

## 📊 Impact

### **Before (ไม่มี Guard)**
- ❌ Guest คลิกลิงก์ → Login อัตโนมัติ
- ❌ UX แย่ ผู้ใช้งง
- ❌ Security risk
- ❌ Bug เจอบ่อย

### **After (มี Guard)**
- ✅ Guest คลิกลิงก์ → แสดง dialog ชัดเจน
- ✅ UX ดี ผู้ใช้มี choice
- ✅ Security better
- ✅ Maintainable

---

## 🎯 Summary

**Navigation Guard = ระบบป้องกัน Auto Login**

**Key Features:**
1. 🔒 Authentication check ก่อน navigate
2. 💬 Dialog เตือนชัดเจน
3. 🏠 Smart Home navigation
4. 📋 Centralized route management
5. ✅ Type-safe navigation

**ใช้ทุกครั้งที่ navigate ไปหน้าที่อาจต้อง login!**
