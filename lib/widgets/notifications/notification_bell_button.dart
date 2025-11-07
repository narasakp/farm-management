/// Notification Bell Button with Badge
/// แสดงปุ่มกระดิ่งพร้อม badge จำนวน unread notifications

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../providers/notification_provider.dart';
import '../../providers/production_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_dropdown.dart';

class NotificationBellButton extends ConsumerStatefulWidget {
  const NotificationBellButton({super.key});

  @override
  ConsumerState<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends ConsumerState<NotificationBellButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    
    debugPrint('🔔 [NotificationBellButton] initState called');
    
    // Initialize notification provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        debugPrint('⚠️ [NotificationBellButton] Widget not mounted, skipping init');
        return;
      }
      
      final authState = ref.read(productionAuthProvider);
      debugPrint('🔐 [NotificationBellButton] Auth state:');
      debugPrint('  - isAuthenticated: ${authState.isAuthenticated}');
      debugPrint('  - user: ${authState.user}');
      
      if (authState.isAuthenticated && authState.user != null) {
        final userId = authState.user!['id']?.toString();
        debugPrint('👤 [NotificationBellButton] userId: $userId');
        
        if (userId != null && userId.isNotEmpty && mounted) {
          debugPrint('✅ [NotificationBellButton] Initializing NotificationProvider with userId: $userId');
          context.read<NotificationProvider>().initialize(userId);
        } else {
          debugPrint('⚠️ [NotificationBellButton] userId is null or empty, skipping initialization');
        }
      } else {
        debugPrint('⚠️ [NotificationBellButton] User not authenticated, skipping initialization');
      }
    });
  }

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!mounted) return;
    
    final authState = ref.read(productionAuthProvider);
    if (!authState.isAuthenticated || authState.user == null) return;

    final userId = authState.user!['id']?.toString();
    if (userId == null || userId.isEmpty) return;
    
    // Load latest notifications
    if (mounted) {
      context.read<NotificationProvider>().loadNotifications(userId);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop to close dropdown
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Dropdown positioned below bell icon
          Positioned(
            width: 400,
            child: CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 8),
              child: IgnorePointer(
                ignoring: false,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: NotificationDropdown(
                    userId: userId,
                    onClose: _closeDropdown,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    // Close dropdown when widget is deactivated (e.g., navigating away)
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    // Clean up overlay before disposing
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider_pkg.Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;
        
        debugPrint('🔔 [NotificationBellButton] Build called');
        debugPrint('  - unreadCount: $unreadCount');
        debugPrint('  - notifications: ${notificationProvider.notifications.length}');
        debugPrint('  - isLoading: ${notificationProvider.isLoading}');
        debugPrint('  - error: ${notificationProvider.error}');

        return CompositedTransformTarget(
          link: _layerLink,
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _toggleDropdown,
                tooltip: 'การแจ้งเตือน',
              ),
              // Badge
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
