// Application light and dark ThemeData definitions
import 'package:flutter/material.dart';

import 'app_tokens.dart';
//https://developer.android.com/design/ui/mobile/guides/styles/color?hl=de

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildLightTheme();
  static ThemeData get dark => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFF8EC),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF2F4858),
      onPrimary: const Color(0xFFFFF8EC),
      primaryContainer: const Color(0xFF7798AB),
      onPrimaryContainer: const Color(0xFFFFF8EC),
      secondary: const Color(0xFF2F4858),
      onSecondary: const Color(0xFF2F1E08),
      surface: const Color(0xFFFFF8EC),
      onSurface: const Color(0xFF231E17),
      error: const Color(0xFFB3261E),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      outline: const Color.fromARGB(255, 128, 79, 16),
      outlineVariant: const Color(0xFFD8CFC0),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFF8EC),
      visualDensity: VisualDensity.standard,
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFEDE4D5),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFF9EF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFCF6EB),
        contentPadding: AppInsets.inputContent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFEDE4D5),
        indicatorColor: scheme.primary.withOpacity(0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary);
          }
          return IconThemeData(color: scheme.onSurface.withOpacity(0.8));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(color: scheme.onSurface.withOpacity(0.8));
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFFF9EE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7798AB),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFA9C7D8),
      onPrimary: const Color(0xFF102631),
      primaryContainer: const Color(0xFF2F4858),
      onPrimaryContainer: const Color(0xFFFFF8EC),
      secondary: const Color(0xFFA9C7D8),
      onSecondary: const Color(0xFF102631),
      secondaryContainer: const Color(0xFF2F4858),
      onSecondaryContainer: const Color(0xFFFFF8EC),
      surface: const Color(0xFF111B22),
      onSurface: const Color(0xFFF4EDE2),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF5D1715),
      onErrorContainer: const Color(0xFFFFDAD6),
      outline: const Color(0xFFFFF8EC),
      outlineVariant: const Color(0xFF3B4E58),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
      visualDensity: VisualDensity.standard,
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF17232B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1D2B34),
        contentPadding: AppInsets.inputContent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          foregroundColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary);
          }
          return IconThemeData(color: scheme.onSurface.withOpacity(0.8));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(color: scheme.onSurface.withOpacity(0.8));
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF17232B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
    );
  }
}