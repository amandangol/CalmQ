import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../../../app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

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
          _buildSection(context, 'Notifications & Sound', [
            _buildSwitchTile(
              context,
              'Enable Notifications',
              'Receive daily wellness reminders',
              settingsProvider.notificationsEnabled,
              (value) async {
                await settingsProvider.setNotificationsEnabled(value);
                if (value && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Please set up your reminders in the Reminders section',
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Go to Reminders',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(context, '/reminders');
                        },
                      ),
                    ),
                  );
                }
              },
              Icons.notifications_outlined,
            ),
            _buildSwitchTile(
              context,
              'Notification Sound',
              'Play sound for reminders',
              settingsProvider.soundEffectsEnabled,
              (value) => settingsProvider.setSoundEffectsEnabled(value),
              Icons.volume_up_outlined,
            ),
            _buildSwitchTile(
              context,
              'Vibration',
              'Vibrate for reminders',
              settingsProvider.hapticFeedbackEnabled,
              (value) => settingsProvider.setHapticFeedbackEnabled(value),
              Icons.vibration_outlined,
            ),
          ]),
          _buildSection(context, 'Data & Privacy', [
            _buildSwitchTile(
              context,
              'Data Backup',
              'Backup your wellness data',
              settingsProvider.dataSyncEnabled,
              (value) => settingsProvider.setDataSyncEnabled(value),
              Icons.backup_outlined,
            ),
            _buildListTile(
              context,
              'Clear App Data',
              Icons.delete_outline,
              () => _showClearDataDialog(context, settingsProvider),
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
                applicationName: 'Auralynn',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  "assets/icon/icon.png",
                  height: 60,
                  width: 60,
                ),
                applicationLegalese: '© 2024 Auralynn',
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

  void _showClearDataDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'This will permanently delete all your wellness data, including reminders, journal entries, mood logs, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearAllData(context);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Clear Data',
              style: TextStyle(color: Colors.red),
            ),
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
