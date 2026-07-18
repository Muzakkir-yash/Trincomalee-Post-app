import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Tones - Premium Crimson, Rose Gold & Soft Slates
  static const Color primaryRed = Color(0xFFC01F2F); // Rich soft Crimson Red
  static const Color secondaryRed = Color(0xFF90111D); // Burgundy Red for deep contrast
  static const Color softRed = Color(0xFFFFF1F2); // Rose 50 tint (super clean pinkish/white background)
  static const Color glassWhite = Color(0xCCFFFFFF); // Transparent frosted white
  
  // Light Mode Neutrals (Modern iOS/Material Slate theme)
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50 (cleanest light background)
  static const Color cardLight = Colors.white;
  static const Color textDark = Color(0xFF0F172A); // Slate 900 (ultra crisp, premium readability)
  static const Color textMuted = Color(0xFF64748B); // Slate 500

  // Dark Mode Neutrals (Premium deep space theme)
  static const Color bgDark = Color(0xFF060814); // Deep space black/blue base
  static const Color cardDark = Color(0xFF0F1326); // Frosted navy card backplate
  static const Color borderDark = Color(0xFF1E2640); // Soft navy border
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // Status Tones (Vibrant, high contrast)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color danger = Color(0xFFEF4444); // Red 500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: secondaryRed,
        surface: cardLight,
        error: danger,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: textDark),
        titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: textDark),
        titleMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textDark, fontSize: 16, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 14, height: 1.5),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        color: cardLight,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryRed,
        unselectedLabelColor: textMuted,
        indicatorColor: primaryRed,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryRed, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.plusJakartaSans(color: textMuted.withAlpha(150)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFDA4AF), // Soft rose red to prevent screen glare
        secondary: Color(0xFFF43F5E),
        surface: cardDark,
        error: danger,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: textLight),
        displayMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: textLight),
        titleLarge: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: textLight),
        titleMedium: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textLight, fontSize: 16, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textLightMuted, fontSize: 14, height: 1.5),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderDark, width: 1.2),
        ),
        color: cardDark,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: const Color(0xFFFDA4AF),
        unselectedLabelColor: textLightMuted,
        indicatorColor: const Color(0xFFFDA4AF),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFE11D48), // Rose 600
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderDark, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderDark, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFDA4AF), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: textLightMuted, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.plusJakartaSans(color: textLightMuted.withAlpha(100)),
      ),
    );
  }
}
