import 'package:flutter/material.dart';

// =======================================================================
// HOME_ASIS - Tema Aplikasi
// -----------------------------------------------------------------------
// Mengikuti Google Material Design 3 (SRS 3.1) dengan warna identitas
// hijau kebiruan (kesan "asisten rumah tangga profesional") dipadu aksen
// oranye untuk elemen aksi (Call-To-Action).
// =======================================================================
class AppColors {
  AppColors._();

  static const seed = Color(0xFF00796B);
  static const accent = Color(0xFFFFA726);
  static const background = Color(0xFFF5F7F7);
  static const danger = Color(0xFFC62828);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF9A825);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.seed, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.seed.withOpacity(0.12),
    ),
  );
}
