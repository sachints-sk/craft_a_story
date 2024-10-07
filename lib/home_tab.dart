import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121224), // Set your dark background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Create New Story',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to create story page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Create Story', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            const Text(
              'My Stories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // My Stories Grid
            _buildStoryGrid([
              StoryData(
                title: 'The Brave Knight',
                description: 'A tale of courage and bravery.',
                imagePath: 'assets/logo.png',
              ),
              StoryData(
                title: 'Space Adventure',
                description: 'Explore the cosmos.',
                imagePath: 'assets/logo.png',
              ),
            ]),
            const SizedBox(height: 32),
            const Text(
              'Recent Stories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Recent Stories Grid
            _buildStoryGrid([
              StoryData(
                title: 'Underwater World',
                description: 'Dive into the ocean depths.',
                imagePath: 'assets/logo.png',
              ),
              StoryData(
                title: 'Magic School',
                description: 'Learn magic with...',
                imagePath: 'assets/logo.png',
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryGrid(List<StoryData> stories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7, // Adjust as needed for card proportions
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        return _buildStoryCard(stories[index]);
      },
    );
  }

  Widget _buildStoryCard(StoryData storyData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF22223D), // Dark card background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch content horizontally
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(
                storyData.imagePath,
                fit: BoxFit.cover, // Cover the container
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storyData.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  storyData.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Example story data model
class StoryData {
  final String title;
  final String description;
  final String imagePath;

  StoryData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}