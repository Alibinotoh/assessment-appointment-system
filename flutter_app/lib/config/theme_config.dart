import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Color Palette
  static const Color primaryMaroon = Color(0xFF8B1538);
  static const Color primaryNavy = Color(0xFF1B1464);
  static const Color primaryGold = Color(0xFFFFD700);

  // UI Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color accentPink = Color(0xFFE91E63);

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Stress Level Colors (using logo palette)
  static const Color stressLow = Color(0xFF4CAF50); // Green
  static const Color stressMedium = Color(0xFFFFC107); // Yellow
  static const Color stressHigh = Color(0xFF8B1538); // Maroon
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryMaroon,
        secondary: primaryNavy,
        surface: surface,
        background: background,
        error: error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryMaroon,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMaroon,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryMaroon, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surface,
      ),
    );
  }
  
  static Color getStressLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return stressLow;
      case 'moderate':
        return stressMedium;
      case 'high':
        return stressHigh;
      default:
        return textSecondary;
    }
  }
}
