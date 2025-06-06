import 'package:auralynn/features/affirmations/screens/affirmations_screen.dart';
import 'package:auralynn/features/journal/providers/journal_provider.dart';
import 'package:auralynn/features/mood/screens/mood_screen.dart';
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
import 'features/profile/screens/profile_screen.dart';
import 'features/breathing/screens/breathing_screen.dart';
import 'app_theme.dart';
import 'splash_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Mental Wellness',
        theme: mentalWellnessTheme,
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

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return AuralynnSplashScreen(onComplete: _onSplashComplete);
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
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;

  final List<Widget> _screens = [
    HomeScreen(),
    MoodScreen(),
    BreathingScreen(),
    AffirmationsScreen(),
    ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      color: Color(0xFF6B73FF),
    ),
    NavigationItem(
      icon: Icons.mood_outlined,
      activeIcon: Icons.mood,
      label: 'Mood',
      color: Color(0xFF9C27B0),
    ),
    NavigationItem(
      icon: Icons.air_outlined,
      activeIcon: Icons.air,
      label: 'Breathe',
      color: Color(0xFF00BCD4),
    ),
    NavigationItem(
      icon: Icons.format_quote_outlined,
      activeIcon: Icons.format_quote,
      label: 'Affirmations',
      color: Color(0xFFFF9800),
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      color: Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Animate FAB for breathing screen
    if (index == 2) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Animate FAB for breathing screen
          if (index == 2) {
            _fabAnimationController.forward();
          } else {
            _fabAnimationController.reverse();
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navigationItems.length,
                (index) => _buildNavigationItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? item.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: isSelected ? item.color : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? item.color : Colors.grey.shade600,
              ),
              child: Text(item.label),
            ),
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
