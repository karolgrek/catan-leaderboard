import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand & Catan Resource Colors
  static const Color primaryBrick = Color(0xFFC63B12);
  static const Color wheatGold = Color(0xFFE5B53B);
  static const Color sheepGreen = Color(0xFF88B664);
  static const Color oreSlate = Color(0xFF7A8B99);
  static const Color terracottaClay = Color(0xFFD16B47);
  static const Color forestPine = Color(0xFF4E7D52);

  static const List<Color> resourcePalette = [
    wheatGold,
    sheepGreen,
    oreSlate,
    terracottaClay,
    forestPine,
  ];

  // Background & Surface Colors
  static const Color parchmentBase = Color(0xFFF3EAD8);
  static const Color surfaceWhite = Color(0xFFFFFDF9);
  static const Color cardSurface = Color(0xEBFFFDF9);
  static const Color leaderCardSurface = Color(0xF5FFFDF0);
  static const Color outlinedButtonSurface = Color(0xE6FFFDF9);
  static const Color inputFillSurface = Color(0xF2FFFDF9);
  static const Color cardBorder = Color(0xFFE2CCB0);
  static const Color drawerSurface = Color(0xFFFBF6ED);
  static const Color drawerBorder = Color(0xFFDEC5A4);
  static const Color appBarTrim = Color(0xFFE0C097);
  static const Color chitBackground = Color(0xFFF3E3C3);
  static const Color chitBorder = Color(0xFFB89F78);

  // Typography Colors
  static const Color textPrimary = Color(0xFF2B1D16);
  static const Color textSecondary = Color(0xFF6D5446);

  // Leaderboard Medal Colors
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankBronze = Color(0xFFCD7F32);

  // Status & Feedback Colors
  static const Color activeGreen = Colors.green;
  static const Color successGreen = Colors.green;
  static const Color errorRed = Colors.redAccent;
}
