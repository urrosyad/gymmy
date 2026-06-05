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
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.lightSecondaryText);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: AppColors.lightSecondaryText,
            fontSize: 11,
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = AppTypography.textTheme.apply(
      bodyColor: AppColors.darkPrimaryText,
      displayColor: AppColors.darkPrimaryText,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.darkMutedLime,
        tertiary: AppColors.accent,
        surface: AppColors.darkSurface,
        surfaceContainerLowest: AppColors.darkBackground,
        surfaceContainerLow: AppColors.darkSurface,
        surfaceContainer: AppColors.darkCardSurface,
        surfaceContainerHigh: AppColors.darkElevatedSurface,
        surfaceContainerHighest: AppColors.darkElevatedSurface,
        onPrimary: AppColors.darkOnLime,
        onSecondary: AppColors.darkPrimaryText,
        onSurface: AppColors.darkPrimaryText,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorder,
        error: AppColors.darkError,
        onError: AppColors.darkPrimaryText,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkPrimaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        space: 1,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkElevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.darkPrimaryText,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkSecondaryText,
          height: 1.45,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.darkSurface,
        modalBarrierColor: Color(0xAA000000),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkElevatedSurface,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkPrimaryText,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkBorder,
        circularTrackColor: AppColors.darkBorder,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardSurface,
        labelStyle: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.darkSecondaryText,
        ),
        floatingLabelStyle: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkMutedText,
        ),
        errorStyle: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.darkError,
        ),
        prefixIconColor: AppColors.darkSecondaryText,
        suffixIconColor: AppColors.darkSecondaryText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.darkOnLime,
          disabledBackgroundColor: AppColors.darkElevatedSurface,
          disabledForegroundColor: AppColors.darkMutedText,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: baseTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.darkOnLime,
          disabledBackgroundColor: AppColors.darkElevatedSurface,
          disabledForegroundColor: AppColors.darkMutedText,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: baseTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimaryText,
          disabledForegroundColor: AppColors.darkMutedText,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: baseTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: baseTextTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkOnLime,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCardSurface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.darkSurface,
        side: const BorderSide(color: AppColors.darkBorder),
        labelStyle: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.darkSecondaryText,
        ),
        secondaryLabelStyle: baseTextTheme.labelMedium?.copyWith(
          color: AppColors.darkOnLime,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.darkSecondaryText,
        textColor: AppColors.darkPrimaryText,
        titleTextStyle: baseTextTheme.titleSmall?.copyWith(
          color: AppColors.darkPrimaryText,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.darkSecondaryText,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.darkMutedText);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(color: AppColors.darkMutedText, fontSize: 11);
        }),
      ),
    );
  }
}
