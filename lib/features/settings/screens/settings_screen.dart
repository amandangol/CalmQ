import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../../../app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    if (settingsProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection(context, 'Appearance', [
            _buildThemeSelector(context, settingsProvider),
          ]),
          _buildSection(context, 'Notifications & Sound', [
            _buildSwitchTile(
              context,
              'Enable Notifications',
              'Receive reminders and updates',
              settingsProvider.notificationsEnabled,
              (value) => settingsProvider.setNotificationsEnabled(value),
              Icons.notifications_outlined,
            ),
            _buildSwitchTile(
              context,
              'Sound Effects',
              'Play sounds for interactions',
              settingsProvider.soundEffectsEnabled,
              (value) => settingsProvider.setSoundEffectsEnabled(value),
              Icons.volume_up_outlined,
            ),
            _buildSwitchTile(
              context,
              'Haptic Feedback',
              'Vibrate on interactions',
              settingsProvider.hapticFeedbackEnabled,
              (value) => settingsProvider.setHapticFeedbackEnabled(value),
              Icons.vibration_outlined,
            ),
          ]),
          _buildSection(context, 'Privacy & Data', [
            _buildSwitchTile(
              context,
              'Data Sync',
              'Sync your data across devices',
              settingsProvider.dataSyncEnabled,
              (value) => settingsProvider.setDataSyncEnabled(value),
              Icons.sync_outlined,
            ),
            _buildSwitchTile(
              context,
              'Privacy Mode',
              'Hide sensitive content',
              settingsProvider.privacyModeEnabled,
              (value) => settingsProvider.setPrivacyModeEnabled(value),
              Icons.visibility_off_outlined,
            ),
          ]),
          _buildSection(context, 'About', [
            _buildListTile(
              context,
              'Terms & Conditions',
              Icons.description_outlined,
              () => _showTermsAndConditions(context),
            ),
            _buildListTile(
              context,
              'Privacy Policy',
              Icons.privacy_tip_outlined,
              () => _showPrivacyPolicy(context),
            ),
            _buildListTile(context, 'App Version', Icons.info_outline, () {
              showAboutDialog(
                context: context,
                applicationName: 'CalmQ',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  "assets/icon/icon.png",
                  height: 60,
                  width: 60,
                ),
                applicationLegalese: '© 2025 CalmQ',
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider provider) {
    return ListTile(
      leading: Icon(Icons.palette_outlined, color: AppColors.primary),
      title: const Text('Theme'),
      subtitle: Text(
        provider.themeMode == ThemeMode.system
            ? 'System Default'
            : provider.themeMode == ThemeMode.light
            ? 'Light'
            : 'Dark',
      ),
      onTap: () => _showThemeSelector(context, provider),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon, [
    VoidCallback? onTap,
    Widget? trailing,
  ]) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showThemeSelector(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('System Default'),
            leading: const Icon(Icons.brightness_auto),
            onTap: () {
              provider.setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Light'),
            leading: const Icon(Icons.brightness_high),
            onTap: () {
              provider.setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Dark'),
            leading: const Icon(Icons.brightness_4),
            onTap: () {
              provider.setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By using this app, you agree to:\n\n'
            '1. Use the app responsibly and ethically\n'
            '2. Keep your account information secure\n'
            '3. Not share your account with others\n'
            '4. Respect the privacy of other users\n'
            '5. Use the app in accordance with applicable laws\n\n'
            'We are committed to protecting your privacy and providing a safe environment for mental wellness.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app:\n\n'
            '1. Collects only necessary personal information\n'
            '2. Uses data to improve your experience\n'
            '3. Never shares your data with third parties\n'
            '4. Allows you to control your data\n'
            '5. Implements security measures to protect your information\n\n'
            'For more details, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
