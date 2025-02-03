
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'home_tab.dart'; // Import your tab pages
import 'mystories_tab.dart';
import 'explore_tab.dart';
import 'settings_tab.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'CustompayWall.dart';


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
  bool _subscribed = false;
  void Function(CustomerInfo)? _customerInfoListener;



  // Callback function to change the selected tab index
  void _onTabSelected(int index) {
    if(mounted)
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  void initState() {
    super.initState();
    _setupIsPro();


  }

  @override
  void dispose() {
    if (_customerInfoListener != null) {
      Purchases.removeCustomerInfoUpdateListener(_customerInfoListener!);
    }

    super.dispose();
  }




  Future<void> _setupIsPro() async {
    await Future.delayed(const Duration(seconds: 7));
    _customerInfoListener = (CustomerInfo customerInfo) {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Premium'];
      if (mounted) {
        setState(() {
          _subscribed = entitlement?.isActive ?? false;
        });
      }
    };
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);
    if(!_subscribed)
      _showPaywall();
  }


  Future<void> _showPaywall() async{
    if(mounted)
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child:  PaywallPage(),
      ),
    );
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dynamically set the background color
      body: _pages[_selectedIndex], // Display the selected tab's content
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (mounted) {
            setState(() {
              _selectedIndex = index;
            });
          }
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
        backgroundColor: Theme.of(context).colorScheme.surface, // Dynamically set the navigation bar's background color
        elevation: 3, // Optional: controls the elevation (shadow)
      ),
    );

  }
}