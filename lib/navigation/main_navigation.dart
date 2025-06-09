import 'package:auralynn/features/achievements/screens/achievements_screen.dart';
import 'package:auralynn/features/chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/mood/screens/mood_screen.dart';
import '../features/breathing/screens/breathing_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = -1;
  DateTime? _lastBackPressTime;

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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFABPressed() {
    if (_selectedIndex == -1) return;
    setState(() {
      _selectedIndex = -1;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != -1) {
      setState(() {
        _selectedIndex = -1;
      });
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex == -1 ? 0 : _selectedIndex + 1,
          children: _screens,
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
      ),
    );
  }
}
