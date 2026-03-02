import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seed = Color(0xFF1A1A1A);
  static const Color _accent = Color(0xFFFFFFFF);
  static const Color _surface = Color(0xFF121212);
  static const Color _background = Color(0xFF000000);
  static const Color _ink = Color(0xFFFFFFFF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _seed,
      secondary: _accent,
      surface: _surface,
      onSurface: _ink,
    ),
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _ink,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: _ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _ink,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        color: _ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: _ink,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF131313),
      selectedColor: _seed.withValues(alpha: 0.2),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(
          color: _ink.withValues(alpha: 0.12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}

