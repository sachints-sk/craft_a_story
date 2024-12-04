

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_tab.dart'; // Import your tab pages
import 'mystories_tab.dart';
import 'explore_tab.dart';
import 'settings_tab.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

void main() {
  runApp(const CraftAStoryApphome());
}

class CraftAStoryApphome extends StatefulWidget {
  const CraftAStoryApphome({Key? key}) : super(key: key);

  @override
  State<CraftAStoryApphome> createState() => _CraftAStoryApphomeState();
}

class _CraftAStoryApphomeState extends State<CraftAStoryApphome> {
  int _selectedIndex = 0; // Index of the currently selected tab

  // Callback function to change the selected tab index
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool _paywallShown = false;
  bool _subscribed = false;// Flag to track if paywall is shown

  @override
  void initState() {
    super.initState();



    _configureSDK();
  }



  Future<void> _configureSDK() async {
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration? configuration;

    if(Platform.isAndroid){
      configuration=PurchasesConfiguration("goog_ROHmfEQIqmPakpNaNfXYdMByLKh");
    }


    if(configuration != null){
      await Purchases.configure(configuration);
      await Future.delayed(const Duration(seconds: 5));
      final paywallResult =await RevenueCatUI.presentPaywallIfNeeded("Premium",displayCloseButton: true);
      print('Paywall Result: $paywallResult');
    }

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

