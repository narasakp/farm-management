import 'package:flutter/material.dart';

/// Notification types with severity levels
enum NotificationType {
  success,
  info,
  warning,
  error,
}

/// Standard notification helper for consistent UI
/// 
/// Usage:
/// ```dart
/// NotificationHelper.show(
///   context,
///   'Operation successful!',
///   NotificationType.success,
/// );
/// ```
class NotificationHelper {
  /// Show centered notification with auto-dismiss
  /// 
  /// - Position: Center of screen (40% from top)
  /// - Text: Center aligned
  /// - Duration: 5 seconds
  /// - Color: Based on severity
  static void show(
    BuildContext context,
    String message,
    NotificationType type,
  ) {
    final colors = {
      NotificationType.success: Colors.green.shade600,
      NotificationType.info: Colors.blue.shade600,
      NotificationType.warning: Colors.orange.shade600,
      NotificationType.error: Colors.red.shade600,
    };
    
    final icons = {
      NotificationType.success: Icons.check_circle,
      NotificationType.info: Icons.info_outline,
      NotificationType.warning: Icons.warning_amber,
      NotificationType.error: Icons.error_outline,
    };
    
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4, // Center vertically
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors[type],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icons[type],
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
  
  /// Quick shortcuts for common notifications
  static void success(BuildContext context, String message) {
    show(context, message, NotificationType.success);
  }
  
  static void info(BuildContext context, String message) {
    show(context, message, NotificationType.info);
  }
  
  static void warning(BuildContext context, String message) {
    show(context, message, NotificationType.warning);
  }
  
  static void error(BuildContext context, String message) {
    show(context, message, NotificationType.error);
  }
}
