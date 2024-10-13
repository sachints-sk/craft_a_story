import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyStoriesPage extends StatefulWidget {
  const MyStoriesPage({Key? key}) : super(key: key);

  @override
  State<MyStoriesPage> createState() => _MyStoriesPageState();
}

class _MyStoriesPageState extends State<MyStoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: const Color(0xFF161825),

        title: const Text('My Stories',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildStoryGrid(),
      ),
    );
  }

  Widget _buildStoryGrid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please sign in to see your stories."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final stories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return StoryData(
              storyId: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'] ,
              // Add other fields from your StoryData model as needed
            );
          }).toList();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent( // Change to this delegate
              maxCrossAxisExtent: 200, // Set maximum width of each item
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.85, // Adjust aspect ratio if needed
            ),
            itemCount: stories.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildStoryCard(stories[index], snapshot.data!.docs[index].data() as Map<String, dynamic>);
            },
          );
        } else {
          return const Center(child: Text('No stories found.'));
        }
      },
    );
  }

  // Reusable widget for a single story card
  Widget _buildStoryCard(StoryData story, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // Navigate to the story details page (You'll need to implement StoryDetailsPage)
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => StoryDetailsPage(storyId: story.storyId),
        //   ),
        // );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Inside your Stack widget:
// Conditional check for the entire Image.network widget
                data['coverImageUrl'] != null
                    ? Image.network(data['coverImageUrl'], height: 140, fit: BoxFit.cover) // No need for ?? '' here
                    : Image.asset('assets/placeholderimage.png', height: 140, fit: BoxFit.cover),

              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryData {
  final String storyId; // Add storyId
  final String title;
  final String description;
  final String coverImageUrl;
  // ... add other fields from your data model

  StoryData({
    required this.storyId,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    // ... other fields
  });
}