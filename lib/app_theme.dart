import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFA3D5D3);
  static const primaryDark = Color(0xFF7AB3B1);
  static const secondary = Color(0xFFFFBCBC);
  static const secondaryDark = Color(0xFFFF9A9E);
  static const background = Color(0xFFF7FDFD);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF2E3D49);
  static const textLight = Color(0xFF6D7587);
  static const error = Color(0xFFFF9A9E);
  static const success = Color(0xFF9EB567);
}

final ThemeData mentalWellnessTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.text,
    secondary: AppColors.secondary,
    onSecondary: AppColors.text,
    background: AppColors.background,
    onBackground: AppColors.text,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.error,
    onError: AppColors.surface,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: AppColors.text,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: AppColors.text,
    ),
    bodyLarge: GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.text,
    ),
    bodyMedium: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight,
    ),
    labelLarge: GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
    ),
    iconTheme: const IconThemeData(color: AppColors.text),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.text,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: GoogleFonts.nunito(color: AppColors.textLight, fontSize: 14),
    hintStyle: GoogleFonts.nunito(
      color: AppColors.textLight.withOpacity(0.7),
      fontSize: 14,
    ),
    errorStyle: GoogleFonts.nunito(color: AppColors.error, fontSize: 12),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.primary.withOpacity(0.1),
    selectedColor: AppColors.primary,
    labelStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textLight,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.text,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.text,
    contentTextStyle: GoogleFonts.nunito(color: AppColors.surface),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
  ),
);
