import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buycredits.dart';
import 'package:page_transition/page_transition.dart';
import 'Subscription.dart';
import 'languagePage.dart';
import 'storageSettingsPage.dart';
import 'helpCenterPage.dart';
import 'PrivacyPolicyPage.dart';
import 'TermsofUsePage.dart';
import 'Paywall.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'dart:io';
import 'CustompayWall.dart';
import 'onboarding_page.dart';
import 'package:redacted/redacted.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';


class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false; // Track dark mode state
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _subscribed = false;
  void Function(CustomerInfo)? _customerInfoListener;
  String _userName = 'User';
  String? _profilePicUrl;
  bool _isLoading = true;





  @override
  void initState(){
    super.initState();
    _fetchUserProfile();
    _setupIsPro();
  }
  @override
  void dispose() {
    if (_customerInfoListener != null) {
      Purchases.removeCustomerInfoUpdateListener(_customerInfoListener!);
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
centerTitle: true,
        title: const Text(
          "Settings",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black ,fontWeight: FontWeight.bold),
        ),

      ),
      body: Container(

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfile(),
              if(!_subscribed)
                const SizedBox(height: 20),
              if(!_subscribed)
                _buildUpgradeToProCard(),

              const SizedBox(height: 20),
              _buildSettingsSection('General', [
                _buildSettingItem(Icons.shopping_cart, 'Buy Credits'),
                _buildSettingItem(Icons.subscriptions, 'Subscriptions'),
                _buildSettingItem(Icons.storage, 'Storage'),
                _buildSettingItem(Icons.logout, 'Logout'),

              ]),
              const SizedBox(height: 20),
              _buildSettingsSection('About', [
                _buildSettingItem(Icons.share, 'Share us on Social Media'),
                _buildSettingItem(Icons.reviews, 'Review Us'),
                _buildSettingItem(Icons.article, 'Help Center'),
                _buildSettingItem(Icons.lock, 'Privacy Policy'),
                _buildSettingItem(Icons.description, 'Terms of Use'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setupIsPro() async {

    _customerInfoListener = (CustomerInfo customerInfo) {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Premium'];
      if (mounted) {
        setState(() {
          _subscribed = entitlement?.isActive ?? false;
        });
      }
    };
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);

  }

  Future<void> _fetchUserProfile() async {
    try{
      setState(() {
        _isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();
      if(userDoc.exists){
        final userData = userDoc.data() as Map<String,dynamic>;
        setState(() {
          _userName = userData['name'] as String? ?? 'User';
          _profilePicUrl = userData['profilePicUrl'] as String?;
        });
      }


    }
    catch (e){
      print('Error fetching profile data: $e');
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildUserProfile() {
    return  Row(
      children: [
        CircleAvatar(
          backgroundImage:  _profilePicUrl != null
              ? NetworkImage(_profilePicUrl!) as ImageProvider
              : const AssetImage('assets/Profile_placeholder.png'),
          radius: 30,
        ).redacted(
          context: context,
          redact: _isLoading,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                _userName,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                )
            ).redacted(
                context: context,
                redact: _isLoading
            ),
            const SizedBox(height: 4),
            Text(
                FirebaseAuth.instance.currentUser?.email ?? ' ',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      fontSize: 14, color: Colors.grey),
                )
            ).redacted(
              context: context,
              redact: _isLoading,
            ),
          ],
        ),
      ],
    );

  }

  void showpaywall () async{
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child:  PaywallPage(),
      ),
    );
  }
  Widget _buildUpgradeToProCard() {
    return GestureDetector(onTap: showpaywall , child:Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF8A44F2),// Purple background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Wrap the Lottie animation in a SizedBox or Container
              SizedBox(
                width:90,
                height: 90,
                child: Lottie.asset(
                  'assets/getpro.json',  // AI animation
                ),
              ),
              const SizedBox(width: 10), // Add spacing between the animation and text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Upgrade to PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enjoy all features & benefits',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    ) ,) ;
  }


  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        if (label == 'Logout') {
          _logout(); // Call logout function on tap
        }
        if (label == 'Storage') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  StorageSettingsPage(),
            ),
          );
        }
        if (label == 'Help Center') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  HelpCenterPage(),
            ),
          );
        }
        if (label == 'Terms of Use') {
         // throw Exception();// Call logout function on tap
        }
        if (label == 'Buy Credits') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  PurchaseCreditsPage(),
            ),
          ); // Call logout function on tap
        }
        if (label == 'Subscriptions') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  PaywallScreen(),
            ),
          ); // Call logout function on tap
        }
        if (label == 'Privacy Policy') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  PrivacyPolicyPage(),
            ),
          ); // Call logout function on tap
        }
        if (label == 'Terms of Use') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  TermsOfUsePage(),
            ),
          );
        }
        else {

          // Handle other setting item taps
        }
      },
    );
  }

  void _logout() async {
    try {
      await Purchases.logOut();
      await _auth.signOut();

// Sign out the user
      // Optionally, navigate to the login screen or show a success message

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>  Onboarding()),
            (Route<dynamic> route) => false,
      );// Go back after logging out
    } catch (e) {
      print('Logout failed: $e'); // Handle logout error
      // Optionally, show an error message
    }
  }

  Widget _buildSettingItemWithSwitch(IconData icon, String label, bool value) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(label),
      value: value,
      onChanged: (newValue) {
        setState(() {
          _isDarkMode = newValue; // Update dark mode state
        });
        // Handle switch change
      },
    );
  }
}
