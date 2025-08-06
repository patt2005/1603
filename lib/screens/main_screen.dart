import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tracking_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();

  // Static reference to access main screen functionality
  static MainScreenState? _instance;
  static MainScreenState? get instance => _instance;
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<StatsScreenState> _statsScreenKey = GlobalKey<StatsScreenState>();

  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // Method to trigger back navigation on StatsScreen from main screen
  void triggerStatsBackNavigation() {
    if (_selectedIndex == 2) { // If currently on Stats tab
      _statsScreenKey.currentState?.triggerBackNavigation();
    }
  }

  List<Widget> get _screens => [
    const HomeScreen(),
    const TrackingScreen(),
    StatsScreen(
      key: _statsScreenKey,
      onBackToHome: _navigateToHome,
    ),
    SettingsScreen(onBackToHome: _navigateToHome),
  ];

  @override
  void initState() {
    super.initState();
    MainScreen._instance = this;
  }

  @override
  void dispose() {
    MainScreen._instance = null;
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFB71C1C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: _selectedIndex == 0 ? 28 : 24,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.track_changes,
                size: _selectedIndex == 1 ? 28 : 24,
              ),
              label: 'Tracking',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.pie_chart,
                size: _selectedIndex == 2 ? 28 : 24,
              ),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                size: _selectedIndex == 3 ? 28 : 24,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}