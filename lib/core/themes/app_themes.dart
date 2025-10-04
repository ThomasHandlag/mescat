import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static const Color primaryColor = Color(0xFF5865F2); // Discord's blurple
  static const Color secondaryColor = Color(0xFF57F287); // Discord's green
  static const Color errorColor = Color(0xFFED4245); // Discord's red
  static const Color warningColor = Color(0xFFFEE75C); // Discord's yellow

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF36393F);
  static const Color darkSurface = Color(0xFF2F3136);
  static const Color darkCard = Color(0xFF40444B);
  static const Color darkOnBackground = Color(0xFFDCDDDE);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF2F3F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF2E3338);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: lightSurface,
        onSurface: lightOnBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnBackground,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: lightCard, elevation: 2),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkSurface,
        onSurface: darkOnBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnBackground,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: darkCard, elevation: 2),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
