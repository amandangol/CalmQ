import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../affirmations/providers/affirmation_provider.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _soundEffectsKey = 'sound_effects_enabled';
  static const String _hapticFeedbackKey = 'haptic_feedback_enabled';
  static const String _dataSyncKey = 'data_sync_enabled';
  static const String _privacyModeKey = 'privacy_mode_enabled';

  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = false;
  bool _soundEffectsEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _dataSyncEnabled = false;
  bool _privacyModeEnabled = false;

  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get dataSyncEnabled => _dataSyncEnabled;
  bool get privacyModeEnabled => _privacyModeEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _themeMode = ThemeMode.values[prefs.getInt(_themeKey) ?? 0];
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? false;
      _soundEffectsEnabled = prefs.getBool(_soundEffectsKey) ?? true;
      _hapticFeedbackEnabled = prefs.getBool(_hapticFeedbackKey) ?? true;
      _dataSyncEnabled = prefs.getBool(_dataSyncKey) ?? false;
      _privacyModeEnabled = prefs.getBool(_privacyModeKey) ?? false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _soundEffectsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEffectsKey, enabled);
    notifyListeners();
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    _hapticFeedbackEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
    notifyListeners();
  }

  Future<void> setDataSyncEnabled(bool enabled) async {
    _dataSyncEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSyncKey, enabled);
    notifyListeners();
  }

  Future<void> setPrivacyModeEnabled(bool enabled) async {
    _privacyModeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyModeKey, enabled);
    notifyListeners();
  }

  Future<void> clearAllData(BuildContext context) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset all settings to default values
      _notificationsEnabled = false;
      _soundEffectsEnabled = true;
      _hapticFeedbackEnabled = true;
      _dataSyncEnabled = false;

      // Clear data from other providers
      if (context.mounted) {
        // Clear Mood data
        final moodProvider = Provider.of<MoodProvider>(context, listen: false);
        moodProvider.clearData();

        // Clear Journal data
        final journalProvider = Provider.of<JournalProvider>(
          context,
          listen: false,
        );
        // await journalProvider.clearData();

        // Clear Affirmation data
        final affirmationProvider = Provider.of<AffirmationProvider>(
          context,
          listen: false,
        );
        await affirmationProvider
            .refreshData(); // This will reset to default affirmations
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
      rethrow;
    }
  }
}
