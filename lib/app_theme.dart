import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors - Deep, rich blues and purples
  // Primary - Light Blue
  static const primary = Color(0xFF64B5F6); // Light Blue (Main Theme Color)

  // Primary Dark - Rich Blue
  static const primaryDark = Color(0xFF1E88E5); // Medium Blue

  // Primary Light - Pale Blue
  static const primaryLight = Color(0xFFBBDEFB); // Soft Sky Blue

  // Secondary Colors - Rich purples and lavenders
  static const secondary = Color(0xFFCE93D8); // Light Purple tone
  static const secondaryDark = Color(0xFFE1BEE7); // Very Light Purple tone
  static const secondaryLight = Color(
    0xFFF3E5F5,
  ); // Extremely Light Purple tone

  // Accent Colors - Deep, rich tones
  static const accent = Color(0xFFFFB74D); // Light Orange tone
  static const accentWarm = Color(0xFFFFCC80); // Lighter Orange tone

  // Background Colors - Dark, rich tones
  static const background = Color(0xFFF5F5F5); // Very Light Grey
  static const surface = Color(0xFFFFFFFF); // White Surface
  static const surfaceVariant = Color(
    0xFFEEEEEE,
  ); // Lighter Grey Surface Variant

  // Text Colors - High contrast for readability
  static const textPrimary = Color(
    0xFF212121,
  ); // Dark Grey (almost black) - Keep for main text
  static const textSecondary = Color(
    0xFF616161,
  ); // Slightly lighter grey for secondary text
  static const textLight = Color(
    0xFF9E9E9E,
  ); // Medium grey for less emphasized text
  static const textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White text on primary/accent colors

  // Status Colors - Rich, deep tones
  static const success = Color(0xFF81C784); // Light Green
  static const warning = Color(0xFFFFB74D); // Light Orange
  static const error = Color(0xFFE57373); // Light Red/Pink
  static const info = Color(0xFF64B5F6); // Light Blue

  // Mood Colors - For mood tracking features
  static const moodHappy = Color(0xFFFFCC80); // Lighter Orange
  static const moodCalm = Color(0xFF81C784); // Light Green
  static const moodSad = Color(0xFF64B5F6); // Light Blue
  static const moodAnxious = Color(0xFFFFB74D); // Light Orange
  static const moodAngry = Color(0xFFE57373); // Light Red/Pink

  // Gradient Colors - For visual appeal
  static const gradientStart = Color(0xFFE57373); // Pink
  static const gradientEnd = Color(0xFFCE93D8); // Purple
  static const gradientLight = [
    Color(0xFFEEEEEE),
    Color(0xFFF5F5F5),
  ]; // Light Grey Gradient
  static const gradientWellness = [
    Color(0xFF81C784),
    Color(0xFF64B5F6),
  ]; // Green and Blue Gradient
}

