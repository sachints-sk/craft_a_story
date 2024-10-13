import 'package:flutter/material.dart';
import 'home_tab.dart'; // Import your tab pages
import 'mystories_tab.dart';
import 'explore_tab.dart';
import 'profile_tab.dart';

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
        useMaterial3: true, // Use Material Design 3
        primarySwatch: Colors.blue,
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
      const ProfileTab(),
    ];


    return Scaffold(

      body: _pages[_selectedIndex], // Display the selected tab's content
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF161825),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}