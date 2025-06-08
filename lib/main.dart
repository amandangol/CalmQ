import 'package:auralynn/features/achievements/providers/achievements_provider.dart';
import 'package:auralynn/features/achievements/screens/achievements_screen.dart';
import 'package:auralynn/features/affirmations/screens/affirmations_screen.dart';
import 'package:auralynn/features/profile/screens/profile_screen.dart';
import 'package:auralynn/features/journal/providers/journal_provider.dart';
import 'package:auralynn/features/mood/screens/mood_screen.dart';
import 'package:auralynn/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/user_profile_provider.dart';
import 'features/mood/providers/mood_provider.dart';
import 'features/breathing/providers/breathing_provider.dart';
import 'features/affirmations/providers/affirmation_provider.dart';
import 'features/reminders/providers/reminder_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/breathing/screens/breathing_screen.dart';
import 'app_theme.dart';
import 'splash_screen.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/web3/providers/web3_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        ChangeNotifierProvider(create: (_) => BreathingProvider()),
        ChangeNotifierProvider(create: (_) => AffirmationProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => Web3Provider()),
        ChangeNotifierProxyProvider<Web3Provider, AchievementsProvider>(
          create: (context) =>
              AchievementsProvider(context.read<Web3Provider>()),
          update: (context, web3Provider, previous) =>
              AchievementsProvider(web3Provider),
        ),
      ],
      child: MaterialApp(
        title: 'Mental Wellness',
        theme: mentalWellnessTheme,
        navigatorKey: navigatorKey,
        home: const SplashScreenWrapper(),
        debugShowCheckedModeBanner: false,
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

  @override
  void initState() {
    super.initState();
    _initializeWeb3();
  }

  Future<void> _initializeWeb3() async {
    final web3Provider = Provider.of<Web3Provider>(context, listen: false);
    await web3Provider.initialize(context);
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return CalmQSplashScreen(onComplete: _onSplashComplete);
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

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _selectedIndex = -1;
  late PageController _pageController;

  final List<Widget> _screens = [
    HomeScreen(),
    MoodScreen(),
    BreathingScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.mood_outlined,
      selectedIcon: Icons.mood_rounded,
      label: 'Mood',
      color: Color(0xFF9C27B0),
    ),
    NavigationItem(
      icon: Icons.air_outlined,
      selectedIcon: Icons.air_rounded,
      label: 'Breathe',
      color: Color(0xFF00BCD4),
    ),
    NavigationItem(
      icon: Icons.redeem_outlined,
      selectedIcon: Icons.redeem_outlined,
      label: 'Achievements',
      color: Color(0xFFFF9800),
    ),
    NavigationItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
      color: Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _selectedIndex = -1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index + 1);
  }

  void _onFABPressed() {
    if (_selectedIndex == -1) return;
    setState(() {
      _selectedIndex = -1;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index == 0 ? -1 : index - 1;
          });
        },
        children: _screens.map((screen) => screen).toList(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        selectedIndex: _selectedIndex,
        items: _navigationItems,
        onItemTapped: _onItemTapped,
        onFABPressed: _onFABPressed,
        fabIcon: Icons.home_rounded,
        fabColor: const Color(0xFF6B73FF),
        backgroundColor: Colors.white,
        unselectedColor: Colors.grey.shade400,
        height: 85,
      ),
    );
  }
}
