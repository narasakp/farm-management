import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:html' as html; // สำหรับใช้ browser history
import '../../providers/production_auth_provider.dart';
import '../../services/profile_service.dart';
import '../../utils/navigation_guard.dart';
import '../notifications/notification_bell_button.dart';

/// ประเภทของ AppBar ตามระดับหน้า
enum AppBarType {
  root,   // ระดับ 0: Dashboard, Login
  main,   // ระดับ 1: Lists, Search, Reports
  detail, // ระดับ 2+: Details, Forms, Management
}

/// StandardAppBar - Custom AppBar ควบคุม 100%
/// 
/// ใช้ 3-Tier Pattern:
/// - Root:   ☰ + Title + 🔍 🔔 🚪
/// - Main:   ← + Title + [Custom] + 🚪
/// - Detail: ← + Title + 🏠 🚪
/// 
/// ⚠️ แก้ไข: ไม่ใช้ Material AppBar เพื่อหลีกเลี่ยงปัญหา pointer events
class StandardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final AppBarType type;
  final String title;
  final List<Widget>? customActions;
  final Color? backgroundColor;
  final bool useGradient;
  final VoidCallback? onLogout;
  final VoidCallback? onBackPressed; // ⭐ Smart Back Navigation callback
  final bool showSearch;
  final bool showNotifications;
  final PreferredSizeWidget? bottom;
  final bool hideMenuForGuest; // ⭐ ซ่อนปุ่มเมนู 3 ขีดสำหรับ Guest (default: false = แสดงตามปกติ)

  const StandardAppBar({
    super.key,
    required this.type,
    required this.title,
    this.customActions,
    this.backgroundColor,
    this.useGradient = true,
    this.onLogout,
    this.onBackPressed, // ⭐ เพิ่ม parameter
    this.showSearch = true,
    this.showNotifications = false,
    this.bottom,
    this.hideMenuForGuest = false, // ⭐ Default: แสดงเมนูตามปกติ
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ CUSTOM APPBAR - ควบคุมเอง 100%
    return Container(
      height: kToolbarHeight + (bottom?.preferredSize.height ?? 0) + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2E7D32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  // Leading (Back button)
                  if (_buildLeading(context, ref) != null)
                    _buildLeading(context, ref)!,
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Actions
                  ..._buildActions(context, ref),
                ],
              ),
            ),
          ),
          // Bottom (TabBar)
          if (bottom != null) bottom!,
        ],
      ),
    );
  }

  /// สร้างปุ่มด้านซ้าย (Leading)
  Widget? _buildLeading(BuildContext context, WidgetRef ref) {
    switch (type) {
      case AppBarType.root:
        // ☰ เมนู 3 ขีด (สำหรับ Drawer)
        // ถ้า hideMenuForGuest = true → เช็ค auth ก่อนแสดง
        if (hideMenuForGuest) {
          final authState = ref.watch(productionAuthProvider);
          if (!authState.isAuthenticated) {
            // Guest: ไม่แสดงปุ่มเมนู
            return null;
          }
        }
        // Default: แสดงปุ่มเมนูตามปกติ
        return Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'เมนู',
          ),
        );
      case AppBarType.main:
      case AppBarType.detail:
        // ← ลูกศรกลับ - ใช้ browser history.back()
        return InkWell(
          onTap: () {
            print('🔴 BACK BUTTON TAPPED!');
            final callback = onBackPressed ?? () {
              print('🔵 Using browser history.back()');
              // ✅ FIX: ใช้ browser history API เพื่อกลับหน้าก่อนหน้าจริงๆ
              html.window.history.back();
            };
            callback();
          },
          child: Container(
            width: 56,
            height: 56,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
    }
  }

  /// สร้าง FlexibleSpace (Background)
  Widget? _buildFlexibleSpace() {
    if (backgroundColor != null) {
      return IgnorePointer(
        child: Container(color: backgroundColor),
      );
    }

    if (useGradient) {
      return IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E7D32), // Primary Green
                Color(0xFF4CAF50), // Light Green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      );
    }

    return null;
  }

  /// สร้างปุ่มด้านขวา (Actions)
  List<Widget> _buildActions(BuildContext context, WidgetRef ref) {
    final actions = <Widget>[];

    // เพิ่ม Custom Actions ก่อน (ถ้ามี)
    if (customActions != null) {
      actions.addAll(customActions!);
    }

    // Root Pages: เพิ่ม Search + Notifications
    if (type == AppBarType.root) {
      if (showSearch) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
            tooltip: 'ค้นหา',
          ),
        );
      }

      if (showNotifications) {
        actions.add(
          const NotificationBellButton(),
        );
      }
    }

    // Detail Pages (ชั้นที่ 2): เพิ่ม Home button
    if (type == AppBarType.detail) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => NavigationGuard.navigateToHome(context, ref),
          tooltip: 'หน้าแรก',
        ),
      );
    }

    // Profile & Logout: เพิ่มเฉพาะ User ที่ login แล้ว
    final authState = ref.watch(productionAuthProvider);
    if (authState.isAuthenticated) {
      // Notification Bell (แสดงในทุกหน้า)
      actions.add(
        const NotificationBellButton(),
      );
      
      // Profile Button with Avatar
      actions.add(
        _ProfileAvatarButton(
          authState: authState,
          onPressed: () => context.go('/profile'),
        ),
      );
      
      // Logout Button
      actions.add(
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout ?? () => _handleLogout(context, ref),
          tooltip: 'ออกจากระบบ',
        ),
      );
    }

    return actions;
  }

  /// จัดการ Logout พร้อม Confirmation Dialog
  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Logout ผ่าน Production Auth Provider
              final authNotifier = ref.read(productionAuthProvider.notifier);
              await authNotifier.logout();
              
              // Navigate to login
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

