import 'package:flutter/material.dart';
import 'home_tab.dart'; // Import your tab pages
import 'create_tab.dart';
import 'explore_tab.dart';
import 'profile_tab.dart';



void main() {
  runApp(const CraftAStoryAppHome());
}

class CraftAStoryAppHome extends StatelessWidget {
  const CraftAStoryAppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Craft-a-Story',

      theme: ThemeData(

        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121224),

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

  // List of pages to display for each tab
  final List<Widget> _pages = [
    const HomeTab(),
    const CreateTab(),
    const ExploreTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Replace with your app icon path
              height: 30, // Adjust icon size as needed
              width: 30,
            ),
            const SizedBox(width: 10), // Add some spacing
            const Text(
              'Craft a Story',
              style: TextStyle(
                fontFamily: 'KaushanScript',
                fontSize: 24,color: const Color(0xFFD8D8F2)
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF121224),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      // Use the custom BottomNavigationBar
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  // Function to build the custom BottomNavigationBar
  Widget _buildCustomBottomNavigationBar() {
    return Container(
      color: const Color(0xFF121224), // Your desired background color
      height: 56.0, // Standard BottomNavigationBar height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Evenly space the items
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.create, 'Create', 1),
          _buildNavItem(Icons.explore, 'Explore', 2),
          _buildNavItem(Icons.person, 'Profile', 3),
        ],
      ),
    );
  }

  // Function to build a single navigation item
  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? const Color(0xFFCAD0D4) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? const Color(0xFFCAD0D4) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}