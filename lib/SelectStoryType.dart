import 'package:flutter/material.dart';
import 'createwithai.dart';
import 'package:page_transition/page_transition.dart';
import 'Services/banner_ad_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';


class SelectStoryTypePage extends StatefulWidget {
  const SelectStoryTypePage({Key? key}) : super(key: key);

  @override
  _SelectStoryTypePageState createState() => _SelectStoryTypePageState();
}

class _SelectStoryTypePageState extends State<SelectStoryTypePage> {
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
        title: const Text(
          "Select Story Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What kind of story would you like to create?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              _buildModeCard(
                context,
                imagePath: 'assets/kidsplaying.png',
                title: 'Visually Engaging\nStories',
                description: 'Uses 10 credits.',
                buttonText: 'Create Now',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const CreateStoryWithAI(video: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildModeCard(
                context,
                imagePath: 'assets/audioimage.png',
                title: 'Audio Stories',
                description: 'Uses 2 credits.',
                buttonText: 'Create Audio',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const CreateStoryWithAI(video: false),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildTipSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !_subscribed
          ? Container(
        child: BannerAdWidget(),
      )
          : null,

    );
  }

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
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Arrange elements with space between
              children: [
                Column(
                  // Wrap title and description in a Column for vertical arrangement
                  crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the start (left)
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(buttonText,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tip: Audio stories are great for reducing screen time, while visually engaging stories add an extra spark of creativity!',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}