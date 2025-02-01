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
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premiumMember.dart';
import 'package:provider/provider.dart';
import 'Services/theme_provider.dart';

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
  void initState() {
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
        title:  Text(
          "Settings",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white // Dark mode text color
              : Colors.black, // Light mode text color
              fontWeight: FontWeight.bold),
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
                const SizedBox(height: 10),
              if(!_subscribed)
                _buildUpgradeToProCard(),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, ),
              const SizedBox(height: 10),
              _buildSettingsSection('General Settings', [
                _buildSettingItemWithSwitch(
                  context, // Pass the context here
                  Icons.dark_mode,
                  "Dark Mode",
                ),
                _buildSettingItem(Icons.shopping_cart, 'Buy Credits'),
                _buildSettingItem(Icons.subscriptions, 'Subscriptions'),
                _buildSettingItem(Icons.storage, 'Storage'),

                _signoutButton(),

              ]),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, ),
              const SizedBox(height: 10),
              _buildSettingsSection('Support & Legal', [
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

  // Function to handle the sharing action
  void _shareApp(BuildContext context) async {
    const String appName = 'Craft-a-Story'; // Replace with your app name
    const String appLink = 'https://play.google.com/store/apps/details?id=com.craftastory.craft_a_story'; // Replace with your app's link
    const String shareMessage =
        'Check out $appName!, Create personalized AI-powered stories for kids. Download it now: $appLink';

    try {
      await Share.share(shareMessage,
          subject: 'Share $appName'); // Optional subject for email sharing
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sharing, please try again!')));
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(
          user.uid);
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _userName = userData['name'] as String? ?? 'User';
            _profilePicUrl = userData['profilePicUrl'] as String?;
          });
        }
      }
    }
    catch (e) {
      print('Error fetching profile data: $e');
    }
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: _profilePicUrl != null
              ? NetworkImage(_profilePicUrl!) as ImageProvider
              : const AssetImage('assets/Profile_placeholder.png'),
          radius: 40,
        ).redacted(
          context: context,
          redact: _isLoading,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userName,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ).redacted(
              context: context,
              redact: _isLoading,
            ),
            const SizedBox(height: 4),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? ' ',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                    fontSize: 14, color: Colors.grey),
              ),
            ).redacted(
              context: context,
              redact: _isLoading,
            ),
          ],
        ),
      ],
    );
  }

  void _reviewApp(BuildContext context) async {
    try {
      StoreRedirect.redirect(
        androidAppId: 'com.craftastory.craft_a_story',
        // Replace with your Android app ID
        iOSAppId: 'com.craftastory.craft_a_story', // Replace with your iOS app ID
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error redirecting to the App store')));
    }
  }

  void showpaywall() async {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: PaywallPage(),
      ),
    );
  }

  Widget _signoutButton(){
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF0B9B8)),
        ),
        child: ElevatedButton(
          onPressed: (){
            _logout();
          },
          style: ElevatedButton.styleFrom(

            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildUpgradeToProCard() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF00001E),
                Color(0xFF7673FF),
              ])
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Get access to exclusive features',
                  style: TextStyle(
                      fontSize: 14.0, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          ElevatedButton(
            onPressed: () {
              showpaywall();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                )
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
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
            color: Theme.of(context).colorScheme.surface,
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
              child: StorageSettingsPage(),
            ),
          );
        }
        if (label == 'Help Center') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: HelpCenterPage(),
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
              child: PurchaseCreditsPage(),
            ),
          ); // Call logout function on tap
        }
        if (label == 'Share us on Social Media') {
          _shareApp(context);
        }
        if (label == 'Review Us') {
          _reviewApp(context);
        }
        if (label == 'Subscriptions') {
          if (_subscribed) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: PremiumPage(),
              ),
            );
          } else {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: PaywallPage(),
              ),
            );
          }
        }
        if (label == 'Privacy Policy') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: PrivacyPolicyPage(),
            ),
          ); // Call logout function on tap
        }
        if (label == 'Terms of Use') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: TermsOfUsePage(),
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
        MaterialPageRoute(builder: (context) => Onboarding()),
            (Route<dynamic> route) => false,
      ); // Go back after logging out
    } catch (e) {
      print('Logout failed: $e'); // Handle logout error
      // Optionally, show an error message
    }
  }

  Widget _buildSettingItemWithSwitch(BuildContext context, IconData icon, String label) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(label),
      value: themeProvider.isDarkMode,
      onChanged: (newValue) {
        if (mounted) {
          setState(() {
            themeProvider.toggleTheme(); // Toggle the theme here
          });
        }
      },
    );
  }
}