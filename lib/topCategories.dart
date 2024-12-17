import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'viewsavedstorypage.dart';
import 'story_data.dart';
import 'package:intl/intl.dart';



class Topcategories extends StatefulWidget {
  final String selectedCategory; // New parameter for selected category

  const Topcategories({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  State<Topcategories> createState() => _TopcategoriesState();
}

class _TopcategoriesState extends State<Topcategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.selectedCategory, // Display the selected category
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(child: _buildStoryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .where('mode', isEqualTo: widget.selectedCategory) // Filter by category
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
            DateTime createdAtDate = (data['createdAt'] as Timestamp).toDate();
            String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);

            return StoryData(
              storyId: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'],
              videoUrl: data['videoUrl'] ?? '',
              createdAt: formattedDate,
              mode: data['mode'] ?? '',
              voice: data['voice'] ?? '',
              isAudio: data['isAudio'] ?? false,
              audioUrl: data['audioUrl'] ?? '',
            );
          }).toList();

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 3,
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
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(tag: story.coverImageUrl, child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          story.coverImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),)
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    story.mode,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.graphic_eq, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    story.voice,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
