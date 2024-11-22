import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_tab.dart'; // Import your tab pages
import 'mystories_tab.dart';
import 'explore_tab.dart';
import 'settings_tab.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

void main() {
  runApp(const CraftAStoryApphome());
}





class CraftAStoryApphome extends StatelessWidget {
  const CraftAStoryApphome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Craft-a-Story',
      theme: ThemeData(
        useMaterial3: true, // Enable Material Design 3
        colorSchemeSeed: const Color(0xFF161825), // Define a custom color scheme
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index of the currently selected tab

  // Callback function to change the selected tab index
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      CraftAStoryHome(onTabSelected: _onTabSelected),
      const MyStoriesPage(),
      const ExploreTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      // Set your primary color
      backgroundColor: Colors.white, // Set the background color
      body: _pages[_selectedIndex], // Display the selected tab's content

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'My Stories',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        backgroundColor: Colors.white, // Material 3 background color
        elevation: 3, // Optional: controls the elevation (shadow)
      ),
    );
  }
}
