import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final effectiveBackgroundColor = backgroundColor ?? const Color(0xFF228B22); // Default to Forest Green
    final effectiveForegroundColor = foregroundColor ?? Colors.white; // Default to white

    return AppBar(
      title: Text(title, style: TextStyle(color: effectiveForegroundColor)),
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: 2,
      shadowColor: Colors.black26,
      centerTitle: false,
      titleSpacing: 8.0, // Creates a nice space between the leading icon and the title
      // Replace the default back button with a Home button.
      // The default back button is implicitly added when `leading` is null and `automaticallyImplyLeading` is true.
      leading: IconButton(
        icon: const Icon(Icons.home_rounded, size: 28),
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        tooltip: 'กลับหน้าหลัก',
        color: effectiveForegroundColor,
      ),
      actions: [], // User explicitly requested to remove the back button entirely.
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}
