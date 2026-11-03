import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bespoke Architectural Gallery White Palette & Modern UI
  static const Color obsidian = Color(0xFFF8FAFC);      // Gallery soft off-white canvas (Slate 50)
  static const Color surfaceDark = Color(0xFFFFFFFF);   // Pristine pure white for sidebars, appbars & modals
  static const Color surfaceCard = Color(0xFFFFFFFF);   // Pristine pure white cards & containers
  static const Color surfaceBorder = Color(0xFFE2E8F0); // Subtle architectural hairline divider (Slate 200)

  // Architectural Brand Metals & Accents
  static const Color goldPrimary = Color(0xFFB48A1A);   // Rich Florentine Gold (high contrast & luxury on light)
  static const Color brassAccent = Color(0xFF9A7818);   // Satin architectural bronze
  static const Color warmCream = Color(0xFF1E293B);     // Deep architectural slate

  // Status & Dynamic Indicators
  static const Color tealAccent = Color(0xFF0284C7);    // Vibrant ocean sky (Sky 600)
  static const Color tealPrimary = Color(0xFF0284C7);
  static const Color emeraldSuccess = Color(0xFF059669);// Crisp emerald green (Emerald 600)
  static const Color amberWarning = Color(0xFFD97706);  // Warm amber (Amber 600)
  static const Color roseDanger = Color(0xFFE11D48);    // Vivid rose coral (Rose 600)

  // High-legibility Slate Typography
  static const Color textMuted = Color(0xFF64748B);     // Slate 500 for secondary text & metadata
  static const Color textLight = Color(0xFF0F172A);     // Slate 900 for primary headlines & razor-sharp body text

  // Modern White Theme Specification
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: obsidian,
      primaryColor: goldPrimary,
      cardColor: surfaceCard,
      colorScheme: const ColorScheme.light(
        primary: goldPrimary,
        secondary: brassAccent,
        surface: surfaceCard,
        error: roseDanger,
        onPrimary: Colors.white,
        onSurface: textLight,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textLight, letterSpacing: -0.5),
        displayMedium: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: textLight),
        titleMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: textLight),
        bodyLarge: GoogleFonts.outfit(fontSize: 14, color: textLight),
        bodyMedium: GoogleFonts.outfit(fontSize: 13, color: textMuted),
        labelLarge: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: goldPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: goldPrimary),
        titleTextStyle: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      dividerColor: surfaceBorder,
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: const BorderSide(color: goldPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: goldPrimary, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 13),
      ),
    );
  }

  // Alias for backward compatibility ensuring the app always presents the modern light theme
  static ThemeData get darkTheme => lightTheme;
}
