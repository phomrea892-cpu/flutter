// lib/state_management/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'save_screen.dart';
import 'package:flutter_application_1/state_manegement/about_screen.dart';
import 'package:flutter_application_1/state_manegement/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const SaveScreen(), 
    const AboutScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.bookmarks_outlined), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.info_outlined), label: 'About'),
          NavigationDestination(icon: Icon(Icons.account_circle_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}