/// AppBar สำหรับหน้าที่มีสีเฉพาะ (ตาม PRD)
class ColoredAppBar extends StandardAppBar {
  /// AppBar สีน้ำตาล (สำหรับส่วนปศุสัตว์)
  ColoredAppBar.brown({
    super.key,
    required super.type,
    required super.title,
    super.customActions,
    super.onLogout,
    super.showSearch,
    super.showNotifications,
    super.bottom,
  }) : super(
          backgroundColor: const Color(0xFF5D4037), // Primary Brown
          useGradient: false,
        );

  /// AppBar สีน้ำเงิน (สำหรับข้อมูล/รายงาน)
  ColoredAppBar.blue({
    super.key,
    required super.type,
    required super.title,
    super.customActions,
    super.onLogout,
    super.showSearch,
    super.showNotifications,
    super.bottom,
  }) : super(
          backgroundColor: const Color(0xFF1976D2), // Primary Blue
          useGradient: false,
        );

  /// AppBar สีส้ม (สำหรับการเตือน/ไฮไลท์)
  ColoredAppBar.orange({
    super.key,
    required super.type,
    required super.title,
    super.customActions,
    super.onLogout,
    super.showSearch,
    super.showNotifications,
    super.bottom,
  }) : super(
          backgroundColor: const Color(0xFFFF9800), // Primary Orange
          useGradient: false,
        );
}

/// Profile Avatar Button Widget
class _ProfileAvatarButton extends StatefulWidget {
  final ProductionAuthState authState;
  final VoidCallback onPressed;
  
  const _ProfileAvatarButton({
    required this.authState,
    required this.onPressed,
  });
  
  @override
  State<_ProfileAvatarButton> createState() => _ProfileAvatarButtonState();
}

