import 'package:flutter/material.dart';
import 'SelectStoryType.dart';
import 'package:page_transition/page_transition.dart';
import 'userstorydetails.dart';
import 'Services/banner_ad_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';



class SelectModePage extends StatefulWidget {
  const SelectModePage({Key? key}) : super(key: key);

  @override
  _SelectModePageState createState() => _SelectModePageState();
}

class _SelectModePageState extends State<SelectModePage> {
  bool _subscribed = false;
  late final void Function(CustomerInfo) _customerInfoListener;


  @override
  void initState() {
    super.initState();
    // Initialization logic here
    _setupIsPro();

  }

  @override
  void dispose() {
    // Cleanup logic here
    Purchases.removeCustomerInfoUpdateListener(_customerInfoListener);

    super.dispose();
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
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Choose Your Path",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Choose mode for story creation.",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildModeCard(
                          context,
                          imagePath: 'assets/aiwriting.png',
                          title: 'Create with AI',
                          description: 'Generate a story in seconds',
                          buttonText: 'Get Started',
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const SelectStoryTypePage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildModeCard(
                          context,
                          imagePath: 'assets/personwriting.png',
                          title: 'Write Your Story',
                          description: 'Craft a story from scratch',
                          buttonText: 'Start Writing',
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: CreateStory(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        const Center(
                          child: Text(
                            'This feature supports English language only.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.0, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !_subscribed
          ? Container(
        child: BannerAdWidget(),
      )
          : null,

    );
  }

  // Reusable widget for mode cards
  Widget _buildModeCard(
      BuildContext context, {
        required String imagePath,
        required String title,
        required String description,
        required String buttonText,
        required VoidCallback onPressed,
      }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image at the top
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Image.asset(
              imagePath,
              height: 150, // Adjust height as needed
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Arrange elements with space between
              children: [
                Column( // Wrap title and description in a Column for vertical arrangement
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start (left)
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4), // Small vertical spacing
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2259),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:  Text(buttonText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}