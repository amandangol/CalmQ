import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Soft, calming blues and teals
  static const primary = Color(0xFF6B9EDB); // Serene blue
  static const primaryDark = Color(0xFF4A7FB8); // Deeper blue
  static const primaryLight = Color(0xFF9BC4E8); // Light blue

  // Secondary Colors - Warm, comforting purples and lavenders
  static const secondary = Color(0xFF9B7EDB); // Lavender purple
  static const secondaryDark = Color(0xFF7A5CB8); // Deeper purple
  static const secondaryLight = Color(0xFFC4A8E8); // Light lavender

  // Accent Colors - Gentle, healing tones
  static const accent = Color(0xFF7DBDA3); // Sage green
  static const accentWarm = Color(0xFFE8B4A0); // Warm peach

  // Background Colors - Ultra-soft, breathable tones
  static const background = Color(0xFFF8FAFE); // Very light blue-white
  static const surface = Color(0xFFFFFFFF); // Pure white
  static const surfaceVariant = Color(0xFFF5F7FA); // Light grey-blue

  // Text Colors - Soft but readable
  static const textPrimary = Color(0xFF2C3E50); // Deep blue-grey
  static const textSecondary = Color(0xFF5D6D7E); // Medium grey-blue
  static const textLight = Color(0xFF85929E); // Light grey
  static const textOnPrimary = Color(0xFFFFFFFF); // White text

  // Status Colors - Gentle, non-alarming tones
  static const success = Color(0xFF7DBDA3); // Soft green
  static const warning = Color(0xFFE8B4A0); // Soft orange
  static const error = Color(0xFFE8A0A0); // Soft red
  static const info = Color(0xFF9BC4E8); // Soft blue

  // Mood Colors - For mood tracking features
  static const moodHappy = Color(0xFFFFE066); // Warm yellow
  static const moodCalm = Color(0xFF7DBDA3); // Sage green
  static const moodSad = Color(0xFF9BC4E8); // Soft blue
  static const moodAnxious = Color(0xFFE8B4A0); // Soft orange
  static const moodAngry = Color(0xFFE8A0A0); // Soft red

  // Gradient Colors - For visual appeal
  static const gradientStart = Color(0xFF6B9EDB);
  static const gradientEnd = Color(0xFF9B7EDB);
  static const gradientLight = [Color(0xFFF8FAFE), Color(0xFFFFFFFF)];
  static const gradientWellness = [Color(0xFF7DBDA3), Color(0xFF6B9EDB)];
}

final ThemeData mentalWellnessTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textOnPrimary,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    outline: AppColors.textLight,
    shadow: Colors.black12,
  ),

  scaffoldBackgroundColor: AppColors.background,

  // Typography - Calming and readable fonts
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w300, // Lighter weight for calmness
      color: AppColors.textPrimary,
      height: 1.2,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.27,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.33,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.43,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight,
      height: 1.33,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.43,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      height: 1.33,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
      height: 1.45,
    ),
  ),

  // App Bar - Clean and calming
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: false,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    actionsIconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 22,
    ),
  ),

  // Buttons - Soft and inviting
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),

  // Input Fields - Gentle and approachable
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.textLight.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: GoogleFonts.inter(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      color: AppColors.primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: GoogleFonts.inter(
      color: AppColors.textLight,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    errorStyle: GoogleFonts.inter(
      color: AppColors.error,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  ),

  // Cards - Soft and welcoming
  cardTheme: CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.05),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
  ),

  // Chips - Gentle selection elements
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryLight,
    deleteIconColor: AppColors.textSecondary,
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textOnPrimary,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide.none,
  ),

  // Bottom Navigation - Clean and accessible
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textLight,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  ),

  // Floating Action Button - Inviting and prominent
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textOnPrimary,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  // Snackbar - Gentle notifications
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: GoogleFonts.inter(
      color: AppColors.textOnPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    actionTextColor: AppColors.primaryLight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
    elevation: 3,
  ),

  // Dialog - Calm and focused
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
  ),

  // Bottom Sheet - Smooth transitions
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  // List Tiles - Clean and readable
  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    subtitleTextStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    iconColor: AppColors.textSecondary,
  ),

  // Switch - Soft interactions
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.textLight;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryLight;
      }
      return AppColors.surfaceVariant;
    }),
  ),

  // Slider - Smooth progress indicators
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.primaryLight,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withOpacity(0.1),
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle: GoogleFonts.inter(
      color: AppColors.textOnPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Progress Indicators - Calming progress
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.primaryLight,
    circularTrackColor: AppColors.primaryLight,
  ),

  // Divider - Subtle separation
  dividerTheme: DividerThemeData(
    color: AppColors.textLight.withOpacity(0.2),
    thickness: 1,
    space: 1,
  ),
);

// Extension for easy gradient access
extension WellnessGradients on ThemeData {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static const LinearGradient wellnessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientWellness,
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.gradientLight,
  );
}

// Helper class for mood-specific colors
class MoodColors {
  static const Map<String, Color> moodColorMap = {
    'happy': AppColors.moodHappy,
    'excited': AppColors.moodHappy,
    'joyful': AppColors.moodHappy,
    'calm': AppColors.moodCalm,
    'peaceful': AppColors.moodCalm,
    'relaxed': AppColors.moodCalm,
    'sad': AppColors.moodSad,
    'melancholy': AppColors.moodSad,
    'down': AppColors.moodSad,
    'anxious': AppColors.moodAnxious,
    'worried': AppColors.moodAnxious,
    'stressed': AppColors.moodAnxious,
    'angry': AppColors.moodAngry,
    'frustrated': AppColors.moodAngry,
    'irritated': AppColors.moodAngry,
  };

  static Color getMoodColor(String mood) {
    return moodColorMap[mood.toLowerCase()] ?? AppColors.primary;
  }
}
