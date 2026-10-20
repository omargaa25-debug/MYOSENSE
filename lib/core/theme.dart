import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0B0F10);
  static const card = Color(0xFF151A1B);
  static const volt = Color(0xFFC6F432); // accent lime
  static const textPrimary = Color(0xFFEEF2EE);
  static const textMuted = Color(0xFF9EA5A2);
  static const warning = Color(0xFFFF7A2F);
  static const danger = Color(0xFFFF3B30);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.volt,
          surface: AppColors.card,
        ),
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      );
}