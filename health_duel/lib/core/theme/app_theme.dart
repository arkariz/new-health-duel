import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'extensions/extensions.dart';
import 'tokens/tokens.dart';

/// Application Theme Configuration
///
/// Provides centralized theme management for Light and Dark modes.
/// Typography: Syne (display/headline/titleLarge) + DM Sans (body/label/title sm/md)
///
/// Color palette matches the sports-energy mockup design system:
/// - Primary: #00E5A0 (brand green, dark) / #00A87A (light, WCAG AA)
/// - Opponent: #FF6B35 (orange — via AppColorsExtension)
/// - Gold: #FFC94A (trophy/crown — via AppColorsExtension)
class AppTheme {
  AppTheme._(); // Private constructor

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Brand green — light mode (WCAG AA accessible on white)
  static const Color _primaryLight = Color(0xFF00A87A);

  /// Brand green — dark mode (sports-energy palette)
  static const Color _primaryDark = Color(0xFF00E5A0);

  /// Secondary blue — light mode
  static const Color _secondaryLight = Color(0xFF0E89C4);

  /// Secondary blue — dark mode (#38B6FF from mockup)
  static const Color _secondaryDark = Color(0xFF38B6FF);

  /// Error/danger red (#FF4D6A from mockup)
  static const Color errorColor = Color(0xFFFF4D6A);

  /// Warning amber (unchanged)
  static const Color warningColor = Color(0xFFF59E0B);

  /// Public alias for backward compat (= light primary)
  static const Color primaryColor = _primaryLight;

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A2B3C);
  static const Color lightOnSurfaceVariant = Color(0xFF4A6275);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE BACKGROUNDS (Mockup Design System)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Main scaffold background (--bg: #080c10)
  static const Color darkBackground = Color(0xFF080C10);

  /// Surface / input fill (--surface: #0e1318)
  static const Color darkSurface = Color(0xFF0E1318);

  /// Primary text color (--text: #e8f0f5)
  static const Color darkOnSurface = Color(0xFFE8F0F5);

  /// Secondary / subtitle text (--sub: #7a95a8)
  static const Color darkOnSurfaceVariant = Color(0xFF7A95A8);

  /// Border / separator (--border: #1e2a34)
  static const Color darkOutline = Color(0xFF1E2A34);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        secondary: _secondaryLight,
        surface: lightSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
        onError: Colors.white,
        outline: Color(0xFFE5E7EB),
      ),
      scaffoldBackgroundColor: lightBackground,

      // Theme Extensions (ADR-005)
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension.light,
      ],

      // Typography: Syne (display/headline/title) + DM Sans (body/label)
      textTheme: _buildTextTheme(lightOnSurface),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightOnSurface,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
        ),
        color: lightSurface,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: _primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          side: const BorderSide(color: _primaryLight),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: darkSurface,
        error: errorColor,
        onPrimary: Color(0xFF060A0E), // Near-black on bright green (mockup style)
        onSecondary: Colors.white,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        onError: Colors.white,
        outline: darkOutline,
      ),
      scaffoldBackgroundColor: darkBackground,

      // Theme Extensions (ADR-005)
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension.dark,
      ],

      // Typography: Syne (display/headline/title) + DM Sans (body/label)
      textTheme: _buildTextTheme(darkOnSurface),

      // AppBar (seamless — same color as scaffold)
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: darkBackground,
        foregroundColor: darkOnSurface,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: const BorderSide(color: darkOutline),
        ),
        color: const Color(0xFF141B22), // --card
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF141B22), // card level, one step above surface
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgBorder,
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBorder,
          ),
          side: const BorderSide(color: darkOutline),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: _primaryDark,
        foregroundColor: Color(0xFF060A0E),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: darkOutline,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TYPOGRAPHY
  // Syne: display*, headline*, titleLarge  — impactful numbers & headings
  // DM Sans: titleMedium/Small, body*, label* — readable body & labels
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      // ── Syne: Display (step counts, hero numbers) ──
      displayLarge:  GoogleFonts.syne(fontSize: 57, fontWeight: FontWeight.w800, color: color),
      displayMedium: GoogleFonts.syne(fontSize: 45, fontWeight: FontWeight.w700, color: color),
      displaySmall:  GoogleFonts.syne(fontSize: 36, fontWeight: FontWeight.w700, color: color),

      // ── Syne: Headlines (screen titles, section headers) ──
      headlineLarge:  GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w700, color: color),
      headlineSmall:  GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w700, color: color),

      // ── Syne: titleLarge (card headings, large titles) ──
      titleLarge: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: color),

      // ── DM Sans: titleMedium/Small (player names, card subtitles) ──
      titleMedium: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleSmall:  GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: color),

      // ── DM Sans: Body ──
      bodyLarge:  GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall:  GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: color),

      // ── DM Sans: Labels (tags, chips, button text) ──
      labelLarge:  GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      labelMedium: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall:  GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: color),
    );
  }
}
