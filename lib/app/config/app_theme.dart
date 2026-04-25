import 'package:flutter/material.dart';
import 'app_colors.dart';

class MyAppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyAppColors.primary,
        primary: MyAppColors.primary,
        secondary: MyAppColors.secondary,
        surface: MyAppColors.surface,
        background: MyAppColors.background,
        error: MyAppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: MyAppColors.textBody,
        onBackground: MyAppColors.textBody,
      ),
      scaffoldBackgroundColor: MyAppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: MyAppColors.surface,
        foregroundColor: MyAppColors.textBody,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyAppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: MyAppColors.textBody,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: MyAppColors.textBody,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: MyAppColors.textMuted,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: MyAppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: MyAppColors.primary,
        primary: MyAppColors.primary,
        secondary: MyAppColors.secondary,
        surface: MyAppColors.darkSurface,
        background: MyAppColors.darkBackground,
        error: MyAppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: MyAppColors.darkTextPrimary,
        onBackground: MyAppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: MyAppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: MyAppColors.darkSurface,
        foregroundColor: MyAppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyAppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: MyAppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: MyAppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: MyAppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: MyAppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
    );
  }
}