final ThemeData mentalWellnessTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light, // Keep light brightness
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textOnPrimary,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceVariant: AppColors.surfaceVariant,
    onSurfaceVariant:
        AppColors.textSecondary, // Use textSecondary for text on surfaceVariant
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    outline: AppColors.textLight, // Use textLight for outlines
    shadow: Colors.black12, // Lighter shadow
  ),

  scaffoldBackgroundColor: AppColors.background,

  // Typography - Calming and readable fonts
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w300,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.2,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.3,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.3,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.3,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.27,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.33,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, // Use textSecondary
      height: 1.43,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textLight, // Use textLight
      height: 1.33,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, // Use textPrimary
      height: 1.43,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary, // Use textSecondary
      height: 1.33,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight, // Use textLight
      height: 1.45,
    ),
  ),

  // App Bar - Clean and calming
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background, // Match background
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary, // Use textPrimary
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ), // Use textPrimary
    actionsIconTheme: const IconThemeData(
      color: AppColors.textSecondary, // Use textSecondary
      size: 22,
    ),
  ),

  // Buttons - Soft and inviting
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary, // Use textOnPrimary
      elevation: 0,
      shadowColor: Colors.transparent,
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
      foregroundColor: AppColors.textOnPrimary, // Use textOnPrimary
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary, // Use primary
      side: BorderSide(
        color: AppColors.primary.withOpacity(0.5),
        width: 1.5,
      ), // Use primary with opacity
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary, // Use primary
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),

  // Input Fields - Gentle and approachable
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ), // Use primary
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 1.5,
      ), // Use error
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 2,
      ), // Use error
    ),
    labelStyle: GoogleFonts.inter(
      color: AppColors.textSecondary, // Use textSecondary
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    floatingLabelStyle: GoogleFonts.inter(
      color: AppColors.primary, // Use primary
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: GoogleFonts.inter(
      color: AppColors.textLight, // Use textLight
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    errorStyle: GoogleFonts.inter(
      color: AppColors.error, // Use error
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  ),

  // Cards - Soft and welcoming
  cardTheme: CardThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.08),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
  ),

  // Chips - Gentle selection elements
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryLight, // Use primaryLight
    deleteIconColor: AppColors.textSecondary, // Use textSecondary
    labelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary, // Use textPrimary
    ),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textOnPrimary, // Use textOnPrimary
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide.none,
  ),

  // Bottom Navigation - Clean and accessible
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary, // Use primary
    unselectedItemColor: AppColors.textLight, // Use textLight
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  ),

  // Floating Action Button - Inviting and prominent
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary, // Use primary
    foregroundColor: AppColors.textOnPrimary, // Use textOnPrimary
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  ),

  // Snackbar - Gentle notifications
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimary, // Use textPrimary
    contentTextStyle: GoogleFonts.inter(
      color: AppColors.textOnPrimary, // Use textOnPrimary
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    actionTextColor: AppColors.primaryLight, // Use primaryLight
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
      color: AppColors.textPrimary, // Use textPrimary
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, // Use textSecondary
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
      color: AppColors.textPrimary, // Use textPrimary
    ),
    subtitleTextStyle: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary, // Use textSecondary
    ),
    iconColor: AppColors.textSecondary, // Use textSecondary
  ),

  // Switch - Soft interactions
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary; // Use primary
      }
      return AppColors.textLight; // Use textLight
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryLight; // Use primaryLight
      }
      return AppColors.surfaceVariant; // Use surfaceVariant
    }),
  ),

  // Slider - Smooth progress indicators
  sliderTheme: SliderThemeData(
    activeTrackColor: AppColors.primary, // Use primary
    inactiveTrackColor: AppColors.primaryLight, // Use primaryLight
    thumbColor: AppColors.primary, // Use primary
    overlayColor: AppColors.primary.withOpacity(
      0.1,
    ), // Use primary with opacity
    valueIndicatorColor: AppColors.primary, // Use primary
    valueIndicatorTextStyle: GoogleFonts.inter(
      color: AppColors.textOnPrimary, // Use textOnPrimary
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),

  // Progress Indicators - Calming progress
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary, // Use primary
    linearTrackColor: AppColors.primaryLight, // Use primaryLight
    circularTrackColor: AppColors.primaryLight, // Use primaryLight
  ),

  // Divider - Subtle separation
  dividerTheme: DividerThemeData(
    color: AppColors.textLight.withOpacity(0.2), // Use textLight with opacity
    thickness: 1,
    space: 1,
  ),
);

// Extension for easy gradient access
extension WellnessGradients on ThemeData {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientEnd,
    ], // Use gradientStart and gradientEnd
  );

  static const LinearGradient wellnessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientWellness, // Use gradientWellness
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.gradientLight, // Use gradientLight
  );
}

// Helper class for mood-specific colors
class MoodColors {
  static const Map<String, Color> moodColorMap = {
    'very happy': AppColors.moodHappy,
    'happy': AppColors.moodHappy,
    'neutral': Colors.grey,
    'sad': AppColors.moodSad,
    'angry': AppColors.moodAngry,
    'excited': AppColors.moodHappy,
    'joyful': AppColors.moodHappy,
    'calm': AppColors.moodCalm,
    'peaceful': AppColors.moodCalm,
    'relaxed': AppColors.moodCalm,
    'melancholy': AppColors.moodSad,
    'down': AppColors.moodSad,
    'anxious': AppColors.moodAnxious,
    'worried': AppColors.moodAnxious,
    'stressed': AppColors.moodAnxious,
    'frustrated': AppColors.moodAngry,
    'irritated': AppColors.moodAngry,
  };

  static Color getMoodColor(String mood) {
    return moodColorMap[mood.toLowerCase()] ??
        Colors.grey; // Default to grey for unknown moods
  }
}
