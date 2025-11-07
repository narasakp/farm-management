import 'package:flutter/material.dart';

/// Mobile-First Responsive Helper
/// ออกแบบสำหรับมือถือก่อน แล้วค่อยขยายไป Tablet/Desktop
class MobileResponsiveHelper {
  /// Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  /// ตรวจสอบ device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;
  
  /// Padding - Mobile First
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(20);
    return const EdgeInsets.all(24);
  }
  
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }
  
  /// Spacing - Mobile First
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 8;
    if (isTablet(context)) return 12;
    return 16;
  }
  
  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 20;
  }
  
  /// Font Sizes - Mobile First
  static double getHeadlineFontSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 24;
    return 28;
  }
  
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 18;
    return 20;
  }
  
  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 15;
    return 16;
  }
  
  static double getCaptionFontSize(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 13;
    return 14;
  }
  
  /// Button Sizes - Touch-friendly
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) return 48; // Min touch target
    return 44;
  }
  
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 24;
    if (isTablet(context)) return 22;
    return 20;
  }
  
  /// Grid/List - Responsive columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }
  
  static int getStatCardsPerRow(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }
  
  /// Form Field Sizes
  static double getTextFieldHeight(BuildContext context) {
    if (isMobile(context)) return 56; // Larger for mobile
    return 48;
  }
  
  /// Card Sizes
  static double getCardElevation(BuildContext context) {
    if (isMobile(context)) return 1;
    return 2;
  }
  
  static BorderRadius getCardBorderRadius(BuildContext context) {
    if (isMobile(context)) return BorderRadius.circular(8);
    if (isTablet(context)) return BorderRadius.circular(10);
    return BorderRadius.circular(12);
  }
  
  /// Layout Direction - Mobile: Column, Desktop: Row
  static Axis getFormFieldAxis(BuildContext context) {
    return isMobile(context) ? Axis.vertical : Axis.horizontal;
  }
  
  static bool shouldUseColumn(BuildContext context) => isMobile(context);
  
  /// Stat Card Width (for dashboard)
  static double? getStatCardWidth(BuildContext context) {
    if (isMobile(context)) return null; // Full width with Expanded
    if (isTablet(context)) return 200;
    return 240;
  }
  
  /// Dialog/Modal Width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) return screenWidth * 0.9;
    if (isTablet(context)) return 500;
    return 600;
  }
  
  /// App Bar Height
  static double getAppBarHeight(BuildContext context) {
    if (isMobile(context)) return 56;
    return 64;
  }
  
  /// Wrap or Row - สำหรับ buttons
  static Widget responsiveButtonRow(
    BuildContext context,
    List<Widget> children, {
    MainAxisAlignment alignment = MainAxisAlignment.end,
  }) {
    if (isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: child,
                ))
            .toList(),
      );
    }
    return Row(
      mainAxisAlignment: alignment,
      children: children
          .map((child) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: child,
              ))
          .toList(),
    );
  }
  
  /// Responsive Divider
  static Widget getDivider(BuildContext context) {
    if (isMobile(context)) {
      return const Divider(height: 24, thickness: 1);
    }
    return const Divider(height: 32, thickness: 1);
  }
}