class _ProfileAvatarButtonState extends State<_ProfileAvatarButton> {
  String? _avatarUrl;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }
  
  @override
  void didUpdateWidget(_ProfileAvatarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload avatar ทุกครั้งที่ widget rebuild (เมื่อกลับจากหน้า Profile)
    if (!_isLoading) {
      _loadAvatar();
    }
  }
  
  void _showAvatarMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // ดูรูปขนาดใหญ่
              ListTile(
                leading: const Icon(Icons.zoom_in),
                title: const Text('ดูรูปขนาดใหญ่'),
                onTap: () {
                  Navigator.pop(context);
                  _showFullAvatar(context);
                },
              ),
              
              // ไปหน้าโปรไฟล์
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('ไปหน้าโปรไฟล์'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onPressed();
                },
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showFullAvatar(BuildContext context) {
    if (_avatarUrl == null) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Full Size Image - Circle
            Container(
              width: 400,
              height: 400,
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 400,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarImage(_avatarUrl!, size: 400),
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่มไปหน้าโปรไฟล์
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onPressed();
              },
              icon: const Icon(Icons.person),
              label: const Text('ไปหน้าโปรไฟล์'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _loadAvatar() async {
    if (widget.authState.accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    if (_isLoading) return; // ป้องกัน double loading
    
    setState(() => _isLoading = true);
    
    try {
      final profile = await ProfileService.getProfile(
        widget.authState.accessToken!,
      );
      
      debugPrint('📡 ProfileService.getProfile() returned: $profile');
      
      if (mounted && profile != null) {
        // Priority: avatarUrl (uploaded) > photoUrl (OAuth)
        // เมื่ออัปโหลดรูปใหม่ → แสดงรูปที่อัปโหลด แทน OAuth photo
        final avatarUrl = profile['avatarUrl'];
        final photoUrl = profile['photoUrl'];
        
        debugPrint('🔍 Profile loaded: avatarUrl=$avatarUrl, photoUrl=$photoUrl');
        
        setState(() {
          _avatarUrl = avatarUrl ?? photoUrl;  // ✅ uploaded > OAuth
          _isLoading = false;
        });
        
        debugPrint('✅ Final _avatarUrl: $_avatarUrl');
      }
    } catch (e) {
      debugPrint('❌ Error loading avatar: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Widget _buildAvatarImage(String avatarUrl, {double size = 32}) {
    // Check if URL or Base64
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      // OAuth HTTP URL - ใช้ Backend Proxy เพื่อ bypass rate limit
      String imageUrl = avatarUrl;
      if (avatarUrl.contains('googleusercontent.com')) {
        // ใช้ Backend Proxy แทน direct Google URL
        imageUrl = 'http://localhost:3000/api/proxy/avatar?url=${Uri.encodeComponent(avatarUrl)}';
        debugPrint('🔄 Using proxy URL: $imageUrl');
      }
      
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        cacheWidth: size.toInt() * 2,  // Cache ขนาด 2x เพื่อลด requests
        cacheHeight: size.toInt() * 2,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Failed to load OAuth avatar: $imageUrl');
          debugPrint('Error: $error');
          // แสดง Icon แทนรูป (มี background เขียว)
          return Container(
            width: size,
            height: size,
            color: const Color(0xFF4CAF50),
            child: Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      // Base64 uploaded avatar
      return Image.memory(
        base64Decode(avatarUrl.split(',')[1]),
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return IconButton(
        icon: const Icon(Icons.person),
        onPressed: widget.onPressed,
        tooltip: 'โปรไฟล์',
      );
    }
    
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      // แสดงรูป Avatar
      try {
        return IconButton(
          icon: ClipOval(
            child: Container(
              width: 32,
              height: 32,
              child: _buildAvatarImage(_avatarUrl!),
            ),
          ),
          onPressed: () => _showFullAvatar(context),
          tooltip: 'ดูรูปโปรไฟล์',
        );
      } catch (e) {
        // ถ้า decode ไม่ได้ แสดง Icon เริ่มต้น
        return IconButton(
          icon: const Icon(Icons.person),
          onPressed: widget.onPressed,
          tooltip: 'โปรไฟล์',
        );
      }
    }
    
    // แสดง Icon เริ่มต้น
    return IconButton(
      icon: const Icon(Icons.person),
      onPressed: widget.onPressed,
      tooltip: 'โปรไฟล์',
    );
  }
}
