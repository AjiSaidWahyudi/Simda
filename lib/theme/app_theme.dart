import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.blue600,
      secondary: AppColors.blue100,
      background: AppColors.slate100,
      surface: AppColors.white,
      onPrimary: AppColors.white,
      onBackground: AppColors.slate900,
      onSurface: AppColors.slate900,
      error: AppColors.danger,
    );

    return ThemeData(
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colorScheme.onBackground,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.slate500,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.blue600,
      secondary: AppColors.blue800,
      background: AppColors.slate900,
      surface: AppColors.slate700,
      onPrimary: AppColors.white,
      onBackground: AppColors.white,
      onSurface: AppColors.white,
      error: AppColors.danger,
    );

    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onBackground,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onBackground,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colorScheme.onBackground,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.slate300,
        ),
      ),
    );
  }
}
