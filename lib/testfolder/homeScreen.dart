import 'package:flutter/material.dart';

class HomeScreen2 extends StatelessWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[50], // Light purple app bar
        title: const Text(
          'StoryKid - Home Screen',
          style: TextStyle(
            color: Colors.black, // Black text
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              // Handle user profile action
            },
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/profile_image.jpg'), // Replace with your profile image
          ),
          const SizedBox(width: 16),
        ],
        elevation: 0, // Remove app bar shadow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search stories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none, // Remove border
                  ),
                  filled: true,
                  fillColor: Colors.grey[200], // Light grey background
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Create New Story',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage('assets/create_story_image.jpg'), // Replace with your image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400], // Blue button
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Handle create new story action
                },
                child: const Text(' + Create New Story', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 32),
              const Text(
                'Recommended Stories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Use ListView.builder for a more efficient way to display a list
              ListView.builder(
                shrinkWrap: true, // Important for ListView inside Column
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for inner ListView
                itemCount: recommendedStories.length,
                itemBuilder: (context, index) {
                  return _buildStoryCard(recommendedStories[index]);
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Created Stories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: createdStories.length,
                itemBuilder: (context, index) {
                  return _buildStoryCard(createdStories[index], isCreated: true);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue[400], // Blue for selected item
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true, // Show unselected labels
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(StoryData storyData, {bool isCreated = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storyData.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  storyData.description,
                  maxLines: 2, // Limit description to 2 lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis if description is too long
                  style: const TextStyle(fontSize: 14),
                ),
                if (isCreated)
                  ElevatedButton(
                    onPressed: () {
                      // Handle edit action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      textStyle: const TextStyle(fontSize: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              storyData.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
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

// Sample data for recommended and created stories
final List<StoryData> recommendedStories = [
  StoryData(
    title: "Lily's Journey",
    description: "Join Lily in her adventure through the magical forest where she discovers talking animals and hidden treasures.",
    imagePath: 'assets/story1.jpg', // Replace with your actual image paths
  ),
  StoryData(
    title: "Max in Space",
    description: "Explore the galaxy with Max and his new alien friend, discovering planets and learning about space.",
    imagePath: 'assets/story2.jpg',
  ),
  StoryData(
    title: "Pirate Quest",
    description: "Captain Jack and his crew set sail to find hidden treasures on mysterious islands.",
    imagePath: 'assets/story3.jpg',
  ),
];

final List<StoryData> createdStories = [
  StoryData(
    title: "Magic Forest",
    description: "A tale of enchantment in a magical forest.",
    imagePath: 'assets/story4.jpg',
  ),
  StoryData(
    title: "Space Adventure",
    description: "Join the astronauts on a journey through space.",
    imagePath: 'assets/story5.jpg',
  ),
  StoryData(
    title: "Ocean Quest",
    description: "Dive into the ocean for an exciting quest.",
    imagePath: 'assets/story6.jpg',
  ),
];