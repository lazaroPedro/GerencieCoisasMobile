import 'package:flutter/material.dart';
import 'package:gerencie_coisas/core/theme/app_colors.dart';
import 'package:gerencie_coisas/core/theme/dark_app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.bodyBg,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.cyan,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    dividerColor: AppColors.border,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: DarkAppColors.bodyBg,

    colorScheme: ColorScheme.dark(
      primary: DarkAppColors.primary,
      secondary: DarkAppColors.cyan,
      surface: DarkAppColors.surface,
      error: DarkAppColors.danger,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: DarkAppColors.surface,
      elevation: 0,
      foregroundColor: DarkAppColors.textPrimary,
    ),

    cardTheme: CardThemeData(
      color: DarkAppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: DarkAppColors.textSecondary,
        fontSize: 15,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DarkAppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    dividerColor: DarkAppColors.border,
  );
}