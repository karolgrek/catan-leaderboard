import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

export '../../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBrick,
        primary: AppColors.primaryBrick,
        secondary: AppColors.wheatGold,
        tertiary: AppColors.forestPine,
        surface: AppColors.surfaceWhite,
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
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
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
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBrick,
          backgroundColor: AppColors.outlinedButtonSurface,
          side: const BorderSide(color: AppColors.primaryBrick, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.buttonBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          borderSide: const BorderSide(color: AppColors.primaryBrick, width: 2),
        ),
      ),
    );
  }
}
