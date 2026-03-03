import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primary = Color(0xFF1B998B);
  static const Color _secondary = Color(0xFFF2C94C);
  static const Color _surface = Color(0xFF0F1521);
  static const Color _background = Color(0xFF070A12);
  static const Color _ink = Color(0xFFF6F7FB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      onSurface: _ink,
      background: _background,
    ),
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _ink,
    ),
    textTheme: _buildTextTheme(),
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF121826),
      selectedColor: _primary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
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
    tabBarTheme: TabBarTheme(
      labelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );

  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);
    return base.copyWith(
      headlineLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.08,
        color: _ink,
      ),
      headlineMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: _ink,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        height: 1.5,
        color: _ink,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.55,
        color: _ink,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: _ink,
      ),
    );
  }
}

