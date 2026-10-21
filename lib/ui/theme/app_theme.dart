import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBrick = Color(0xFFC63B12);
  static const Color wheatGold = Color(0xFFE5B53B);
  static const Color sheepGreen = Color(0xFF88B664);
  static const Color oreSlate = Color(0xFF7A8B99);
  static const Color terracottaClay = Color(0xFFD16B47);
  static const Color forestPine = Color(0xFF4E7D52);

  static const Color parchmentBase = Color(0xFFF3EAD8);
  static const Color cardSurface = Color(0xEBFFFDF9);
  static const Color cardBorder = Color(0xFFE2CCB0);
  static const Color drawerSurface = Color(0xFFFBF6ED);
  static const Color drawerBorder = Color(0xFFDEC5A4);
  static const Color appBarTrim = Color(0xFFE0C097);
  static const Color chitBackground = Color(0xFFF3E3C3);
  static const Color chitBorder = Color(0xFFB89F78);

  static const Color textPrimary = Color(0xFF2B1D16);
  static const Color textSecondary = Color(0xFF6D5446);

  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankBronze = Color(0xFFCD7F32);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBrick,
        primary: AppColors.primaryBrick,
        secondary: AppColors.wheatGold,
        tertiary: AppColors.forestPine,
        surface: const Color(0xFFFFFDF9),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBrick,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: AppColors.appBarTrim, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        color: AppColors.cardSurface,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrick,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBrick,
          backgroundColor: const Color(0xE6FFFDF9),
          side: const BorderSide(color: AppColors.primaryBrick, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xF2FFFDF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBrick, width: 2),
        ),
      ),
    );
  }
}
