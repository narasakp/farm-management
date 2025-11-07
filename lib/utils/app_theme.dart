import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2F855A);
  static const Color secondaryColor = Color(0xFF38A169);
  static const Color accentColor = Color(0xFF68D391);
  static const Color backgroundColor = Color(0xFFF7FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFED8936);
  static const Color successColor = Color(0xFF38A169);
  static const Color textPrimaryColor = Color(0xFF2D3748);
  static const Color textSecondaryColor = Color(0xFF4A5568);

  static ThemeData get lightTheme {
    return ThemeData(
      // ปรับขนาด Icon ทั้งระบบ
      iconTheme: const IconThemeData(
        size: 32, // เพิ่มจาก 24 (default) → 32 (+33%)
        color: textPrimaryColor,
      ),
      primaryIconTheme: const IconThemeData(
        size: 32,
        color: Colors.white,
      ),
      primarySwatch: MaterialColor(
        primaryColor.value,
        <int, Color>{
          50: const Color(0xFFE6FFFA),
          100: const Color(0xFFB2F5EA),
          200: const Color(0xFF81E6D9),
          300: const Color(0xFF4FD1C7),
          400: const Color(0xFF38B2AC),
          500: primaryColor,
          600: const Color(0xFF2C7A7B),
          700: const Color(0xFF285E61),
          800: const Color(0xFF234E52),
          900: const Color(0xFF1D4044),
        },
      ),
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          size: 32, // เพิ่มจาก 24 → 32 (+33%)
          color: Colors.black87,
        ),
        titleTextStyle: TextStyle(
          fontSize: 28, // เพิ่มจาก 24 → 28 (+17%)
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 22, // เพิ่มจาก 18 → 22 (+22%)
            fontWeight: FontWeight.w600,
            ),
        ),
      ),
      textTheme: const TextTheme(
        // Display styles สำหรับ headings ใหญ่
        displayLarge: TextStyle(
          fontSize: 56, // เพิ่มจาก 40 → 56 (+40%)
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontSize: 48, // เพิ่มจาก 36 → 48 (+33%)
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontSize: 42, // เพิ่มจาก 32 → 42 (+31%)
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        // Headline styles สำหรับ section headers
        headlineLarge: TextStyle(
          fontSize: 38, // เพิ่มจาก 28 → 38 (+36%)
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 32, // เพิ่มจาก 24 → 32 (+33%)
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 28, // เพิ่มจาก 22 → 28 (+27%)
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        // Title styles สำหรับ card titles
        titleLarge: TextStyle(
          fontSize: 26, // เพิ่มจาก 20 → 26 (+30%)
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 22, // เพิ่มจาก 18 → 22 (+22%)
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        // Body styles สำหรับเนื้อหาทั่วไป (สำคัญที่สุดสำหรับผู้สูงอายุ)
        bodyLarge: TextStyle(
          fontSize: 22, // เพิ่มจาก 18 → 22 (+22%)
          fontWeight: FontWeight.normal,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 20, // เพิ่มจาก 16 → 20 (+25%)
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
        ),
        bodySmall: TextStyle(
          fontSize: 18, // เพิ่มจาก 16 → 18 (+12.5%)
          fontWeight: FontWeight.normal,
          color: textSecondaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // เพิ่ม padding
        labelStyle: const TextStyle(fontSize: 20), // เพิ่มจาก 16 → 20 (+25%)
        hintStyle: const TextStyle(fontSize: 20), // เพิ่มจาก 16 → 20 (+25%)
        helperStyle: const TextStyle(fontSize: 18), // เพิ่มจาก 16 → 18 (+12.5%)
        errorStyle: const TextStyle(fontSize: 18), // เพิ่มจาก 16 → 18 (+12.5%)
      ),
    );
  }
}
