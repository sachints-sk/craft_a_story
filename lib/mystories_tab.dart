import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'viewsavedstorypage.dart';
import 'story_data.dart';

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
        centerTitle: true,
        title: const Text(
          'My Stories',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildStoryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search here',
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
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
          return Center(
            child: Lottie.asset('assets/loadingplaceholder.json', width: 150, height: 150),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final stories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return StoryData(
              storyId: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'],
              videoUrl: data['videoUrl'] ?? '',
            );
          }).toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return _buildStoryCard(stories[index]);
            },
          );
        } else {
          return const Center(child: Text('No stories found.'));
        }
      },
    );
  }

  Widget _buildStoryCard(StoryData story) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSavedStoryPage(storyData: story),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCoverImage(story.coverImageUrl),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Add some space between title and language/voice
                  // Display language and voice information separately
                  Row(
                    children: [
                      const Icon(Icons.language, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "English (India)",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Add some space between language and voice
                  Row(
                    children: [
                      const Icon(Icons.graphic_eq, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "en-US-Standard-A",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // ... (rest of your Column children) ...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCoverImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imageUrl,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              height: 140,
              child: Lottie.asset('assets/loadingplaceholder.json', ),
            );
          },
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.asset(
        'assets/placeholderimage.png',
        height: 140,
        fit: BoxFit.cover,
      ),
    );
  }
}
