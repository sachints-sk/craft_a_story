import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'selectmodepage.dart';
import 'package:page_transition/page_transition.dart';
import 'story_data.dart';

import 'buycredits.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class CraftAStoryHome extends StatelessWidget {
  final Function(int) onTabSelected;

  const CraftAStoryHome({Key? key, required this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
      title: Image.asset('assets/logo1.png',height: 30,fit: BoxFit.contain,),

      ),
      body: Container(

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [ Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hello👋',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Text(
                      'Jacob Jones',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
                  Row(
                    children: [
                      GestureDetector( onTap: () => _showCreditsDialog(context) ,child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24A17F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children:  [
                            Image.asset(
                              'assets/coin.png', // Your custom crown icon asset
                              height: 19,
                              width: 19,
                            ),
                            SizedBox(width: 4),
                            Text('5', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),),// First widget (green button with "5" and icon)

                      const SizedBox(width: 8),

                      // Second widget (purple crown button)
                      Container(
                        padding: const EdgeInsets.only(top: 9,bottom: 9,left: 14,right: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8A44F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/crown.png', // Your custom crown icon asset
                          height: 22,
                          width: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16), // Add some padding to the right
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161825),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        'assets/wizard1.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Unleash Your Imaginations!",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                          const Text(
                            'Create your own adventures',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF066AB2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: const SelectModePage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Create',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              buildSectionHeader('Recommended Stories', 2),
              buildHorizontalList(context, isMyStories: false, stories: []),
              const SizedBox(height: 20),
              buildSectionHeader('My Stories', 1),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stories')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('createdAt', descending: true)
                    .limit(2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<StoryData> myStories = [];
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      myStories.add(
                        StoryData(
                          coverImageUrl: data['coverImageUrl'] ?? 'assets/placeholderimage.png',
                          title: data['title'] ?? '',
                          storyId: doc.id,
                          description: data['description'] ?? '',
                            videoUrl:data['videoUrl']??'',
                        ),
                      );
                    }
                  }

                  return buildHorizontalList(context, isMyStories: true, stories: myStories);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title, int page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            onTabSelected(page);
          },
          child: const Text(
            'View All',
            style: TextStyle(color: Color(0xFF161825)),
          ),
        ),
      ],
    );
  }

  Widget buildHorizontalList(BuildContext context, {required bool isMyStories, required List<StoryData> stories}) {
    if (isMyStories && stories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'No stories yet, start creating!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: isMyStories ? stories.length : 2,
        itemBuilder: (context, index) {
          if (isMyStories) {
            return buildCardItem(context, stories[index].title, stories[index].coverImageUrl);
          } else {
            return buildCardItem(context, 'The Magical Unicorn', 'assets/testimage.png');
          }
        },
      ),
    );
  }

  Widget buildCardItem(BuildContext context, String title, String imagePath) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imagePath,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/testimage.png', height: 140, fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getUserCredits() async {
    // ... (Your logic to get credits from Firestore or local storage)
    return 10; // Example: Return 10 credits
  }

  void _showCreditsDialog(BuildContext context) async {
    int credits = await _getUserCredits();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.lottie( // Use GiffyDialog.lottie() constructor
           Lottie.asset('assets/coins.json', width: 170,
             height: 170,), // Your Lottie animation
          title: Text(
            'Your Creative Spark!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          content: Column( // Use a Column for the description
            children: [
              Text(
                'You have $credits credits to craft amazing stories.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16),
              const Text(
                "Need more inspiration? Get more credits to unlock endless storytelling possibilities!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to the Purchase Credits page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseCreditsPage(),
                  ),
                );
              },
              child: const Text('Buy Credits', style: TextStyle(color: Colors.black)),
            ),
          ],

        );
      },
    );
  }

}

// _GiffyDialogModel class
class _GiffyDialogModel {
  final Widget giffy;
  final Widget title;
  final Widget content;
  final List<TextButton> actions;

  _GiffyDialogModel({
    required this.giffy,
    required this.title,
    required this.content,
    required this.actions,
  });
}
