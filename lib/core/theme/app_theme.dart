import 'package:flutter/material.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.lightPrimaryText,
        onSecondary: AppColors.lightSurface,
        onSurface: AppColors.lightPrimaryText,
        error: AppColors.error,
        onError: AppColors.lightSurface,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.lightPrimaryText,
        displayColor: AppColors.lightPrimaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightPrimaryText,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkPrimaryText,
        onSurface: AppColors.darkPrimaryText,
        error: AppColors.error,
        onError: AppColors.darkPrimaryText,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.darkPrimaryText,
        displayColor: AppColors.darkPrimaryText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
