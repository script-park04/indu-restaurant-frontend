import 'package:flutter/material.dart';

class AppTheme {
  // ─────────────────────────────────────────────
  // Vibrant Fuchsia Color Palette
  // ─────────────────────────────────────────────
  static const Color fuchsiaRed = Color(0xFFFF2E63);   // Vibrant Pink/Red
  static const Color fuchsiaBlue = Color(0xFF651FFF);  // Deep Electric Violet/Blue
  static const Color deepViolet = Color(0xFF4A148C);   // Darker purple for depth
  static const Color cyanAccent = Color(0xFF00E5FF);   // Cyberpunk pop
  static const Color softWhite = Color(0xFFFFFFFF);    // Pure white for contrast
  static const Color nightBlack = Color(0xFF1A1612);   // Deep dark background

  // Brand Mapping (Optimized for Contrast)
  static const Color primaryBrand = fuchsiaRed;
  static const Color secondaryBrand = fuchsiaBlue;
  static const Color accentBrand = cyanAccent;
  
  static const Color primaryBlue = fuchsiaBlue;
  static const Color primaryRed = fuchsiaRed;
  static const Color secondaryPurple = deepViolet;
  static const Color accentTeal = cyanAccent;
  
  // Auxiliary
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color secondaryGold = Color(0xFFFFD740);
  
  // Status
  static const Color success = Color(0xFF00C853); 
  static const Color warning = Color(0xFFFFAB00); 
  static const Color error = Color(0xFFD50000);   
  static const Color accentGreen = success;
  static const Color warmCream = softWhite;

  // ─────────────────────────────────────────────
  // Glass Surfaces
  // ─────────────────────────────────────────────
  static const Color glassLight = Color(0xCCF5F5FA);   // Cool white
  static const Color glassCard = Color(0xFFFFFFFF);    // Pure white glass
  static const Color glassDark = Color(0xCC12121A);    // Cool dark
  static const Color glassDarkCard = Color(0xCC1E1E2C); // Dark violet-ish

  // ─────────────────────────────────────────────
  // Text & Dividers
  // ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF); 
  static const Color divider = Color(0xFFEEEEEE);

  // ─────────────────────────────────────────────
  // Liquid Background Gradient
  // ─────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF5F7FA), // Cool grey start
      Color(0xFFC3CFE2), // Cool grey end
    ],
  );

  // ─────────────────────────────────────────────
  // Glass Decoration Helper
  // ─────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    BorderRadius? borderRadius,
    Color? color,
    double opacity = 0.5,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          (color ?? glassCard).withValues(alpha: opacity + 0.1),
          (color ?? glassCard).withValues(alpha: opacity),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // LIGHT THEME (GLASS)
  // ─────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'SF Pro Display',

    // IMPORTANT: transparent for LiquidBackground
    scaffoldBackgroundColor: Colors.transparent,

    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryPurple,
      tertiary: accentTeal,
      error: error,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: glassCard.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: textPrimary,
    ),

    cardTheme: CardThemeData(
      color: glassCard.withValues(alpha: 0.85),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: glassCard,
      selectedColor: primaryBrand,
      secondarySelectedColor: primaryBrand,
      labelStyle: const TextStyle(color: textPrimary),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: glassCard.withValues(alpha: 0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: glassCard.withValues(alpha: 0.95),
      elevation: 0,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
    ),
  );

  // ─────────────────────────────────────────────
  // DARK THEME (GLASS)
  // ─────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SF Pro Display',

    scaffoldBackgroundColor: Colors.transparent,

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryPurple,
      tertiary: accentTeal,
      error: error,
      onPrimary: textLight,
      onSurface: textLight,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: glassDark.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      foregroundColor: textLight,
    ),

    cardTheme: CardThemeData(
      color: glassDarkCard.withValues(alpha: 0.85),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: glassDark.withValues(alpha: 0.95),
      elevation: 0,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
    ),
  );
}
