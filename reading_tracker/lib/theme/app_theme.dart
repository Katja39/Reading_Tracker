import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildLightTheme();
  static ThemeData get dark => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8D6C3F),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF7A5C35),
      onPrimary: const Color(0xFFFFF8EC),
      secondary: const Color(0xFF9D7240),
      onSecondary: const Color(0xFF2F1E08),
      surface: const Color(0xFFFAF5EA),
      onSurface: const Color(0xFF231E17),
      error: const Color(0xFFB3261E),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      outline: const Color(0xFF7B7062),
      outlineVariant: const Color(0xFFD8CFC0),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1E9DB),
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
          borderRadius: BorderRadius.circular(16),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A6A42),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFD2B27D),
      onPrimary: const Color(0xFF34220B),
      secondary: const Color(0xFFC69A66),
      onSecondary: const Color(0xFF2E1B07),
      surface: const Color(0xFF1B1A17),
      onSurface: const Color(0xFFE8DDD0),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF5D1715),
      onErrorContainer: const Color(0xFFFFDAD6),
      outline: const Color(0xFF8A7560),
      outlineVariant: const Color(0xFF45382C),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF141518),
      visualDensity: VisualDensity.standard,
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1B1F),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF211A13),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
        fillColor: const Color(0xFF251E16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1B1F),
        indicatorColor: scheme.primary.withOpacity(0.2),
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
        backgroundColor: const Color(0xFF211A13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
