import 'package:auralynn/features/wellness/providers/water_tracker_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/user_profile_provider.dart';
import 'features/mood/providers/mood_provider.dart';
import 'features/breathing/providers/breathing_provider.dart';
import 'features/affirmations/providers/affirmation_provider.dart';
import 'features/reminders/providers/reminder_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/journal/providers/journal_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/web3/providers/web3_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/achievements/providers/achievement_provider.dart';
import 'app_theme.dart';
import 'splash_screen.dart';
import 'navigation/main_navigation.dart';
import 'features/focus/providers/focus_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await ConfigService.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => Web3Provider()),

        ChangeNotifierProvider(create: (_) => BreathingProvider()),
        ChangeNotifierProvider(create: (_) => AffirmationProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WaterTrackerProvider()),
        ChangeNotifierProvider(create: (_) => FocusProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Mental Wellness',
            theme: mentalWellnessTheme,
            themeMode: settingsProvider.themeMode,
            home: const SplashScreenWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({Key? key}) : super(key: key);

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      final web3Provider = Provider.of<Web3Provider>(context, listen: false);
      await web3Provider.initialize(context);

      final achievementProvider = Provider.of<AchievementProvider>(
        context,
        listen: false,
      );
      // Temporary for testing: Clear all achievement data
      achievementProvider.clearData();
      // await achievementProvider.initialize();

      final breathingProvider = Provider.of<BreathingProvider>(
        context,
        listen: false,
      );
      breathingProvider.initialize();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SerenaraSplashScreen(onComplete: _onSplashComplete);
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isAuthenticated
            ? const MainNavigation()
            : LoginScreen();
      },
    );
  }
}
