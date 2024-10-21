import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buycredits.dart';
import 'package:page_transition/page_transition.dart';
import 'Subscription.dart';
import 'languagePage.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isDarkMode = false; // Track dark mode state
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
              const SizedBox(height: 20),
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

  Widget _buildUserProfile() {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage('assets/logo.png'), // Replace with your profile image
          radius: 30,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Text(
              'Elon Musk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Elon.Musk@yourdomain.com',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );

  }

  Widget _buildUpgradeToProCard() {
    return Container(
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
        if (label == 'Buy Credits') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  LanguageAudioPage(),
            ),
          ); // Call logout function on tap
        }
        if (label == 'Subscriptions') {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child:  SubscriptionPage(),
            ),
          ); // Call logout function on tap
        }
        else {

          // Handle other setting item taps
        }
      },
    );
  }

  void _logout() async {
    try {
      await _auth.signOut(); // Sign out the user
      // Optionally, navigate to the login screen or show a success message
      Navigator.pop(context); // Go back after logging out
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
