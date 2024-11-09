import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'story_data.dart'; // Import the StoryData class
import 'dart:async'; // Import the dart:async library
import 'package:lottie/lottie.dart';
import 'buycredits.dart';
import 'viewsavedstorypage.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Explore',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section
            HeroBanner(),
            // Top Categories Section
            SectionTitle(title: 'Top Categories'),
            TopCategoriesList(),
            // Trending Stories Section
            SectionTitle(title: 'Trending Stories'),
            TrendingStoriesList(),
            // Suggested for You Section
            SectionTitle(title: 'Suggested for You'),
            SuggestedStoriesGrid(),
          ],
        ),
      ),
    );
  }
}

class HeroBanner extends StatefulWidget {
  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController(initialPage: 0);
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  Timer? _timer;
  static Future<List<FeaturedStoryData>>? _featuredStoriesFuture;


  @override
  void initState() {
    super.initState();
    _featuredStoriesFuture ??= _fetchFeaturedStories(); // Load data only once
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _animateToNextPage();
    });
  }

  void _animateToNextPage() {
    int nextPage = (_currentPageNotifier.value + 1) % 3;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _currentPageNotifier.value = nextPage;
  }

  Future<List<FeaturedStoryData>> _fetchFeaturedStories() async {
    final featuredStoriesDoc = await FirebaseFirestore.instance
        .collection('featured_stories')
        .doc('featured_stories')
        .get();

    final featuredStoriesData = featuredStoriesDoc.data()!;
    final storyOfTheWeekId = featuredStoriesData['storyOfTheWeek'];
    final seasonalSpecialId = featuredStoriesData['seasonalSpecial'];
    final featuredAdventureId = featuredStoriesData['featuredAdventure'];

    return Future.wait([
      FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(storyOfTheWeekId)
          .get()
          .then((doc) => FeaturedStoryData(
        imagePath: doc.data()?['coverImageUrl'] ?? 'assets/placeholderimage.png',
        title: 'Story of the Week',
        description: doc.data()?['title'] ?? '',
      )),
      FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(seasonalSpecialId)
          .get()
          .then((doc) => FeaturedStoryData(
        imagePath: doc.data()?['coverImageUrl'] ?? 'assets/placeholderimage.png',
        title: 'Seasonal Special',
        description: doc.data()?['title'] ?? '',
      )),
      FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(featuredAdventureId)
          .get()
          .then((doc) => FeaturedStoryData(
        imagePath: doc.data()?['coverImageUrl'] ?? 'assets/placeholderimage.png',
        title: 'Featured Adventure',
        description: doc.data()?['title'] ?? '',
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeaturedStoryData>>(
      future: _featuredStoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return PlaceholderBanner(); // Show a placeholder while loading
        }

        if (snapshot.hasData) {
          final featuredStories = snapshot.data!;
          return SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: featuredStories.length,
                  onPageChanged: (page) {
                    _currentPageNotifier.value = page; // Update the indicator
                  },
                  itemBuilder: (context, index) {
                    return BannerCard(
                      title: featuredStories[index].title,
                      image: featuredStories[index].imagePath,
                      subtitle: featuredStories[index].description,
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPageNotifier,
                    builder: (context, currentPage, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          featuredStories.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No featured stories found.'));
        }
      },
    );
  }
}

// Placeholder Widget
class PlaceholderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.photo,
          size: 100,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}


class BannerCard extends StatelessWidget {
  final String title;
  final String image;
  final String subtitle;

  BannerCard({
    required this.title,
    required this.image,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for Section Titles
class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Widget for Trending Stories (Horizontal Scroll)
class TrendingStoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .orderBy('trendingScore', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final List<StoryData> stories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return StoryData(
              coverImageUrl: data['coverImageUrl'] ?? 'assets/placeholderimage.png',
              title: data['title'] ?? '',
              storyId: doc.id,
              description: data['description'] ?? '',
              videoUrl: data['videoUrl'] ?? '',
            );
          }).toList();

          return Container(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return StoryCard(
                  image: stories[index].coverImageUrl,
                  title: stories[index].title,
                  storyData: stories[index],
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No trending stories found.'));
        }
      },
    );
  }
}

// Widget for a single Story Card
class StoryCard extends StatelessWidget {
  final String image;
  final String title;
  final StoryData storyData;

  StoryCard({
    required this.image,
    required this.title,
    required this.storyData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSavedStoryPage(storyData: storyData),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(left: 16, right: 8),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
// Widget for Top Categories (Horizontal Scroll)
class TopCategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Data for the categories
    List<String> categories = [
      'Adventure',
      'Fantasy',
      'Sci-Fi',
      'Mystery',
      'Humorous',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding to the sides
      child: Wrap(
        spacing: 4,

        children: categories.map((category) {
          return Chip(
            label: Text(
              category,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
            // Set background color to blue
            elevation: 0,
          );
        }).toList(),
      ),
    );
  }
}

// Widget for a single Category Card
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;

  CategoryCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SuggestedStoriesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .orderBy('createdAt', descending: true) // Order by creation date (newest first)
          .limit(6) // Limit the number of stories to display
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
              coverImageUrl: data['coverImageUrl'] ?? 'assets/placeholderimage.png',
              title: data['title'] ?? '',
              storyId: doc.id,
              description: data['description'] ?? '',
              videoUrl: data['videoUrl'] ?? '',
            );
          }).toList();

          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(1),
            mainAxisSpacing: 16,
            crossAxisSpacing: 2,
            children: stories.map((story) => StoryCard(image: story.coverImageUrl, title: story.title,  storyData: story,)).toList(),
          );
        } else {
          return const Center(child: Text('No stories found.'));
        }
      },
    );
  }
}

// Example story data model (You'll need to replace this with your actual data model)


class FeaturedStoryData {
  final String imagePath;
  final String title;
  final String description;

  FeaturedStoryData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}