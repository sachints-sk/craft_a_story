import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'selectmodepage.dart';
import 'package:page_transition/page_transition.dart';

class CraftAStoryHome extends StatelessWidget {
  final Function(int) onTabSelected; // Callback function

  const CraftAStoryHome({Key? key, required this.onTabSelected}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161825),
        elevation: 0,
        toolbarHeight: 170,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello👋',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      'Jacob Jones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned settings icon at the top-right corner
              Positioned(
                top: 15,
                right: 20,
                child: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Open the end drawer
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Use an empty container to prevent the drawer icon from appearing
          Container(width: 48), // This keeps the AppBar balanced
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF161825),

                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.black),
                title: Text('Account Settings', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.black),
                title: Text('Account Settings', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              // Add more list tiles here...
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161825),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        'assets/wizard1.png', // Replace with your image asset
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unleash Your Imaginations!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Create your own adventures',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF066AB2), // Fixed the error here
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft, // Slide in from right
                                      child: const SelectModePage(),
                                     ),
                                     );
                                  },
                            child: Text('Create',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              buildSectionHeader('Recommended Stories',2),
              buildHorizontalList(context, isMyStories: false, stories: []),
              SizedBox(height: 20),
              buildSectionHeader('My Stories',1),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stories')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('createdAt', descending: true) // Order by creation date, newest first
                    .limit(2) // Limit to the latest 2 stories
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Extract story data from the snapshot
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
                          // Rating is not relevant here
                        ),
                      );
                    }
                  }

                  // Pass the fetched stories to buildHorizontalList
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
            // Call the callback function with the desired tab index
            onTabSelected(page); // Navigate to the second tab (index 1)
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
    // Check if it's the "My Stories" section and there are no stories
    if (isMyStories && stories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 8.0), // Add some padding
          child: Text(
            'No stories yet, start creating!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: isMyStories ? stories.length : 2, // Show 2 items if not "My Stories"
        itemBuilder: (context, index) {
          if (isMyStories) {
            // Use data from Firestore for "My Stories"
            return buildCardItem(
              context,
              stories[index].title,
              // Price not applicable for "My Stories"
              stories[index].coverImageUrl, // Get image from Firestore
               // Rating not applicable for "My Stories"
            );
          } else {
            // Use your existing placeholder data for "Recommended Stories"
            return buildCardItem(
              context,
              'The Magical Unicorn',
              'assets/testimage.png',
            );
          }
        },
      ),
    );
  }


  Widget buildCardItem(BuildContext context, String title,
       String imagePath, ) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,  // Fixed aspect ratio for the image
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imagePath,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/placeholderimage.png', height: 140, fit: BoxFit.cover); // Display a placeholder on error
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(  // Removed the Expanded widget here
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
// story_data.dart
class StoryData {
  final String storyId;
  final String title;
  final String description;
  final String coverImageUrl;


  StoryData({
    required this.storyId,
    required this.title,
    required this.description,
    required this.coverImageUrl,

  });
}