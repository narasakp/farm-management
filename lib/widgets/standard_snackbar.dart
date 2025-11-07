import 'package:flutter/material.dart';

/// Standard Snackbar Helper Functions
/// Custom Design for Farm Management System
/// 
/// Features:
/// - Center position (ไม่บังโดย Feedback Icon)
/// - Center-aligned text
/// - Severity-based colors
/// - Icon support
/// - Rounded corners
/// - Auto-dismiss
class StandardSnackbar {
  
  /// Show success message
  /// Usage: StandardSnackbar.showSuccess(context, 'บันทึกสำเร็จ');
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  /// Show error message
  /// Usage: StandardSnackbar.showError(context, 'เกิดข้อผิดพลาด');
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool showCloseButton = true,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error,
      backgroundColor: Colors.red.shade600,
      duration: duration,
      actionLabel: showCloseButton ? 'ปิด' : null,
      onAction: showCloseButton 
          ? () => ScaffoldMessenger.of(context).hideCurrentSnackBar() 
          : null,
    );
  }
  
  /// Show warning message
  /// Usage: StandardSnackbar.showWarning(context, 'โปรดตรวจสอบข้อมูล');
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning,
      backgroundColor: Colors.orange.shade600,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  /// Show info message
  /// Usage: StandardSnackbar.showInfo(context, 'ข้อมูลอัปเดตแล้ว');
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info,
      backgroundColor: Colors.blue.shade600,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  /// Internal method to show centered overlay notification
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _CenterNotification(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

/// Center Notification Widget
class _CenterNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const _CenterNotification({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  State<_CenterNotification> createState() => _CenterNotificationState();
}

class _CenterNotificationState extends State<_CenterNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
    
    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon (Large, Center)
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    
                    // Message (Center-aligned)
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    
                    // Action Button (if provided)
                    if (widget.actionLabel != null) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          widget.onAction?.call();
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
