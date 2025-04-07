import 'package:flutter/material.dart';
import 'HomeTab.dart';
import 'CreatePage.dart';
import 'MePage.dart';







// --- Main HomePage Widget ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Start with the first tab selected (Listen)

  // List of pages corresponding to the bottom navigation tabs
  static const List<Widget> _widgetOptions = <Widget>[
    HomePageContent(),
    CreatePage(),
    MePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- Action Handlers (Implement Navigation/Actions here) ---
  void _onProTap() {
    // Navigate to Subscription Page or show Subscription Dialog
    print("Pro Tag Tapped!");
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Subscription Page')),
    );
  }

  void _onSearchTap() {
    // Navigate to Search Page or show Search Delegate
    print("Search Tapped!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open Search')),
    );
  }

  void _onVoiceTap() {
    // Navigate to Voice Cloning Setup/Status Page
    print("Voice Tapped!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Voice Settings/Cloning')),
    );
    // Navigator.push(context, MaterialPageRoute(builder: (context) => VoiceCloningPage()));
  }

  void _onSettingsTap() {
    // Navigate to Settings Page
    print("Settings Tapped!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Settings Page')),
    );
    // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));

  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary; // Or your specific brand color
    final Color unselectedColor = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        // Modern minimalist style often uses little to no elevation
        elevation: 0.5, // Subtle shadow
        backgroundColor: const Color(0xF4E9E3), // Use surface color for clean look
        foregroundColor: Theme.of(context).colorScheme.onSurface, // Text/icon color on surface
        title: Image.asset(Theme.of(context).brightness == Brightness.dark
            ? 'assets/logo2.png' // Use dark mode logo
            : 'assets/logo1.png',

            height: 30, fit: BoxFit.contain),
        actions: <Widget>[
          // Pro Tag/Button

          // Search Icon Button
          IconButton(
            icon: const Icon(Icons.search,size: 32,),

            tooltip: 'Search Stories',
            onPressed: _onSearchTap,
          ),
          // Voice Icon Button (Representing Voice Cloning / Narration Options)
          IconButton(
            icon: const Icon(Icons.graphic_eq_outlined, size: 32,), // Icon suggesting audio/voice processing
            // Alternative: Icons.mic_none or Icons.record_voice_over
            tooltip: 'Voice Settings / Cloning',
            onPressed: _onVoiceTap,
          ),
          // Settings Icon Button
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 32,),
            tooltip: 'Settings',
            onPressed: _onSettingsTap,
          ),
        ],
      ),
      body: IndexedStack( // Use IndexedStack to keep page state when switching tabs
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),     // Changed Icon
            activeIcon: Icon(Icons.home),       // Changed Active Icon
            label: 'Home',                      // Changed Label
          ),
          BottomNavigationBarItem(
            // Use the *same* styled widget for both icon and activeIcon
            icon: Icon(
              Icons.add_circle, // Use the filled icon for prominence?
              color: Color(0xFFE6465D), // Apply the fixed color
              size: 40.0, // Slightly larger size (optional)
            ),
            activeIcon: Icon(
              Icons.add_circle, // Use the filled icon
              color: Color(0xFFE6465D), // Apply the fixed color
              size: 40.0, // Slightly larger size (optional)
            ),
            label: 'Create', // Set label to empty string to hide it
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'Me', // Or 'Library' / 'Profile'
          ),
        ],
        currentIndex: _selectedIndex,
        // Modern look often uses the primary color for selected items
        selectedItemColor: const Color(0xFFE6465D),
        unselectedItemColor: unselectedColor,
        onTap: _onItemTapped,
        // Use fixed type for 3 items for better spacing and always visible labels
        type: BottomNavigationBarType.fixed,
        // Minimalist style often avoids showing labels for unselected items,
        // but explicit labels are usually better for usability.
        // showUnselectedLabels: false, // Uncomment for ultra-minimalist look
        backgroundColor: const Color(0xFFF4E9E3),// Match AppBar background
        elevation: 1.0, // Subtle elevation for separation
      ),
    );
  }
}